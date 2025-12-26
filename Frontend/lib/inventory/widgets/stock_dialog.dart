import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../widgets/custom_button.dart';
import '../models/product_model.dart';

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
    final icon = widget.isStockIn ? Icons.add_circle : Icons.remove_circle;
    final color = widget.isStockIn ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final actionText = widget.isStockIn ? 'add to' : 'remove from';

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current stock info
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current stock: ${widget.product.quantity} units',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            // Quantity input
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity to $actionText stock',
                  prefixIcon: Icon(icon, color: color),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(color: color, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateQuantity,
                autofocus: true,
              ),
            ),

            const SizedBox(height: AppConstants.paddingSmall),

            // Preview of result
            if (_quantityController.text.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getPreviewText(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        CustomButton(
          text: 'Confirm',
          backgroundColor: color,
          onPressed: _confirm,
        ),
      ],
    );
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.requiredField;
    }

    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Please enter a valid quantity greater than 0';
    }

    if (!widget.isStockIn && quantity > widget.product.quantity) {
      return AppConstants.insufficientStock;
    }

    return null;
  }

  String _getPreviewText() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final newQuantity = widget.isStockIn
        ? widget.product.quantity + quantity
        : widget.product.quantity - quantity;

    return widget.isStockIn
        ? 'Stock will increase to $newQuantity units'
        : 'Stock will decrease to $newQuantity units';
  }

  void _confirm() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      widget.onConfirm(quantity);
      Navigator.pop(context);
    }
  }
}
