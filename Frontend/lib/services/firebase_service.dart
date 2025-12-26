import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Firebase service class for handling all Firestore operations
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _productsCollection = 'products';

  /// Get stream of all products for real-time updates
  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection(_productsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Get all products as a Future (for one-time fetch)
  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Add a new product to Firestore
  Future<String> addProduct(Product product) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_productsCollection)
          .add(product.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  /// Update an existing product
  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update(product.toFirestore());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Update product quantity (for stock in/out operations)
  Future<void> updateProductQuantity(String productId, int newQuantity) async {
    try {
      // Prevent negative stock
      if (newQuantity < 0) {
        throw Exception('Stock quantity cannot be negative');
      }

      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update({
            'quantity': newQuantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to update product quantity: $e');
    }
  }

  /// Stock In operation - increase quantity
  Future<void> stockIn(String productId, int quantityToAdd) async {
    try {
      if (quantityToAdd <= 0) {
        throw Exception('Quantity to add must be positive');
      }

      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      Product product = Product.fromFirestore(doc);
      int newQuantity = product.quantity + quantityToAdd;

      await updateProductQuantity(productId, newQuantity);
    } catch (e) {
      throw Exception('Failed to stock in: $e');
    }
  }

  /// Stock Out operation - decrease quantity
  Future<void> stockOut(String productId, int quantityToRemove) async {
    try {
      if (quantityToRemove <= 0) {
        throw Exception('Quantity to remove must be positive');
      }

      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (!doc.exists) {
        throw Exception('Product not found');
      }

      Product product = Product.fromFirestore(doc);
      int newQuantity = product.quantity - quantityToRemove;

      if (newQuantity < 0) {
        throw Exception('Insufficient stock. Available: ${product.quantity}');
      }

      await updateProductQuantity(productId, newQuantity);
    } catch (e) {
      throw Exception('Failed to stock out: $e');
    }
  }

  /// Get products that are low on stock
  Future<List<Product>> getLowStockProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .get();

      List<Product> allProducts = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();

      return allProducts.where((product) => product.isLowStock).toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }

  /// Get total inventory statistics
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_productsCollection)
          .get();

      List<Product> products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();

      int totalProducts = products.length;
      int totalStock = products.fold(0, (sum, product) => sum + product.quantity);
      int lowStockProducts = products.where((product) => product.isLowStock).length;
      int outOfStockProducts = products.where((product) => product.quantity <= 0).length;

      double totalValue = products.fold(0.0, (sum, product) =>
          sum + (product.price * product.quantity));

      return {
        'totalProducts': totalProducts,
        'totalStock': totalStock,
        'lowStockProducts': lowStockProducts,
        'outOfStockProducts': outOfStockProducts,
        'totalValue': totalValue,
      };
    } catch (e) {
      throw Exception('Failed to fetch inventory stats: $e');
    }
  }

  /// Get a single product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }
}
