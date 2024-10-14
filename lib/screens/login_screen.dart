import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'user_registration_screen.dart';
import 'volunteer_registration_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final String userType;

  const LoginScreen({Key? key, required this.userType}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailOrUsernameController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    // Check for saved login details if the user type is User or Volunteer
    if (widget.userType != 'Admin') {
      _loadLoginDetails();
    }
  }

  Future<void> _loadLoginDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginDetails = prefs.getString('login_details');

    if (loginDetails != null) {
      Map<String, dynamic> userData = jsonDecode(loginDetails);

      // Check if the userType matches to avoid filling in wrong user data
      if (userData['userType'] == widget.userType) {
        setState(() {
          emailOrUsernameController.text = userData['email'] ?? '';
          passwordController.text = userData['password'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login as ${widget.userType}'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email or Username Field
            TextField(
              controller: emailOrUsernameController,
              decoration: InputDecoration(
                labelText: widget.userType == 'Admin' ? 'Username' : 'Email',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Password Field
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            // Login Button
            ElevatedButton(
              onPressed: () {
                if (widget.userType == 'Admin') {
                  _loginAdmin();
                } else {
                  _loginUserOrVolunteer();
                }
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            // Registration Option for User/Volunteer
            if (widget.userType != 'Admin') ...[
              const Text("Not registered yet?"),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => widget.userType == 'User'
                          ? UserRegistrationScreen()
                          : VolunteerRegistrationScreen(),
                    ),
                  );
                },
                child: const Text('Register here'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _loginAdmin() async {
    try {
      // Authenticate using Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailOrUsernameController.text,
              password: passwordController.text);

      // After successful login, navigate to the Admin Dashboard
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors like invalid credentials, user not found, etc.
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No admin found for that email.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Wrong password provided for that user.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      }
    } catch (e) {
      // Handle other types of errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }

  // User/Volunteer Login Logic

  Future<void> _loginUserOrVolunteer() async {
    String node = widget.userType == 'User' ? 'users' : 'volunteers';
    final DatabaseReference userRef = databaseRef.child(node);
    print(node);
    try {
      // Query the database for the user with the given email
      final DataSnapshot snapshot = await userRef
          .orderByChild('email')
          .equalTo(emailOrUsernameController.text.trim())
          .get();

      if (snapshot.exists) {
        final usersData = snapshot.value as Map<dynamic, dynamic>;

        bool isAuthenticated = false;
        Map<String, dynamic> userData = {};

        usersData.forEach((key, value) {
          if (value['password'] == passwordController.text.trim()) {
            isAuthenticated = true;
            userData = {
              'id': key,
              'email': value['email'],
              'name': value['name'], // assuming name exists in the data
              'userType': widget.userType,
              'password': value['password'],
              'phone': value['phone']
            };
          }
        });

        if (isAuthenticated) {
          // Save user details in local storage
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString('login_details', jsonEncode(userData));

          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(widget.userType),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed')),
      );
    }
  }
}
