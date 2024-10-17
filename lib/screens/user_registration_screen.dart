import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({Key? key}) : super(key: key);

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref('users'); // Realtime DB reference

  bool isLoading = false; // To show a loading state

  // Check if email already exists in the database
  Future<bool> _checkEmailExists(String email) async {
    final snapshot =
        await _database.orderByChild('email').equalTo(email).once();

    // If snapshot has data, email already exists
    return snapshot.snapshot.exists;
  }

  Future<void> _registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      setState(() {
        isLoading = true; // Set loading state to true
      });

      // Check if the email already exists
      bool emailExists = await _checkEmailExists(email);
      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Email already exists. Please use a different email.')),
        );
        setState(() {
          isLoading = false; // Reset loading state
        });
        return; // Exit the function, don't proceed with registration
      }

      // Prepare user data for registration
      final newUser = {
        'name': _nameController.text.trim(),
        'email': email,
        'password': _passwordController.text
            .trim(), // You should hash passwords in real apps
        'phone': _phoneController.text.trim(), // Include phone number
      };

      try {
        // Write user data to Firebase Realtime Database
        await _database.push().set(newUser);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User Registered!')),
        );
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        // Handle registration error
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration failed! Please try again.')),
        );
      } finally {
        setState(() {
          isLoading = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Please enter your 10 digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : () => _registerUser(context),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
