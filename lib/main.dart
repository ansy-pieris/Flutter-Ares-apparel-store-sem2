import 'package:apparel_store/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:apparel_store/constants/app_theme.dart';
import 'package:apparel_store/screens/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apparel Store',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, 
      theme: AppTheme.lightTheme,   
      darkTheme: AppTheme.darkTheme, 
      home: SplashScreen(),
    );
  }
}
