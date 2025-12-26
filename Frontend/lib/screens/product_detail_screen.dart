import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../widgets/stock_button.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
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
        title: const Text(AppStrings.productDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProduct(),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header
            _buildProductHeader(),

            const SizedBox(height: AppConfig.paddingLarge),

            // Stock Management Section
            _buildStockManagement(),

            const SizedBox(height: AppConfig.paddingLarge),

            // Product Information
            _buildProductInformation(),

            const SizedBox(height: AppConfig.paddingLarge),

            // Stock Status
            _buildStockStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentProduct.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConfig.paddingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.paddingSmall,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _currentProduct.category,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: AppConfig.paddingMedium),
            Text(
              '\$${_currentProduct.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConfig.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: StockButton(
                    label: AppStrings.stockIn,
                    icon: Icons.add,
                    color: AppColors.success,
                    onPressed: () => _showStockDialog(isStockIn: true),
                  ),
                ),
                const SizedBox(width: AppConfig.paddingMedium),
                Expanded(
                  child: StockButton(
                    label: AppStrings.stockOut,
                    icon: Icons.remove,
                    color: AppColors.warning,
                    onPressed: () => _showStockDialog(isStockIn: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConfig.paddingMedium),
            _buildInfoRow('Current Stock', _currentProduct.quantity.toString()),
            _buildInfoRow(
                'Low Stock Limit', _currentProduct.lowStockLimit.toString()),
            if (_currentProduct.createdAt != null)
              _buildInfoRow(
                'Created',
                _formatDateTime(_currentProduct.createdAt!),
              ),
            if (_currentProduct.updatedAt != null)
              _buildInfoRow(
                'Last Updated',
                _formatDateTime(_currentProduct.updatedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus() {
    return Card(
      color: _getStockStatusColor().withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.paddingMedium),
        child: Row(
          children: [
            Icon(
              _getStockStatusIcon(),
              color: _getStockStatusColor(),
              size: 32,
            ),
            const SizedBox(width: AppConfig.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentProduct.stockStatus,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _getStockStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _getStockStatusMessage(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConfig.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
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
        await _firebaseService.stockIn(_currentProduct.productId!, quantity);
      } else {
        await _firebaseService.stockOut(_currentProduct.productId!, quantity);
      }

      // Refresh product data
      final updatedProduct =
          await _firebaseService.getProductById(_currentProduct.productId!);
      if (updatedProduct != null && mounted) {
        setState(() => _currentProduct = updatedProduct);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.stockUpdated),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorOccurred}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToEditProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: _currentProduct),
      ),
    );

    if (result == true && mounted) {
      // Refresh product data after edit
      final updatedProduct =
          await _firebaseService.getProductById(_currentProduct.productId!);
      if (updatedProduct != null) {
        setState(() => _currentProduct = updatedProduct);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content:
            Text('Are you sure you want to delete "${_currentProduct.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => _deleteProduct(),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct() async {
    Navigator.pop(context); // Close dialog

    try {
      await _firebaseService.deleteProduct(_currentProduct.productId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.productDeleted),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Go back to product list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorOccurred}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStockStatusColor() {
    if (_currentProduct.quantity <= 0) {
      return AppColors.outOfStock;
    } else if (_currentProduct.isLowStock) {
      return AppColors.lowStock;
    } else {
      return AppColors.inStock;
    }
  }

  IconData _getStockStatusIcon() {
    if (_currentProduct.quantity <= 0) {
      return Icons.cancel;
    } else if (_currentProduct.isLowStock) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  String _getStockStatusMessage() {
    if (_currentProduct.quantity <= 0) {
      return 'Product is out of stock';
    } else if (_currentProduct.isLowStock) {
      return 'Stock is below the minimum limit';
    } else {
      return 'Stock level is adequate';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Stock Dialog Widget
class StockDialog extends StatefulWidget {
  final Product product;
  final bool isStockIn;
  final Function(int) onConfirm;

  const StockDialog({
    super.key,
    required this.product,
    required this.isStockIn,
    required this.onConfirm,
  });

  @override
  State<StockDialog> createState() => _StockDialogState();
}

class _StockDialogState extends State<StockDialog> {
  final _quantityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isStockIn ? 'Stock In' : 'Stock Out';
    final icon = widget.isStockIn ? Icons.add : Icons.remove;
    final color = widget.isStockIn ? AppColors.success : AppColors.warning;

    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppConfig.paddingSmall),
          Text(title),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current stock: ${widget.product.quantity}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConfig.paddingMedium),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                hintText:
                    'Enter quantity to ${widget.isStockIn ? 'add' : 'remove'}',
                prefixIcon: Icon(icon),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateQuantity(value),
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(backgroundColor: color),
          child: const Text(AppStrings.confirm),
        ),
      ],
    );
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.requiredField;
    }

    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Please enter a valid quantity greater than 0';
    }

    if (!widget.isStockIn && quantity > widget.product.quantity) {
      return ValidationMessages.insufficientStock;
    }

    return null;
  }

  void _confirm() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      widget.onConfirm(quantity);
      Navigator.pop(context);
    }
  }
}
