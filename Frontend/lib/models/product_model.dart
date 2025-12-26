import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model class representing inventory items in Firestore
class Product {
  final String? productId;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final int lowStockLimit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.productId,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.lowStockLimit,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      productId: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 0,
      lowStockLimit: data['lowStockLimit'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Product to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'lowStockLimit': lowStockLimit,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of Product with updated fields
  Product copyWith({
    String? productId,
    String? name,
    String? category,
    double? price,
    int? quantity,
    int? lowStockLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      lowStockLimit: lowStockLimit ?? this.lowStockLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if product is low on stock
  bool get isLowStock => quantity <= lowStockLimit;

  /// Get stock status string
  String get stockStatus {
    if (quantity <= 0) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  /// Get stock status color
  String get stockStatusColor {
    if (quantity <= 0) return 'red';
    if (isLowStock) return 'orange';
    return 'green';
  }

  @override
  String toString() {
    return 'Product(productId: $productId, name: $name, category: $category, '
           'price: $price, quantity: $quantity, lowStockLimit: $lowStockLimit)';
  }
}
