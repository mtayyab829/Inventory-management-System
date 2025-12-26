import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../core/constants.dart';
import '../inventory/services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _notificationsEnabled = true; // Default to enabled

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            _buildProfileHeader(user),

            const SizedBox(height: AppConstants.paddingLarge),

            // Account Information
            _buildAccountInfo(user),

            const SizedBox(height: AppConstants.paddingLarge),

            // App Statistics
            _buildAppStats(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Settings
            _buildSettings(),

            const SizedBox(height: AppConstants.paddingLarge),

            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
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
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // User Name
          Text(
            user?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? 'No email',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(user) {
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
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            _buildInfoRow('Email', user?.email ?? 'Not available'),
            _buildInfoRow('Account Type', 'Email & Password'),
            _buildInfoRow('Member Since', _formatJoinDate(user?.metadata.creationTime)),
            _buildInfoRow('Last Sign In', _formatLastSignIn(user?.metadata.lastSignInTime)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppStats() {
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
              'Inventory Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppConstants.paddingMedium),

            FutureBuilder<Map<String, dynamic>>(
              future: _firestoreService.getInventoryStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Failed to load statistics',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final stats = snapshot.data ?? {};
                final totalProducts = stats['totalProducts'] ?? 0;
                final totalStock = stats['totalStock'] ?? 0;
                final lowStockProducts = stats['lowStockProducts'] ?? 0;
                final totalValue = stats['totalValue'] ?? 0.0;

                return Column(
                  children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                            'Total Products',
                            totalProducts.toString(),
                            Icons.inventory_2,
                    const Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: _buildStatItem(
                            'Total Stock',
                            totalStock.toString(),
                            Icons.warehouse,
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.paddingMedium),

                    Row(
                children: [
                        Expanded(
                          child: _buildStatItem(
                            'Low Stock Items',
                            lowStockProducts.toString(),
                            Icons.warning,
                            const Color(0xFFF59E0B),
                          ),
                  ),
                        const SizedBox(width: AppConstants.paddingMedium),
                  Expanded(
                          child: _buildStatItem(
                            'Inventory Value',
                            '\$${totalValue.toStringAsFixed(0)}',
                            Icons.attach_money,
                            const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingMedium),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'App Version',
                            AppConstants.appVersion,
                            Icons.info,
                            const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: _buildStatItem(
                            'Platform',
                            'Web',
                            Icons.web,
                            const Color(0xFF059669),
                    ),
                  ),
                ],
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

  Widget _buildSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Stock Alerts'),
            subtitle: const Text('Get notified when items are low in stock'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _showSuccessSnackBar(
                value ? 'Stock alerts enabled' : 'Stock alerts disabled'
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Data'),
            subtitle: const Text('Sync latest inventory data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _refreshData(),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and contact support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpDialog(),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('App version and information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _showLogoutConfirmation,
        icon: const Icon(Icons.logout),
        label: Text(_isLoading ? AppConstants.loggingIn : 'Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _logout(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    Navigator.pop(context); // Close dialog

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final error = await authService.signOut();

      setState(() => _isLoading = false);

      if (error != null) {
        _showErrorSnackBar(error);
      } else {
        _showSuccessSnackBar(AppConstants.logoutSuccess);
        // Navigation will be handled by AuthWrapper
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Logout failed: ${e.toString()}');
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    try {
      // Force refresh by triggering a rebuild of stats
      setState(() {});
      _showSuccessSnackBar('Data refreshed successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to refresh data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Start Guide:\n\n'
                '🏠 Dashboard: View inventory summary and recent activity\n\n'
                '📦 Inventory: Add, edit, and manage your products\n\n'
                '📊 Reports: View detailed analytics and statistics\n\n'
                '👤 Profile: Manage account settings and preferences\n\n'
                'For technical support, please contact the development team.',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2024 Inventory Pro Team',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A professional inventory management app built with Flutter and Firebase.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Features include:\n• Product management\n• Stock tracking\n• Real-time updates\n• User authentication\n• Dashboard analytics',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatLastSignIn(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }
}
