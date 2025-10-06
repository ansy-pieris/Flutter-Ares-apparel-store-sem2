import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
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
    _textSlideIn = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _logoController.forward().then((_) => _textController.forward());

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
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
    final logoPath = isDark
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
              child: Image.asset(logoPath, width: 160, height: 160),
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
            CircularProgressIndicator(color: isDark ? Colors.white : Colors.black),
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
