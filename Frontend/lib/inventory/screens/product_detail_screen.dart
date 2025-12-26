import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../widgets/stock_dialog.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Product _currentProduct;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header Card
            _buildProductHeader(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Stock Management Card
            _buildStockManagement(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Product Information Card
            _buildProductInformation(),

          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            colors: [
              _currentProduct.stockStatusColor.withOpacity(0.1),
              _currentProduct.stockStatusColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _currentProduct.stockStatusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _currentProduct.stockStatusColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: AppConstants.paddingMedium),

                // Product Name and Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentProduct.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentProduct.category,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingLarge),

            // Price and Stock Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentProduct.formattedPrice,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _currentProduct.stockStatusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentProduct.stockStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Current Quantity
            Row(
              children: [
                const Icon(
                  Icons.inventory,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Stock: ${_currentProduct.quantity} units',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
              ],
            ),

            if (_currentProduct.isLowStock) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Low stock alert: Below ${_currentProduct.lowStockLimit} units',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStockManagement() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStockButton(
                    label: 'Stock In',
                    icon: Icons.add_circle,
                    color: const Color(0xFF10B981),
                    onPressed: () => _showStockDialog(isStockIn: true),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildStockButton(
                    label: 'Stock Out',
                    icon: Icons.remove_circle,
                    color: const Color(0xFFF59E0B),
                    onPressed: () => _showStockDialog(isStockIn: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stock In increases quantity, Stock Out decreases quantity',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.paddingMedium,
        ),
      ),
    );
  }

  Widget _buildProductInformation() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildInfoRow('Product ID', _currentProduct.productId ?? 'N/A'),
            _buildInfoRow(
                'Low Stock Limit', '${_currentProduct.lowStockLimit} units'),
            if (_currentProduct.description != null &&
                _currentProduct.description!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              _buildInfoRow('Description', _currentProduct.description!),
            ],
            if (_currentProduct.createdAt != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              _buildInfoRow(
                  'Created', _formatDateTime(_currentProduct.createdAt!)),
            ],
            if (_currentProduct.updatedAt != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              _buildInfoRow(
                  'Last Updated', _formatDateTime(_currentProduct.updatedAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }


  void _showStockDialog({required bool isStockIn}) {
    showDialog(
      context: context,
      builder: (context) => StockDialog(
        product: _currentProduct,
        isStockIn: isStockIn,
        onConfirm: (quantity) => _updateStock(isStockIn, quantity),
      ),
    );
  }

  Future<void> _updateStock(bool isStockIn, int quantity) async {
    try {
      if (isStockIn) {
        await _firestoreService.stockIn(_currentProduct.productId!, quantity);
      } else {
        await _firestoreService.stockOut(_currentProduct.productId!, quantity);
      }

      // Refresh product data
      final updatedProduct =
          await _firestoreService.getProductById(_currentProduct.productId!);
      if (updatedProduct != null && mounted) {
        setState(() => _currentProduct = updatedProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.stockUpdated),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.errorOccurred}: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(
        product: _currentProduct,
        onProductUpdated: (updatedProduct) {
          setState(() => _currentProduct = updatedProduct);
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${_currentProduct.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteProduct(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    Navigator.pop(context); // Close dialog

    try {
      await _firestoreService.deleteProduct(_currentProduct.productId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.productDeleted),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context); // Go back to inventory list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.errorOccurred}: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon() {
    final category = _currentProduct.category.toLowerCase();

    if (category.contains('electronic') ||
        category.contains('phone') ||
        category.contains('computer')) {
      return Icons.devices;
    } else if (category.contains('cloth') ||
        category.contains('fashion') ||
        category.contains('wear')) {
      return Icons.checkroom;
    } else if (category.contains('food') ||
        category.contains('drink') ||
        category.contains('beverage')) {
      return Icons.restaurant;
    } else if (category.contains('book') || category.contains('education')) {
      return Icons.menu_book;
    } else if (category.contains('home') ||
        category.contains('garden') ||
        category.contains('furniture')) {
      return Icons.home;
    } else if (category.contains('sport') || category.contains('fitness')) {
      return Icons.sports_soccer;
    } else if (category.contains('health') ||
        category.contains('beauty') ||
        category.contains('care')) {
      return Icons.spa;
    } else if (category.contains('auto') ||
        category.contains('car') ||
        category.contains('vehicle')) {
      return Icons.directions_car;
    } else {
      return Icons.inventory_2;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class EditProductDialog extends StatefulWidget {
  final Product product;
  final Function(Product) onProductUpdated;

  const EditProductDialog({
    super.key,
    required this.product,
    required this.onProductUpdated,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // Predefined categories (same as add product screen)
  final List<String> _predefinedCategories = [
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Home & Garden',
    'Sports & Fitness',
    'Health & Beauty',
    'Books & Education',
    'Automotive',
    'Toys & Games',
    'Office Supplies',
    'Other'
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _lowStockLimitController;
  late final TextEditingController _descriptionController;

  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);

    // Check if the product's category is in the predefined list
    if (_predefinedCategories.contains(widget.product.category)) {
      _selectedCategory = widget.product.category;
    } else {
      _selectedCategory = 'Other';
    }

    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _quantityController =
        TextEditingController(text: widget.product.quantity.toString());
    _lowStockLimitController =
        TextEditingController(text: widget.product.lowStockLimit.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customCategoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _lowStockLimitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Text(
                      'Edit Product',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Product Name *',
                  hintText: 'Enter product name',
                  prefixIcon: Icons.shopping_bag,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Product name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category *',
                    hintText: 'Select a category',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                  items: _predefinedCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      // Clear custom category if not "Other"
                      if (value != 'Other') {
                        _customCategoryController.clear();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down),
                ),

                // Custom Category Field (only show when "Other" is selected)
                if (_selectedCategory == 'Other') ...[
                  const SizedBox(height: AppConstants.paddingSmall),
                  CustomTextField(
                    controller: _customCategoryController,
                    labelText: 'Custom Category *',
                    hintText: 'Enter your custom category',
                    prefixIcon: Icons.edit,
                    validator: (value) {
                      if (_selectedCategory == 'Other') {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a custom category';
                        }
                        if (value.trim().length < 2) {
                          return 'Custom category must be at least 2 characters';
                        }
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
                const SizedBox(height: AppConstants.paddingSmall),
                CustomTextField(
                  controller: _priceController,
                  labelText: 'Price *',
                  hintText: '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.attach_money,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price is required';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                CustomTextField(
                  controller: _quantityController,
                  labelText: 'Current Quantity *',
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.inventory,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Quantity is required';
                    }
                    final quantity = int.tryParse(value);
                    if (quantity == null || quantity < 0) {
                      return 'Enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                CustomTextField(
                  controller: _lowStockLimitController,
                  labelText: 'Low Stock Alert *',
                  hintText: 'Alert when stock falls below this number',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.warning,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Low stock limit is required';
                    }
                    final limit = int.tryParse(value);
                    if (limit == null || limit < 0) {
                      return 'Enter a valid limit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Description (Optional)',
                  hintText: 'Additional product details',
                  prefixIcon: Icons.description,
                  maxLines: 2,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: CustomButton(
                        text: 'Update Product',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _updateProduct,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Determine the final category value
      String finalCategory;
      if (_selectedCategory == 'Other') {
        finalCategory = _customCategoryController.text.trim();
      } else {
        finalCategory = _selectedCategory!;
      }

      final updatedProduct = Product(
        productId: widget.product.productId,
        userId: widget.product.userId,
        name: _nameController.text.trim(),
        category: finalCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        lowStockLimit: int.parse(_lowStockLimitController.text),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.product.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateProduct(
          widget.product.productId!, updatedProduct);

      if (mounted) {
        widget.onProductUpdated(updatedProduct);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product updated successfully'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
