import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// Import screens
import 'screens/splash_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';

// Import constants and themes
import 'constants/app_theme.dart';

// Import providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/navigation_provider.dart';

// Import widgets
import 'widgets/network_status_widget.dart';

/// Main entry point of the ARES Apparel Store application
///
/// This 2nd-semester Flutter app demonstrates:
/// - State management using Provider pattern
/// - Material 3 theming with light/dark mode support
/// - Master/detail navigation patterns
/// - Device capabilities integration (sensors, network, location)
/// - Comprehensive form handling with validation
/// - Smooth animations and micro-interactions
/// - Offline capability detection and messaging
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (optional - allows both portrait and landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style for better integration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

/// Root application widget with comprehensive provider setup
///
/// Implements MultiProvider to manage all app state:
/// - AuthProvider: User authentication and profile management
/// - ThemeProvider: Light/dark theme switching with system integration
/// - CartProvider: Shopping cart state and operations
/// - ProductProvider: Product catalog and master/detail management
/// - NavigationProvider: Bottom navigation and routing state
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication provider - manages login state and user data
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // Theme provider - manages light/dark mode and system theme detection
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..initializeThemeState(),
        ),

        // Cart provider - manages shopping cart items and operations
        ChangeNotifierProvider(create: (context) => CartProvider()),

        // Product provider - manages product catalog and filtering
        ChangeNotifierProvider(create: (context) => ProductProvider()),

        // Navigation provider - manages bottom navigation state
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],

      // Consumer to rebuild when theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            // App configuration
            title: 'ARES Apparel Store',
            debugShowCheckedModeBanner: false,

            // Theme configuration with provider integration
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // Navigation configuration
            home: const NetworkStatusWidget(child: AppHome()),

            // App-wide builder for consistent theming
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scaling is accessible but controlled
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(
                    context,
                  ).textScaleFactor.clamp(0.8, 1.3),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

/// Home widget that manages the initial app state and routing
///
/// Determines whether to show splash screen or main navigation
/// based on app initialization status
class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  bool _isInitialized = false;
  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app providers and data
  ///
  /// This method ensures all providers are properly initialized
  /// before showing the main navigation
  Future<void> _initializeApp() async {
    try {
      // Record start time to ensure minimum splash duration
      final startTime = DateTime.now();

      // Initialize providers that need async setup
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      // Wait for all async initializations to complete
      await Future.wait([
        authProvider.initializeAuthState(),
        themeProvider.initializeThemeState(),
      ]);

      // Initialize cart if user is logged in
      if (authProvider.isLoggedIn) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.initializeCart();
        debugPrint('✅ Cart initialized for logged-in user');
      }

      // Initialize product data
      productProvider.initializeProducts();

      // Ensure minimum splash screen duration of 2.5 seconds
      final elapsedTime = DateTime.now().difference(startTime);
      const minSplashDuration = Duration(milliseconds: 2500);

      if (elapsedTime < minSplashDuration) {
        await Future.delayed(minSplashDuration - elapsedTime);
      }

      // Mark app as initialized
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (error) {
      // Handle initialization errors gracefully
      debugPrint('App initialization error: $error');

      // Ensure minimum splash duration even on error
      await Future.delayed(const Duration(milliseconds: 2000));

      // Still proceed to main app even if some initialization fails
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen during initialization
    if (!_isInitialized) {
      return const SplashScreen();
    }

    // Check authentication state and route accordingly
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('=== NAVIGATION DECISION ===');
        debugPrint('isInitialized: ${authProvider.isInitialized}');
        debugPrint('isLoggedIn: ${authProvider.isLoggedIn}');
        debugPrint('userEmail: ${authProvider.userEmail}');

        // Check if user just logged in (state change from logged out to logged in)
        if (authProvider.isLoggedIn && !_wasLoggedIn) {
          _wasLoggedIn = true;
          // Initialize cart when user logs in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cartProvider = Provider.of<CartProvider>(
              context,
              listen: false,
            );
            cartProvider
                .initializeCart()
                .then((_) {
                  debugPrint('✅ Cart initialized after login state change');
                })
                .catchError((error) {
                  debugPrint('❌ Failed to initialize cart after login: $error');
                });
          });
        } else if (!authProvider.isLoggedIn && _wasLoggedIn) {
          // User logged out, clear the flag
          _wasLoggedIn = false;
        }

        // Wait for auth provider to be initialized
        if (!authProvider.isInitialized) {
          debugPrint('SHOWING: SplashScreen (not initialized)');
          return const SplashScreen();
        }

        // Show login screen if user is not authenticated
        if (!authProvider.isLoggedIn) {
          debugPrint('SHOWING: LoginScreen (not logged in)');
          return const LoginScreen();
        }

        // Show main navigation if user is authenticated
        debugPrint('SHOWING: MainNavigation (user is logged in)');
        return const MainNavigation();
      },
    );
  }
}
