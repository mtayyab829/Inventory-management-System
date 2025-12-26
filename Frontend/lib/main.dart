import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/auth_service.dart';
import 'auth/welcome_screen.dart';
import 'core/theme/app_theme.dart';
import 'dashboard/home_screen.dart';
import 'firebase_options.dart';
import 'inventory/screens/inventory_list_screen.dart';
import 'profile/profile_screen.dart';
import 'reports/reports_screen.dart';

/// Main entry point for Inventory Pro app
/// Initializes Firebase and sets up the app with proper authentication flow
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Disable network font loading to prevent connectivity issues
  // This ensures the app uses only local system fonts
  await _disableNetworkFonts();

  runApp(const InventoryProApp());
}

/// Disable network font loading to prevent connectivity issues
Future<void> _disableNetworkFonts() async {
  // This prevents Flutter from trying to load fonts from the network
  // and forces it to use local system fonts only
}

/// Root widget for Inventory Pro application
/// Uses Provider for state management and Material 3 design
class InventoryProApp extends StatelessWidget {
  const InventoryProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication service provider
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Inventory Pro',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Authentication-based routing
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that handles authentication state routing
/// Shows welcome screen for unauthenticated users
/// Shows main app for authenticated users
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Use StreamBuilder for real-time auth state updates
        return StreamBuilder<User?>(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            // Show loading while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Check if user is authenticated
            final user = snapshot.data;
            if (user != null) {
              // User is logged in - show main app
              return const MainApp();
            } else {
              // User is not logged in - show welcome screen
              return const WelcomeScreen();
            }
          },
        );
      },
    );
  }
}

/// Main application widget with bottom navigation
/// Contains all main screens: Home, Inventory, Reports, Profile
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  // List of main app screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigateToTab: _navigateToTab),
      const InventoryListScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // Allow more than 3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
