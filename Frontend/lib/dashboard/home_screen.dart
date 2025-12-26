import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../core/constants.dart';
import '../inventory/services/firestore_service.dart';
import '../inventory/models/product_model.dart';
import '../inventory/screens/add_product_screen.dart';
import 'models/activity_model.dart';
import 'widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirestoreService _firestoreService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _authService.getUserDisplayName() ?? 'User';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Inventory Pro',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                    fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(userName),

              const SizedBox(height: AppConstants.paddingLarge),

              // Summary Cards
              StreamBuilder<List<Product>>(
                stream: _firestoreService.getUserProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCards();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorCards(snapshot.error.toString());
                  }

                  final products = snapshot.data ?? [];
                  final stats = _calculateStats(products);

                  return _buildSummaryCards(stats);
                },
              ),

              const SizedBox(height: AppConstants.paddingLarge),

              // Quick Actions
              _buildQuickActions(),

              const SizedBox(height: AppConstants.paddingLarge),

              // Recent Activity
              _buildRecentActivity(),

              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String userName) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waving_hand, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back to your inventory dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCards(String error) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            'Failed to load dashboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF7F1D1D)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Products',
                value: stats['totalProducts'].toString(),
                icon: Icons.inventory_2,
                color: const Color(0xFF1E88E5),
                subtitle: 'Items in inventory',
                onTap: () => _navigateToInventory(),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: SummaryCard(
                title: 'Total Stock',
                value: stats['totalStock'].toString(),
                icon: Icons.storage,
                color: const Color(0xFF4CAF50),
                subtitle: 'Units available',
                onTap: () => _showStockDetails(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Low Stock',
                value: stats['lowStockProducts'].toString(),
                icon: Icons.warning,
                color: const Color(0xFFF59E0B),
                subtitle: 'Need attention',
                onTap: () => _navigateToLowStock(),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: SummaryCard(
                title: 'Total Value',
                value: '\$${stats['totalValue'].toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: const Color(0xFF8B5CF6),
                subtitle: 'Inventory value',
                onTap: () => _showValueBreakdown(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Add Product',
                Icons.add_circle,
                const Color(0xFF4CAF50),
                () => _navigateToAddProduct(),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildQuickActionCard(
                'View Inventory',
                Icons.inventory,
                const Color(0xFF1E88E5),
                () => _navigateToInventory(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        StreamBuilder<List<Activity>>(
          stream: _firestoreService.getRecentActivitiesStream(limit: 5),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Text(
                          'Failed to load activities',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            final activities = snapshot.data ?? [];

            if (activities.isEmpty) {
              return Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.grey[50],
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: [
              Row(
                children: [
                        const Icon(Icons.info_outline,
                            color: Colors.grey, size: 20),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text(
                          'No recent activities',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                      'Your recent stock changes and product updates will appear here.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      border: index < activities.length - 1
                          ? Border(bottom: BorderSide(color: Colors.grey[100]!))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(activity.color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              activity.icon,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Color(activity.color),
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activity.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (activity.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  activity.subtitle!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          activity.formattedTimestamp,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[400],
                                  ),
              ),
            ],
          ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateStats(List<Product> products) {
    final totalProducts = products.length;
    final totalStock = products.fold<int>(
      0,
      (sum, product) => sum + product.quantity,
    );
    final lowStockProducts =
        products.where((product) => product.isLowStock).length;
    final totalValue = products.fold<double>(
      0.0,
      (sum, product) => sum + (product.price * product.quantity),
    );

    return {
      'totalProducts': totalProducts,
      'totalStock': totalStock,
      'lowStockProducts': lowStockProducts,
      'totalValue': totalValue,
    };
  }

  Future<void> _refreshData() async {
    // Refresh logic will be implemented when we have the firestore service
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  // Navigation methods for summary cards
  void _navigateToInventory() {
    // Switch to inventory tab (index 1)
    if (widget.onNavigateToTab != null) {
      widget.onNavigateToTab!(1); // Switch to inventory tab
    } else {
      // Fallback: show snackbar if callback not provided
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventory navigation not available'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToAddProduct() {
    // Navigate to add product screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    ).then((result) {
      // Refresh data when returning from add product screen
      if (result == true && mounted) {
        setState(() {});
      }
    });
  }

  void _showStockDetails() {
    // Show detailed stock information
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'This feature will show detailed stock breakdown by category and product type.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLowStock() {
    // Navigate to low stock items
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Low Stock Alert'),
        content: const Text(
          'Products with low stock will be highlighted in the inventory. '
          'Switch to the Inventory tab to view and manage them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showValueBreakdown() {
    // Show inventory value breakdown
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Value Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'This feature will show a detailed breakdown of your inventory value by category and product.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
