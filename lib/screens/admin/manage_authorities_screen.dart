import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ManageAuthoritiesScreen extends StatefulWidget {
  const ManageAuthoritiesScreen({super.key});

  @override
  _ManageAuthoritiesScreenState createState() =>
      _ManageAuthoritiesScreenState();
}

class _ManageAuthoritiesScreenState extends State<ManageAuthoritiesScreen> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref('volunteers');
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      // Fetch the users from the database
      DatabaseEvent event = await _database.once();
      DataSnapshot snapshot =
          event.snapshot; // Get the DataSnapshot from DatabaseEvent

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          users = data.entries.map((entry) {
            return {
              'id': entry.key,
              'email': entry.value['email'],
              'name': entry.value['name'],
              'phone':
                  entry.value['phone'] ?? 'N/A', // Handle missing phone numbers
              'password': entry.value['password'], // Store password
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          users = [];
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching users: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    TextEditingController nameController =
        TextEditingController(text: user['name']);
    TextEditingController emailController =
        TextEditingController(text: user['email']);
    TextEditingController phoneController =
        TextEditingController(text: user['phone'].toString());
    TextEditingController passwordController =
        TextEditingController(text: user['password']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update user data in Firebase
                final updatedUser = {
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'password': passwordController
                      .text, // Keep it in plain text or hash it as necessary
                };

                try {
                  await _database.child(user['id']).update(updatedUser);
                  Navigator.of(context).pop();
                  _fetchUsers(); // Refresh the list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User updated successfully!')),
                  );
                } catch (error) {
                  print('Error updating user: $error');
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Authorities'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(child: Text('No users found.'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(user['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user['email']}'),
                            Text('Phone: ${user['phone']}'),
                            Text(
                                'Password: ${user['password']}'), // Display the password
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editUser(user); // Call the edit user method
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
