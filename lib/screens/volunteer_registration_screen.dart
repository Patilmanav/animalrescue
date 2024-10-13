import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VolunteerRegistrationScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();

  VolunteerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Registration'),
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
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _skillsController,
                decoration:
                    const InputDecoration(labelText: 'Skills/Interests'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your skills or interests';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Inside your form submission method
                    print("Validated");

                    // Create a reference to the 'approve_volunteers' collection in Realtime Database
                    DatabaseReference ref =
                        FirebaseDatabase.instance.ref("approve_volunteers");

                    // Save the data to Realtime Database
                    await ref.push().set({
                      'name': _nameController.text,
                      'email': _emailController.text,
                      'phone': _phoneController.text,
                      'skills': _skillsController.text,
                      'status': 'Not Approved', // Status set to 'Not Approved'
                      'timestamp': ServerValue
                          .timestamp, // Optional: timestamp when the data is saved
                    });

                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Volunteer Registered!')));

                    // Go back to the previous screen
                    Navigator.pop(context);
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
