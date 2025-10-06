import 'package:apparel_store/screens/main_navigation.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Email Address",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter your email';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter your password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
