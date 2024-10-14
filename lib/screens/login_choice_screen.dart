import 'package:flutter/material.dart';
import 'login_screen.dart';
// import 'admin/admin_login_screen.dart'; // Import the admin login screen

class LoginChoiceScreen extends StatelessWidget {
  const LoginChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Login Type'),
        automaticallyImplyLeading: false, // This removes the back arrow

        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Adding a logo or header image (optional)
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Image.asset(
                  'assets/logo.jpg', // Replace with your logo
                  height: 120,
                ),
              ),
              _buildLoginButton(
                context,
                text: 'Login as Normal User',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(userType: 'User'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildLoginButton(
                context,
                text: 'Login as Volunteer',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(userType: 'Volunteer'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Adding the admin login option
              _buildLoginButton(
                context,
                text: 'Login as Admin',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(
                        userType: 'Admin',
                      ), // Admin login screen
                    ),
                  );
                },
                color: Colors.red, // Different color for admin
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context,
      {required String text, required VoidCallback onPressed, Color? color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor:
            color ?? Colors.green, // Default to green unless specified
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12), // Rounded corners for buttons
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
