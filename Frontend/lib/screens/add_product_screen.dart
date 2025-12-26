import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  // Form controllers
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockLimitController = TextEditingController();

  // Focus nodes for better UX
  final _nameFocus = FocusNode();
  final _categoryFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _quantityFocus = FocusNode();
  final _lowStockLimitFocus = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _lowStockLimitController.dispose();
    _nameFocus.dispose();
    _categoryFocus.dispose();
    _priceFocus.dispose();
    _quantityFocus.dispose();
    _lowStockLimitFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addProduct),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConfig.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      decoration: const InputDecoration(
                        labelText: AppStrings.productName,
                        hintText: AppStrings.enterProductName,
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_categoryFocus);
                      },
                      validator: _validateProductName,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppConfig.paddingMedium),

                    // Category
                    TextFormField(
                      controller: _categoryController,
                      focusNode: _categoryFocus,
                      decoration: const InputDecoration(
                        labelText: AppStrings.category,
                        hintText: AppStrings.enterCategory,
                        prefixIcon: Icon(Icons.category),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocus);
                      },
                      validator: _validateCategory,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppConfig.paddingMedium),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      focusNode: _priceFocus,
                      decoration: const InputDecoration(
                        labelText: AppStrings.price,
                        hintText: AppStrings.enterPrice,
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: '\$',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_quantityFocus);
                      },
                      validator: _validatePrice,
                    ),
                    const SizedBox(height: AppConfig.paddingMedium),

                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      focusNode: _quantityFocus,
                      decoration: const InputDecoration(
                        labelText: AppStrings.quantity,
                        hintText: AppStrings.enterQuantity,
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_lowStockLimitFocus);
                      },
                      validator: _validateQuantity,
                    ),
                    const SizedBox(height: AppConfig.paddingMedium),

                    // Low Stock Limit
                    TextFormField(
                      controller: _lowStockLimitController,
                      focusNode: _lowStockLimitFocus,
                      decoration: const InputDecoration(
                        labelText: AppStrings.lowStockLimit,
                        hintText: AppStrings.enterLowStockLimit,
                        prefixIcon: Icon(Icons.warning),
                        helperText: 'Alert when stock falls below this number',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveProduct(),
                      validator: _validateLowStockLimit,
                    ),
                    const SizedBox(height: AppConfig.paddingLarge),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        child: const Text(AppStrings.save),
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
      return ValidationMessages.requiredField;
    }
    if (value.trim().length < AppConfig.minProductNameLength) {
      return ValidationMessages.invalidProductName;
    }
    if (value.trim().length > AppConfig.maxProductNameLength) {
      return ValidationMessages.invalidProductName;
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.requiredField;
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.requiredField;
    }
    final price = double.tryParse(value);
    if (price == null) {
      return ValidationMessages.invalidPrice;
    }
    if (price <= 0) {
      return ValidationMessages.invalidPrice;
    }
    if (price > 999999.99) {
      return ValidationMessages.priceTooHigh;
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.requiredField;
    }
    final quantity = int.tryParse(value);
    if (quantity == null) {
      return ValidationMessages.invalidQuantity;
    }
    if (quantity < AppConfig.minQuantity) {
      return ValidationMessages.invalidQuantity;
    }
    if (quantity > AppConfig.maxQuantity) {
      return ValidationMessages.quantityTooHigh;
    }
    return null;
  }

  String? _validateLowStockLimit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.requiredField;
    }
    final limit = int.tryParse(value);
    if (limit == null) {
      return ValidationMessages.invalidLowStockLimit;
    }
    if (limit < AppConfig.minLowStockLimit) {
      return ValidationMessages.invalidLowStockLimit;
    }
    if (limit > AppConfig.maxLowStockLimit) {
      return ValidationMessages.invalidLowStockLimit;
    }
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = Product(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        lowStockLimit: int.parse(_lowStockLimitController.text),
      );

      await _firebaseService.addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.productAdded),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
