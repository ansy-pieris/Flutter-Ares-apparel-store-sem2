import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoFadeIn;

  late AnimationController _textController;
  late Animation<Offset> _textSlideIn;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _logoFadeIn = Tween<double>(begin: 0, end: 2).animate(_logoController);

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textSlideIn = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _logoController.forward().then((_) => _textController.forward());

    // Navigation is now handled by main.dart based on _isInitialized state
    // No need for manual navigation here
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoPath =
        isDark
            ? 'assets/images/Logo.png' // logo that appers in dark mode
            : 'assets/images/Logo_black.png'; // logo that apears in light mode

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFadeIn,
              child: SizedBox(
                width: 160,
                height: 160,
                child: Image.asset(
                  logoPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: isDark ? Colors.white : Colors.black,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: _textSlideIn,
              child: Text(
                'Welcome to ARES',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 40),
            Text(
              'Unleash Your Inner Warrior.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
