import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/environment_config.dart';
import 'core/config/firebase_bootstrap.dart';
import 'theme/app_theme.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/ewaste_provider.dart';
import 'providers/pickup_provider.dart';
import 'providers/rewards_provider.dart';
import 'providers/notifications_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';
import 'screens/submit_ewaste_screen.dart';
import 'screens/item_details_screen.dart';
import 'screens/pickup_dropoff_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/ewaste_passport_screen.dart';
import 'screens/impact_dashboard_screen.dart';
import 'screens/rewards_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/collection_points_screen.dart';

// Models (for route arguments)
import 'models/ewaste_item_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safe Firebase Bootstrap — gracefully handles missing google-services.json
  await FirebaseBootstrap.initialize();

  runApp(const Waste2ValueApp());
}

class Waste2ValueApp extends StatelessWidget {
  const Waste2ValueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EWasteProvider()),
        ChangeNotifierProvider(create: (_) => PickupProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: MaterialApp(
        title: EnvironmentConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const _AppRootGate(),
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  /// Centralized named-route generator
  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _fade(const LoginScreen());
      case '/register':
        return _fade(const RegisterScreen());
      case '/home':
        return _fade(const HomeScreen());
      case '/submit-ewaste':
        return _slide(const SubmitEWasteScreen());
      case '/item-details':
        final item = settings.arguments as EWasteItem?;
        if (item == null) return null;
        return _slide(ItemDetailsScreen(item: item));
      case '/pickup-dropoff':
        return _slide(const PickupDropoffScreen());
      case '/tracking':
        return _slide(const TrackingScreen());
      case '/ewaste-passport':
        final item = settings.arguments as EWasteItem?;
        if (item == null) return null;
        return _slide(EWastePassportScreen(item: item));
      case '/impact-dashboard':
        return _slide(const ImpactDashboardScreen());
      case '/rewards':
        return _slide(const RewardsScreen());
      case '/notifications':
        return _slide(const NotificationsScreen());
      case '/profile':
        return _slide(const ProfileScreen());
      case '/collection-points':
        return _slide(const CollectionPointsScreen());
      default:
        return null;
    }
  }

  static PageRoute _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRoute _slide(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}

// ─── Root Gate: Splash → Auth → Home ─────────────────────────────────────────

class _AppRootGate extends StatefulWidget {
  const _AppRootGate();

  @override
  State<_AppRootGate> createState() => _AppRootGateState();
}

class _AppRootGateState extends State<_AppRootGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(onComplete: () => setState(() => _splashDone = true));
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }
        return const _MainShell();
      },
    );
  }
}

// ─── Bottom Navigation Shell ──────────────────────────────────────────────────

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.add_circle_outline_rounded,
      selectedIcon: Icons.add_circle_rounded,
      label: 'Submit',
    ),
    _NavItem(
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping_rounded,
      label: 'Pickups',
    ),
    _NavItem(
      icon: Icons.eco_outlined,
      selectedIcon: Icons.eco_rounded,
      label: 'Impact',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  final List<Widget> _screens = const [
    HomeScreen(),
    SubmitEWasteScreen(),
    PickupDropoffScreen(),
    ImpactDashboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationsProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        indicatorColor: AppTheme.lightMint,
        backgroundColor: Colors.white,
        elevation: 3,
        destinations: _navItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          // Badge on home tab if unread notifications
          final Widget icon = (i == 0 && notifs.unreadCount > 0)
              ? Badge(
                  label: Text('${notifs.unreadCount}'),
                  child: Icon(item.icon),
                )
              : Icon(item.icon);

          return NavigationDestination(
            icon: icon,
            selectedIcon: Icon(item.selectedIcon,
                color: AppTheme.primaryGreen),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
