import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Product model class representing inventory items in Firestore
class Product {
  final String? productId;
  final String userId;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final int lowStockLimit;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.productId,
    required this.userId,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.lowStockLimit,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      productId: doc.id,
      userId: data[AppConstants.userIdField] ?? '',
      name: data[AppConstants.productNameField] ?? '',
      category: data[AppConstants.categoryField] ?? '',
      price: (data[AppConstants.priceField] ?? 0.0).toDouble(),
      quantity: data[AppConstants.quantityField] ?? 0,
      lowStockLimit: data[AppConstants.lowStockLimitField] ?? 0,
      description: data['description'],
      createdAt: data[AppConstants.createdAtField] != null
          ? (data[AppConstants.createdAtField] as Timestamp).toDate()
          : null,
      updatedAt: data[AppConstants.updatedAtField] != null
          ? (data[AppConstants.updatedAtField] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert Product to Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      AppConstants.userIdField: userId,
      AppConstants.productNameField: name,
      AppConstants.categoryField: category,
      AppConstants.priceField: price,
      AppConstants.quantityField: quantity,
      AppConstants.lowStockLimitField: lowStockLimit,
      'description': description,
      AppConstants.createdAtField: createdAt ?? FieldValue.serverTimestamp(),
      AppConstants.updatedAtField: FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of Product with updated fields
  Product copyWith({
    String? productId,
    String? userId,
    String? name,
    String? category,
    double? price,
    int? quantity,
    int? lowStockLimit,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      lowStockLimit: lowStockLimit ?? this.lowStockLimit,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if product is low on stock
  bool get isLowStock => quantity <= lowStockLimit;

  /// Check if product is out of stock
  bool get isOutOfStock => quantity <= 0;

  /// Get stock status string
  String get stockStatus {
    if (quantity <= 0) return AppConstants.outOfStock;
    if (isLowStock) return AppConstants.lowStock;
    return AppConstants.inStock;
  }

  /// Get stock status color
  Color get stockStatusColor {
    if (quantity <= 0) return const Color(0xFFEF4444); // Red
    if (isLowStock) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFF10B981); // Green
  }

  /// Get formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Get formatted quantity with status
  String get quantityWithStatus => '$quantity ${isLowStock ? '(Low)' : ''}';

  @override
  String toString() {
    return 'Product(productId: $productId, name: $name, category: $category, '
           'price: $price, quantity: $quantity, lowStockLimit: $lowStockLimit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}
