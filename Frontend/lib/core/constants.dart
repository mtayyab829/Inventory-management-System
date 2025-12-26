import 'package:flutter/material.dart';

/// App-wide constants for Inventory Pro
class AppConstants {
  // App Information
  static const String appName = 'Inventory Pro';
  static const String appTagline = 'Smart Inventory Management';
  static const String appSubtitle = 'Manage your stock efficiently';
  static const String appVersion = '1.0.0';

  // Navigation
  static const int homeTabIndex = 0;
  static const int inventoryTabIndex = 1;
  static const int profileTabIndex = 2;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Dimensions
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusSmall = 8.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 4.0;

  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 28.0;

  // Form Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  static const int minProductNameLength = 2;
  static const int maxProductNameLength = 100;

  static const double minPrice = 0.01;
  static const double maxPrice = 999999.99;
  static const int minQuantity = 0;
  static const int maxQuantity = 999999;
  static const int minLowStockLimit = 0;
  static const int maxLowStockLimit = 99999;

  // Stock Management
  static const int defaultLowStockThreshold = 5;
  static const int criticalStockThreshold = 1;

  // Grid Layout
  static const int gridCrossAxisCount = 2;
  static const double gridAspectRatio = 0.85;
  static const double gridSpacing = 12.0;

  // Search
  static const int searchDebounceMs = 300;
  static const int minSearchLength = 2;

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxCacheItems = 100;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String stockHistoryCollection = 'stock_history';
  static const String activitiesCollection = 'activities';

  // User Fields
  static const String userIdField = 'userId';
  static const String emailField = 'email';
  static const String nameField = 'name';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';

  // Product Fields
  static const String productIdField = 'productId';
  static const String productNameField = 'name';
  static const String categoryField = 'category';
  static const String priceField = 'price';
  static const String quantityField = 'quantity';
  static const String lowStockLimitField = 'lowStockLimit';
  static const String descriptionField = 'description';

  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPassword = 'Password must be at least 6 characters';
  static const String passwordsDontMatch = 'Passwords do not match';
  static const String invalidName = 'Name must be 2-50 characters';
  static const String invalidProductName = 'Product name must be 2-100 characters';
  static const String invalidPrice = 'Price must be greater than 0';
  static const String invalidQuantity = 'Quantity must be 0 or greater';
  static const String invalidLowStockLimit = 'Low stock limit must be 0 or greater';
  static const String priceTooHigh = 'Price seems too high';
  static const String quantityTooHigh = 'Quantity seems too high';
  static const String insufficientStock = 'Insufficient stock available';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String signupSuccess = 'Account created successfully!';
  static const String logoutSuccess = 'Logged out successfully';
  static const String productAdded = 'Product added successfully';
  static const String productUpdated = 'Product updated successfully';
  static const String productDeleted = 'Product deleted successfully';
  static const String stockUpdated = 'Stock updated successfully';

  // Error Messages
  static const String genericError = 'An error occurred. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String permissionDenied = 'Permission denied';
  static const String errorOccurred = 'An error occurred';

  // Loading Messages
  static const String loading = 'Loading...';
  static const String saving = 'Save';
  static const String loggingIn = 'Logging in...';
  static const String signingUp = 'Creating account...';
  static const String updating = 'Updating...';

  // Empty States
  static const String noProducts = 'No products found';
  static const String noProductsMessage = 'Start by adding your first product';
  static const String searchNoResults = 'No products match your search';
  static const String searchNoResultsMessage = 'Try different keywords';

  // Stock Status
  static const String inStock = 'In Stock';
  static const String lowStock = 'Low Stock';
  static const String outOfStock = 'Out of Stock';
  static const String criticalStock = 'Critical Stock';

  // Categories (can be expanded)
  static const List<String> defaultCategories = [
    'Electronics',
    'Clothing',
    'Food',
    'Books',
    'Home & Garden',
    'Sports',
    'Health & Beauty',
    'Automotive',
    'Other',
  ];

  // Date Formats
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ssZ';

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.fastOutSlowIn;

  // Route Names
  static const String welcomeRoute = '/welcome';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String homeRoute = '/home';
  static const String inventoryRoute = '/inventory';
  static const String addProductRoute = '/add-product';
  static const String productDetailRoute = '/product-detail';
  static const String profileRoute = '/profile';
}
