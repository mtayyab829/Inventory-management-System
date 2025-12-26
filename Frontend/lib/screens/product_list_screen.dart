import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = _firebaseService.getProductsStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddProduct(),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: AppConfig.paddingMedium),
                  Text(
                    'Error loading products',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppConfig.paddingSmall),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConfig.paddingLarge),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            slivers: [
              // Dashboard Stats
              SliverToBoxAdapter(
                child: _buildDashboard(products),
              ),

              // Low Stock Alert
              SliverToBoxAdapter(
                child: _buildLowStockAlert(products),
              ),

              // Products Grid
              SliverPadding(
                padding: const EdgeInsets.all(AppConfig.paddingMedium),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppConfig.gridCrossAxisCount,
                    crossAxisSpacing: AppConfig.gridSpacing,
                    mainAxisSpacing: AppConfig.gridSpacing,
                    childAspectRatio: AppConfig.gridAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _navigateToProductDetail(product),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddProduct(),
        tooltip: AppStrings.addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConfig.paddingLarge),
          Text(
            AppStrings.noProducts,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConfig.paddingSmall),
          Text(
            AppStrings.addFirstProduct,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConfig.paddingLarge),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddProduct(),
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addProduct),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(List<Product> products) {
    final totalProducts = products.length;
    final totalStock =
        products.fold<int>(0, (sum, product) => sum + product.quantity);
    final lowStockProducts =
        products.where((product) => product.isLowStock).length;
    final totalValue = products.fold<double>(
        0.0, (sum, product) => sum + (product.price * product.quantity));

    return Container(
      margin: const EdgeInsets.all(AppConfig.paddingMedium),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConfig.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      AppStrings.totalProducts,
                      totalProducts.toString(),
                      Icons.inventory,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppConfig.paddingSmall),
                  Expanded(
                    child: _buildStatCard(
                      AppStrings.totalStock,
                      totalStock.toString(),
                      Icons.storage,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.paddingSmall),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      AppStrings.lowStockProducts,
                      lowStockProducts.toString(),
                      Icons.warning,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppConfig.paddingSmall),
                  Expanded(
                    child: _buildStatCard(
                      AppStrings.totalValue,
                      '\$${totalValue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConfig.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlert(List<Product> products) {
    final lowStockProducts =
        products.where((product) => product.isLowStock).toList();

    if (lowStockProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConfig.paddingMedium),
      child: Card(
        color: AppColors.warning.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.warning),
                  const SizedBox(width: AppConfig.paddingSmall),
                  Text(
                    'Low Stock Alert',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppConfig.paddingSmall),
              Text(
                '${lowStockProducts.length} product(s) are running low on stock',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppConfig.paddingSmall),
              Wrap(
                spacing: AppConfig.paddingSmall,
                runSpacing: AppConfig.paddingSmall,
                children: lowStockProducts.map((product) {
                  return Chip(
                    label: Text('${product.name} (${product.quantity})'),
                    backgroundColor: AppColors.warning.withOpacity(0.2),
                    labelStyle: const TextStyle(color: AppColors.warning),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
