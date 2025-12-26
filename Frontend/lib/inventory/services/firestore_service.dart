import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../dashboard/models/activity_model.dart';
import '../models/product_model.dart';
import '../models/stock_history_model.dart';

/// Firestore service for inventory management with user-specific data
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Get stream of user's products for real-time updates
  Stream<List<Product>> getUserProductsStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    // Alternative approach: Get all products and filter client-side
    // This avoids the composite index requirement
    return _firestore
        .collection(AppConstants.productsCollection)
        .where(AppConstants.userIdField, isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final products =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      // Sort by createdAt descending (client-side sorting)
      products.sort((a, b) {
        // Handle null createdAt values - null dates go to the end
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return products;
    }).handleError((error) {
      print('Error getting products stream: $error');
      return [];
    });
  }

  /// Get user's products as a Future
  Future<List<Product>> getUserProducts() async {
    if (_userId == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where(AppConstants.userIdField, isEqualTo: _userId)
          .get();

      final products =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      // Sort by createdAt descending (client-side sorting)
      products.sort((a, b) {
        // Handle null createdAt values - null dates go to the end
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return products;
    } catch (e) {
      print('Error getting products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Add a new product for the current user
  Future<String> addProduct(Product product) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Create product data with user ID
      final productData = product.toFirestore();
      productData[AppConstants.userIdField] = _userId;

      DocumentReference docRef = await _firestore
          .collection(AppConstants.productsCollection)
          .add(productData);

      // Record activity for new product
      final activity = Activity(
        userId: _userId!,
        type: 'product_added',
        title: 'Product Added',
        description: 'Added new product: ${product.name}',
        productId: docRef.id,
        productName: product.name,
        timestamp: DateTime.now(),
      );
      await recordActivity(activity);

      // Record initial stock history only if quantity > 0
      if (product.quantity > 0) {
        final stockHistory = StockHistory(
          productId: docRef.id,
          userId: _userId!,
          action: 'created',
          quantityChange: product.quantity,
          previousQuantity: 0,
          newQuantity: product.quantity,
          notes: 'Product created with initial stock',
          timestamp: DateTime.now(),
        );
        await recordStockHistory(stockHistory);
        print('Created initial stock history for product: ${product.name}');
      }

      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  /// Update an existing product
  Future<void> updateProduct(String productId, Product product) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final productData = product.toFirestore();
      productData[AppConstants.updatedAtField] = FieldValue.serverTimestamp();

      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update(productData);

      // Record activity for product update
      final activity = Activity(
        userId: _userId!,
        type: 'product_updated',
        title: 'Product Updated',
        description: 'Updated product details',
        productId: productId,
        productName: product.name,
        timestamp: DateTime.now(),
      );
      await recordActivity(activity);
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get product name before deletion for activity log
      final productDoc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      String productName = 'Unknown Product';
      if (productDoc.exists) {
        final data = productDoc.data() as Map<String, dynamic>;
        productName = data[AppConstants.productNameField] ?? 'Unknown Product';
      }

      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .delete();

      // Record activity for product deletion
      final activity = Activity(
        userId: _userId!,
        type: 'product_deleted',
        title: 'Product Deleted',
        description: 'Deleted product: $productName',
        productId: productId,
        productName: productName,
        timestamp: DateTime.now(),
      );
      await recordActivity(activity);
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Update product quantity (for stock in/out operations)
  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Prevent negative stock
      if (newQuantity < 0) {
        throw Exception('Stock quantity cannot be negative');
      }

      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        AppConstants.quantityField: newQuantity,
        AppConstants.updatedAtField: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating product quantity: $e');
      throw Exception('Failed to update product quantity: $e');
    }
  }

  /// Stock In operation - increase quantity
  Future<void> stockIn(String productId, int quantityToAdd) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      if (quantityToAdd <= 0) {
        throw Exception('Quantity to add must be positive');
      }

      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final currentQuantity = data[AppConstants.quantityField] ?? 0;
      final newQuantity = currentQuantity + quantityToAdd;
      final productName =
          data[AppConstants.productNameField] ?? 'Unknown Product';

      await updateProductQuantity(productId, newQuantity);

      // Record stock history
      final stockHistory = StockHistory(
        productId: productId,
        userId: _userId!,
        action: 'stock_in',
        quantityChange: quantityToAdd,
        previousQuantity: currentQuantity,
        newQuantity: newQuantity,
        timestamp: DateTime.now(),
      );
      await recordStockHistory(stockHistory);

      // Record activity
      final activity = Activity(
        userId: _userId!,
        type: 'stock_changed',
        title: 'Stock Increased',
        description: 'Added $quantityToAdd units to $productName',
        productId: productId,
        productName: productName,
        quantityChange: quantityToAdd,
        timestamp: DateTime.now(),
      );
      await recordActivity(activity);
    } catch (e) {
      print('Error stock in: $e');
      throw Exception('Failed to stock in: $e');
    }
  }

  /// Stock Out operation - decrease quantity
  Future<void> stockOut(String productId, int quantityToRemove) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      if (quantityToRemove <= 0) {
        throw Exception('Quantity to remove must be positive');
      }

      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final currentQuantity = data[AppConstants.quantityField] ?? 0;

      if (quantityToRemove > currentQuantity) {
        throw Exception('Insufficient stock. Available: $currentQuantity');
      }

      final newQuantity = currentQuantity - quantityToRemove;
      final productName =
          data[AppConstants.productNameField] ?? 'Unknown Product';

      await updateProductQuantity(productId, newQuantity);

      // Record stock history
      final stockHistory = StockHistory(
        productId: productId,
        userId: _userId!,
        action: 'stock_out',
        quantityChange: -quantityToRemove, // Negative for stock out
        previousQuantity: currentQuantity,
        newQuantity: newQuantity,
        timestamp: DateTime.now(),
      );
      await recordStockHistory(stockHistory);

      // Record activity
      final activity = Activity(
        userId: _userId!,
        type: 'stock_changed',
        title: 'Stock Decreased',
        description: 'Removed $quantityToRemove units from $productName',
        productId: productId,
        productName: productName,
        quantityChange: -quantityToRemove, // Negative for stock out
        timestamp: DateTime.now(),
      );
      await recordActivity(activity);
    } catch (e) {
      print('Error stock out: $e');
      throw Exception('Failed to stock out: $e');
    }
  }

  /// Get products that are low on stock for current user
  Future<List<Product>> getLowStockProducts() async {
    if (_userId == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where(AppConstants.userIdField, isEqualTo: _userId)
          .get();

      List<Product> allProducts =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      return allProducts.where((product) => product.isLowStock).toList();
    } catch (e) {
      print('Error getting low stock products: $e');
      throw Exception('Failed to fetch low stock products: $e');
    }
  }

  /// Get inventory statistics for current user
  Future<Map<String, dynamic>> getInventoryStats() async {
    if (_userId == null) {
      return {
        'totalProducts': 0,
        'totalStock': 0,
        'lowStockProducts': 0,
        'outOfStockProducts': 0,
        'totalValue': 0.0,
      };
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where(AppConstants.userIdField, isEqualTo: _userId)
          .get();

      List<Product> products =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      int totalProducts = products.length;
      int totalStock =
          products.fold(0, (sum, product) => sum + product.quantity);
      int lowStockProducts =
          products.where((product) => product.isLowStock).length;
      int outOfStockProducts =
          products.where((product) => product.quantity <= 0).length;

      double totalValue = products.fold(
          0.0, (sum, product) => sum + (product.price * product.quantity));

      return {
        'totalProducts': totalProducts,
        'totalStock': totalStock,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
        'totalValue': totalValue,
      };
    } catch (e) {
      print('Error getting inventory stats: $e');
      throw Exception('Failed to fetch inventory stats: $e');
    }
  }

  /// Get a single product by ID
  Future<Product?> getProductById(String productId) async {
    if (_userId == null) {
      return null;
    }

    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Search products by name or category
  Future<List<Product>> searchProducts(String query) async {
    if (_userId == null || query.trim().isEmpty) {
      return [];
    }

    try {
      // Get all user products and filter client-side
      // Note: Firestore doesn't support case-insensitive search easily
      final allProducts = await getUserProducts();
      final searchTerm = query.toLowerCase().trim();

      return allProducts.where((product) {
        return product.name.toLowerCase().contains(searchTerm) ||
            product.category.toLowerCase().contains(searchTerm);
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    if (_userId == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where(AppConstants.userIdField, isEqualTo: _userId)
          .where(AppConstants.categoryField, isEqualTo: category)
          .get();

      final products =
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

      // Sort by createdAt descending (client-side sorting)
      products.sort((a, b) {
        // Handle null createdAt values - null dates go to the end
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return products;
    } catch (e) {
      print('Error getting products by category: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  /// Get unique categories for current user
  Future<List<String>> getCategories() async {
    if (_userId == null) {
      return [];
    }

    try {
      final products = await getUserProducts();
      final categories =
          products.map((product) => product.category).toSet().toList()..sort();

      return categories;
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  /// Record stock history entry
  Future<String> recordStockHistory(StockHistory history) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(AppConstants.stockHistoryCollection)
          .add(history.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error recording stock history: $e');
      throw Exception('Failed to record stock history: $e');
    }
  }

  /// Get stock history for a specific product
  Future<List<StockHistory>> getProductStockHistory(String productId) async {
    if (_userId == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.stockHistoryCollection)
          .where(AppConstants.userIdField, isEqualTo: _userId)
          .where('productId', isEqualTo: productId)
          .orderBy('timestamp', descending: true)
          .limit(50) // Limit to last 50 entries
          .get();

      final histories =
          snapshot.docs.map((doc) => StockHistory.fromFirestore(doc)).toList();

      return histories;
    } catch (e) {
      print('Error getting product stock history: $e');
      return [];
    }
  }

  /// Record user activity
  Future<String> recordActivity(Activity activity) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(AppConstants.activitiesCollection)
          .add(activity.toFirestore());

      return docRef.id;
    } catch (e) {
      print('Error recording activity: $e');
      throw Exception('Failed to record activity: $e');
    }
  }

  /// Get recent activities for current user
  Future<List<Activity>> getRecentActivities({int limit = 20}) async {
    if (_userId == null) {
      return [];
    }

    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.activitiesCollection)
          .where(AppConstants.userIdField, isEqualTo: _userId)
          .get();

      final activities =
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();

      // Sort by timestamp descending (client-side sorting)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return activities.take(limit).toList();
    } catch (e) {
      print('Error getting recent activities: $e');
      return [];
    }
  }

  /// Get stream of recent activities for real-time updates
  Stream<List<Activity>> getRecentActivitiesStream({int limit = 20}) {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(AppConstants.activitiesCollection)
        .where(AppConstants.userIdField, isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final activities =
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
      // Sort by timestamp descending (client-side sorting)
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(limit).toList();
    }).handleError((error) {
      print('Error getting activities stream: $error');
      return [];
    });
  }
}
