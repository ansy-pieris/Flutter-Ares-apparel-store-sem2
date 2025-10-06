import 'package:flutter/material.dart';
import 'package:apparel_store/screens/register_screen.dart';
import 'package:apparel_store/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Icon(Icons.shopping_bag, size: 80, color: iconColor),
            const SizedBox(height: 20),
            Text(
              "Welcome Back to ARES!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 30),
            const LoginForm(), 
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: Text(
                "Don't have an account? Register",
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
