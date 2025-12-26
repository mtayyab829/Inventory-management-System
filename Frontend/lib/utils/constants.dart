import 'package:flutter/material.dart';

/// App-wide constants including colors, strings, and configuration values

// App Colors
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFF03DAC6);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);

  // Stock status colors
  static const Color inStock = Color(0xFF4CAF50);
  static const Color lowStock = Color(0xFFFF9800);
  static const Color outOfStock = Color(0xFFF44336);
}

// App Strings
class AppStrings {
  // App titles
  static const String appName = 'Inventory Manager';
  static const String appSubtitle = 'Manage your stock efficiently';

  // Screen titles
  static const String products = 'Products';
  static const String addProduct = 'Add Product';
  static const String editProduct = 'Edit Product';
  static const String productDetails = 'Product Details';

  // Button labels
  static const String add = 'Add';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String stockIn = 'Stock In';
  static const String stockOut = 'Stock Out';
  static const String confirm = 'Confirm';

  // Form labels
  static const String productName = 'Product Name';
  static const String category = 'Category';
  static const String price = 'Price';
  static const String quantity = 'Quantity';
  static const String lowStockLimit = 'Low Stock Limit';

  // Placeholders
  static const String enterProductName = 'Enter product name';
  static const String enterCategory = 'Enter category';
  static const String enterPrice = 'Enter price';
  static const String enterQuantity = 'Enter quantity';
  static const String enterLowStockLimit = 'Enter low stock limit';

  // Messages
  static const String loading = 'Loading...';
  static const String noProducts = 'No products found';
  static const String addFirstProduct = 'Add your first product to get started!';
  static const String confirmDelete = 'Are you sure you want to delete this product?';
  static const String productAdded = 'Product added successfully';
  static const String productUpdated = 'Product updated successfully';
  static const String productDeleted = 'Product deleted successfully';
  static const String stockUpdated = 'Stock updated successfully';
  static const String errorOccurred = 'An error occurred';
  static const String invalidInput = 'Please check your input';
  static const String insufficientStock = 'Insufficient stock available';

  // Stock status
  static const String inStock = 'In Stock';
  static const String lowStock = 'Low Stock';
  static const String outOfStock = 'Out of Stock';

  // Dashboard labels
  static const String totalProducts = 'Total Products';
  static const String totalStock = 'Total Stock';
  static const String lowStockProducts = 'Low Stock Items';
  static const String outOfStockProducts = 'Out of Stock';
  static const String totalValue = 'Total Value';
}

// App Configuration
class AppConfig {
  // Form validation
  static const int minProductNameLength = 2;
  static const int maxProductNameLength = 50;
  static const double minPrice = 0.01;
  static const int minQuantity = 0;
  static const int maxQuantity = 999999;
  static const int minLowStockLimit = 0;
  static const int maxLowStockLimit = 99999;

  // UI Configuration
  static const double borderRadius = 12.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double cardElevation = 2.0;

  // Grid configuration
  static const int gridCrossAxisCount = 2;
  static const double gridAspectRatio = 0.8;
  static const double gridSpacing = 12.0;
}

// Input Validation Messages
class ValidationMessages {
  static const String requiredField = 'This field is required';
  static const String invalidProductName = 'Product name must be 2-50 characters';
  static const String invalidPrice = 'Price must be greater than 0';
  static const String invalidQuantity = 'Quantity must be 0 or greater';
  static const String invalidLowStockLimit = 'Low stock limit must be 0 or greater';
  static const String priceTooHigh = 'Price seems too high';
  static const String quantityTooHigh = 'Quantity seems too high';
  static const String insufficientStock = 'Insufficient stock available';
}

// Firebase Collection Names
class FirestoreCollections {
  static const String products = 'products';
}

// Date Formats
class DateFormats {
  static const String displayDateTime = 'MMM dd, yyyy hh:mm a';
  static const String displayDate = 'MMM dd, yyyy';
  static const String displayTime = 'hh:mm a';
}
