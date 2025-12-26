import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../core/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Predefined categories
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

  // Form controllers
  final _nameController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockLimitController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              CustomTextField(
                controller: _nameController,
                labelText: 'Product Name *',
                hintText: 'Enter product name',
                prefixIcon: Icons.shopping_bag,
                validator: _validateProductName,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                validator: _validateCategory,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down),
              ),

              // Custom Category Field (only show when "Other" is selected)
              if (_selectedCategory == 'Other') ...[
                const SizedBox(height: AppConstants.paddingMedium),
                CustomTextField(
                  controller: _customCategoryController,
                  labelText: 'Custom Category *',
                  hintText: 'Enter your custom category',
                  prefixIcon: Icons.edit,
                  validator: _validateCustomCategory,
                  textCapitalization: TextCapitalization.words,
                ),
              ],

              const SizedBox(height: AppConstants.paddingMedium),

              // Price
              CustomTextField(
                controller: _priceController,
                labelText: 'Price *',
                hintText: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: _validatePrice,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Quantity
              CustomTextField(
                controller: _quantityController,
                labelText: 'Initial Quantity *',
                hintText: '0',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.inventory,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateQuantity,
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Low Stock Limit
              CustomTextField(
                controller: _lowStockLimitController,
                labelText: 'Low Stock Alert *',
                hintText: 'Alert when stock falls below this number',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.warning,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateLowStockLimit,
                helperText: 'You\'ll get notified when stock is low',
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Description (Optional)
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description (Optional)',
                hintText: 'Additional product details',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Save Button
              CustomButton(
                text: AppConstants.saving,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _saveProduct,
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Info Card
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: Text(
                        'All fields marked with * are required. You can edit these details later.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Validation methods
  String? _validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.requiredField;
    }
    if (value.trim().length < AppConstants.minProductNameLength) {
      return AppConstants.invalidProductName;
    }
    if (value.trim().length > AppConstants.maxProductNameLength) {
      return AppConstants.invalidProductName;
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  String? _validateCustomCategory(String? value) {
    if (_selectedCategory == 'Other') {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter a custom category';
      }
      if (value.trim().length < 2) {
        return 'Custom category must be at least 2 characters';
      }
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.requiredField;
    }
    final price = double.tryParse(value);
    if (price == null) {
      return AppConstants.invalidPrice;
    }
    if (price < AppConstants.minPrice) {
      return AppConstants.invalidPrice;
    }
    if (price > AppConstants.maxPrice) {
      return AppConstants.priceTooHigh;
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.requiredField;
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return AppConstants.invalidQuantity;
    }
    if (quantity < AppConstants.minQuantity) {
      return AppConstants.invalidQuantity;
    }
    if (quantity > AppConstants.maxQuantity) {
      return AppConstants.quantityTooHigh;
    }
    return null;
  }

  String? _validateLowStockLimit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.requiredField;
    }
    final limit = int.tryParse(value);
    if (limit == null) {
      return AppConstants.invalidLowStockLimit;
    }
    if (limit < AppConstants.minLowStockLimit) {
      return AppConstants.invalidLowStockLimit;
    }
    if (limit > AppConstants.maxLowStockLimit) {
      return AppConstants.invalidLowStockLimit;
    }
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthService>().currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Determine the final category value
      String finalCategory;
      if (_selectedCategory == 'Other') {
        finalCategory = _customCategoryController.text.trim();
      } else {
        finalCategory = _selectedCategory!;
      }

      final product = Product(
        userId: userId,
        name: _nameController.text.trim(),
        category: finalCategory,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        lowStockLimit: int.parse(_lowStockLimitController.text),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await _firestoreService.addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.productAdded),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        // Pop back with success result
        Navigator.pop(context, true);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
