import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              // Product Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getCategoryColor(),
                  size: 24,
                ),
              ),

              const SizedBox(width: AppConstants.paddingMedium),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Price and Quantity
                    Row(
                      children: [
                        Text(
                          product.formattedPrice,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Text(
                          'Qty: ${product.quantity}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppConstants.paddingMedium),

              // Stock Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.stockStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: product.stockStatusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      product.stockStatus,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: product.stockStatusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  if (product.isLowStock) ...[
                    const SizedBox(height: 4),
                    Icon(
                      Icons.warning,
                      color: product.stockStatusColor,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    // Generate consistent colors based on category name
    final hash = product.category.hashCode;
    final colors = [
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFF59E0B), // Orange
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEF4444), // Red
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF84CC16), // Lime
      const Color(0xFFF97316), // Orange Red
    ];

    return colors[hash.abs() % colors.length];
  }

  IconData _getCategoryIcon() {
    final category = product.category.toLowerCase();

    if (category.contains('electronic') || category.contains('phone') || category.contains('computer')) {
      return Icons.devices;
    } else if (category.contains('cloth') || category.contains('fashion') || category.contains('wear')) {
      return Icons.checkroom;
    } else if (category.contains('food') || category.contains('drink') || category.contains('beverage')) {
      return Icons.restaurant;
    } else if (category.contains('book') || category.contains('education')) {
      return Icons.menu_book;
    } else if (category.contains('home') || category.contains('garden') || category.contains('furniture')) {
      return Icons.home;
    } else if (category.contains('sport') || category.contains('fitness')) {
      return Icons.sports_soccer;
    } else if (category.contains('health') || category.contains('beauty') || category.contains('care')) {
      return Icons.spa;
    } else if (category.contains('auto') || category.contains('car') || category.contains('vehicle')) {
      return Icons.directions_car;
    } else {
      return Icons.inventory_2;
    }
  }
}
