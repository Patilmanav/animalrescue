import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class AdoptionFormScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  const AdoptionFormScreen({required this.animal, Key? key}) : super(key: key);

  @override
  _AdoptionFormScreenState createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen> {
  String userName = 'Unknown User';
  String userEmail = 'Unknown Email';
  String userRole = 'user';
  String userPhone = '';
  String additionalPhoneNumber = '';

  // Rescue center data
  String rescueCenterAddress = '';

  // Declare TextEditingControllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchRescueCenterAddress();
  }

  // Load user data from local storage
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginDetails = prefs.getString('login_details');

    if (loginDetails != null) {
      Map<String, dynamic> userData = jsonDecode(loginDetails);
      setState(() {
        userName = userData['name'] ?? 'Unknown User';
        userEmail = userData['email'] ?? 'Unknown Email';
        userRole = userData['userType'] ?? 'user';
        userPhone = userData['phone'].toString();

        nameController.text = userName;
        emailController.text = userEmail;
        roleController.text = userRole;
        phoneController.text = userPhone;
      });
    }
  }

  // Fetch rescue center address from Firebase Realtime Database
  void _fetchRescueCenterAddress() {
    DatabaseReference rescueCenterRef =
        FirebaseDatabase.instance.ref().child('rescue_center');
    rescueCenterRef.once().then((DatabaseEvent event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        if (mounted) {
          setState(() {
            rescueCenterAddress =
                '${data['building']}, ${data['street']}, ${data['area']}, ${data['city']}, Postal Code: ${data['postalCode']}, Contact: ${data['contact']}';
          });
        }
      }
    });
  }

  void _updateAdoptAnimal(String animalId) async {
    DatabaseReference adoptAnimalRef =
        FirebaseDatabase.instance.ref().child('adopt_animal');

    // Fetch all animals from the adopt_animal collection
    adoptAnimalRef.once().then((DatabaseEvent event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        // Iterate through the data to find the document with the matching animal ID
        for (var entry in data.entries) {
          if (entry.value['id'] == animalId) {
            // Found the document with the matching animal ID
            DatabaseReference documentRef = adoptAnimalRef.child(entry.key);

            // Create an update map for the new status
            Map<String, dynamic> updateData = {
              'status': 'PENDING',
              // You can add any other fields you want to retain/update if necessary
            };

            // Update the document with the new data
            documentRef.update(updateData).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Animal details updated successfully!')),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update: $error')),
              );
            });

            // Exit the loop once we've found and updated the document
            break;
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No animals found.')),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching animals: $error')),
      );
    });
  }

  // Save adoption details to Firebase Realtime Database
  void _saveAdoptionDetails() {
    DatabaseReference adoptedAnimalRef =
        FirebaseDatabase.instance.ref().child('adopted_animal');

    // Create adoption entry
    Map<String, dynamic> adoptionData = {
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'additionalPhoneNumber': additionalPhoneNumber,
      'animalId': widget.animal['id'],
      'status': "PENDING",
    };
    print(adoptionData);
    adoptedAnimalRef.push().set(adoptionData).then((_) {
      _updateAdoptAnimal(widget.animal['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Adoption request submitted successfully!')),
      );
      // Navigator.pop(context); // Return to previous screen after submission
      _showReminderDialog();
    });
  }

  // Function to show a dialog reminding the user to visit the store
  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reminder'),
          content: const Text(
            'Please remember to visit the store within 15 days. '
            'Otherwise, the pet will be added back to the adoption list.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(
                    context); // Return to previous screen after submission
              },
              child: const Text('OK'),
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
        title: const Text('Adoption Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Name field (non-editable)
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        enabled: false, // Disable editing
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      // Email field (non-editable)
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        enabled: false, // Disable editing
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        enabled: false, // Disable editing
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      // Role field (non-editable)
                      TextFormField(
                        controller: roleController,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        enabled: false, // Disable editing
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Additional Phone Number field
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Contact Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Additional Phone Number',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            additionalPhoneNumber = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Rescue Center Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rescue Center Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please note: Delivery is not available. You need to visit our center.',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Address:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        rescueCenterAddress,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveAdoptionDetails,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 40.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Submit Adoption Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
