import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../inventory/models/product_model.dart';
import '../inventory/services/firestore_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Text(
                'Inventory Reports',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Comprehensive overview of your inventory performance',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Inventory Overview
              _buildInventoryOverview(),

              const SizedBox(height: AppConstants.paddingLarge),

              // Top Products
              _buildTopProducts(),

              const SizedBox(height: AppConstants.paddingLarge),

              // Low Stock Alerts
              _buildLowStockAlerts(),

              const SizedBox(height: AppConstants.paddingLarge),

              // Recent Activities Summary
              _buildRecentActivitiesSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryOverview() {
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
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Inventory Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getUserProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading data',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  );
                }

                final products = snapshot.data ?? [];
                final stats = _calculateStats(products);

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Products',
                            stats['totalProducts'].toString(),
                            Icons.inventory_2,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: _buildStatCard(
                            'Total Stock',
                            stats['totalStock'].toString(),
                            Icons.warehouse,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Low Stock Items',
                            stats['lowStockProducts'].toString(),
                            Icons.warning,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: _buildStatCard(
                            'Out of Stock',
                            stats['outOfStockProducts'].toString(),
                            Icons.error,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    _buildStatCard(
                      'Total Inventory Value',
                      '\$${stats['totalValue'].toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.purple,
                      fullWidth: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts() {
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
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber[600],
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Top Products by Value',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getUserProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading products',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Text(
                        'No products found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  );
                }

                // Sort by value (price * quantity) descending
                final sortedProducts = List<Product>.from(products)
                  ..sort((a, b) =>
                      (b.price * b.quantity).compareTo(a.price * a.quantity));

                final topProducts = sortedProducts.take(5).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topProducts.length,
                  itemBuilder: (context, index) {
                    final product = topProducts[index];
                    final value = product.price * product.quantity;

                    return Container(
                      margin: const EdgeInsets.only(
                          bottom: AppConstants.paddingSmall),
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  product.category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${value.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${product.quantity} units',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlerts() {
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
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.orange[600],
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Low Stock Alerts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getUserProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading products',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  );
                }

                final products = snapshot.data ?? [];
                final lowStockProducts =
                    products.where((product) => product.isLowStock).toList();

                if (lowStockProducts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[600],
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: Text(
                            'All products are well stocked! 🎉',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lowStockProducts.length,
                  itemBuilder: (context, index) {
                    final product = lowStockProducts[index];

                    return Container(
                      margin: const EdgeInsets.only(
                          bottom: AppConstants.paddingSmall),
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.orange[600],
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange[800],
                                      ),
                                ),
                                Text(
                                  'Current: ${product.quantity} units (Limit: ${product.lowStockLimit})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.orange[700],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Low Stock',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSummary() {
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
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Recent Activity Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getActivitySummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading activity summary',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  );
                }

                final summary = snapshot.data ?? [];

                if (summary.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      child: Text(
                        'No recent activities',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  );
                }

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppConstants.paddingMedium,
                  crossAxisSpacing: AppConstants.paddingMedium,
                  children: summary.map((item) {
                    return Container(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        border:
                            Border.all(color: item['color'].withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['count'].toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: item['color'],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: item['color'].withOpacity(0.8),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  Map<String, dynamic> _calculateStats(List<Product> products) {
    final totalProducts = products.length;
    final totalStock =
        products.fold<int>(0, (sum, product) => sum + product.quantity);
    final lowStockProducts =
        products.where((product) => product.isLowStock).length;
    final outOfStockProducts =
        products.where((product) => product.quantity <= 0).length;
    final totalValue = products.fold<double>(
        0.0, (sum, product) => sum + (product.price * product.quantity));

    return {
      'totalProducts': totalProducts,
      'totalStock': totalStock,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'totalValue': totalValue,
    };
  }

  Future<List<Map<String, dynamic>>> _getActivitySummary() async {
    try {
      final activities = await _firestoreService.getRecentActivities(limit: 50);

      // Count activities by type
      final typeCounts = <String, int>{};
      for (final activity in activities) {
        typeCounts[activity.type] = (typeCounts[activity.type] ?? 0) + 1;
      }

      final summary = <Map<String, dynamic>>[];

      if (typeCounts.containsKey('product_added')) {
        summary.add({
          'label': 'Products Added',
          'count': typeCounts['product_added'],
          'color': Colors.green,
        });
      }

      if (typeCounts.containsKey('stock_changed')) {
        final stockChanges =
            activities.where((a) => a.type == 'stock_changed').toList();
        final stockIn =
            stockChanges.where((a) => (a.quantityChange ?? 0) > 0).length;
        final stockOut =
            stockChanges.where((a) => (a.quantityChange ?? 0) < 0).length;

        if (stockIn > 0) {
          summary.add({
            'label': 'Stock In',
            'count': stockIn,
            'color': Colors.blue,
          });
        }

        if (stockOut > 0) {
          summary.add({
            'label': 'Stock Out',
            'count': stockOut,
            'color': Colors.orange,
          });
        }
      }

      if (typeCounts.containsKey('product_updated')) {
        summary.add({
          'label': 'Products Updated',
          'count': typeCounts['product_updated'],
          'color': Colors.purple,
        });
      }

      if (typeCounts.containsKey('product_deleted')) {
        summary.add({
          'label': 'Products Deleted',
          'count': typeCounts['product_deleted'],
          'color': Colors.red,
        });
      }

      return summary;
    } catch (e) {
      print('Error getting activity summary: $e');
      return [];
    }
  }
}
