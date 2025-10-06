import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

void _handleRegister() {
  if (_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration successful!')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context); 
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
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
            decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter a password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Confirm Password", border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Confirm your password';
              if (value != passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Register", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
