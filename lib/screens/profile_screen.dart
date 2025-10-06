import 'package:apparel_store/screens/login_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    
    final String userName = 'Ansy Pieris';
    final String email = 'ansypieris@gmai.com';
    final String phone = '+94 71 244 4528';
    final String profileImage = 'assets/images/Ares.jpg';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ), 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(profileImage),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: TextStyle(color: textColor.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                  
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      backgroundColor: isDark ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      );
                    },

                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
