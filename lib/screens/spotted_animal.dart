import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SpottedAnimalsScreen extends StatefulWidget {
  const SpottedAnimalsScreen({super.key});

  @override
  _SpottedAnimalsScreenState createState() => _SpottedAnimalsScreenState();
}

class _SpottedAnimalsScreenState extends State<SpottedAnimalsScreen> {
  final DatabaseReference animalSpottedRef =
      FirebaseDatabase.instance.ref().child('animals_spotted');
  final DatabaseReference adoptAnimalRef =
      FirebaseDatabase.instance.ref().child('adopt_animal');
  List<Map<String, dynamic>> animalReports = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchAnimalReports();
  }

  // Fetch the animal spotted data from Firebase Realtime Database
  void _fetchAnimalReports() {
    animalSpottedRef.onValue.listen((DatabaseEvent event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      List<Map<String, dynamic>> tempReports = [];

      if (data != null) {
        data.forEach((key, value) {
          tempReports.add({
            'id': key, // Capture the key as the ID for deletion later
            ...Map<String, dynamic>.from(value)
          });
        });
      }

      setState(() {
        animalReports = tempReports;
      });
    });
  }

  // Allow user to upload or edit the image
  Future<void> _selectImage(String reportId) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(reportId, imageFile);
    }
  }

  // Upload the image to Firebase Storage and update the report
  Future<void> _uploadImage(String reportId, File imageFile) async {
    try {
      // Upload to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('animal_images/$reportId');
      await storageRef.putFile(imageFile);

      // Get the download URL
      final imageUrl = await storageRef.getDownloadURL();

      // Update the image URL in the report in Firebase Database
      await animalSpottedRef.child(reportId).update({'imageUrl': imageUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotted Animals'),
        centerTitle: true,
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: animalReports.isEmpty
          ? const Center(child: Text('No spotted animals reported yet.'))
          : ListView.builder(
              itemCount: animalReports.length,
              itemBuilder: (context, index) {
                return _buildAnimalCard(animalReports[index], context);
              },
            ),
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> report, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showLocationDialog(context, report);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the image on the right side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display text information
                    Text(
                      report['animalDescription'] ?? 'No description available',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Area: ${report['area'] ?? 'Unknown'}'),
                    const SizedBox(height: 4),
                    Text(
                        'Location: (${report['latitude']}, ${report['longitude']})'),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Space between text and image
              // Display the image
              report['imageUrl'] != "No Image"
                  ? Image.network(
                      report['imageUrl'],
                      height: 150, // Adjust height as needed
                      width: 100, // Set width for the image
                      fit: BoxFit.cover,
                    )
                  : const SizedBox(
                      height: 150,
                      width: 100, // Set width for the placeholder
                      child: Placeholder(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Animal Location'),
          content: SingleChildScrollView(
            // Add scrolling capability
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Description: ${report['animalDescription'] ?? 'N/A'}'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Type: ${report['animalType'] ?? 'Unknown'}'),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Breed: ${report['animalBreed'] ?? 'Unknown'}'),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Color: ${report['animalColor'] ?? 'Unknown'}'),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Area: ${report['area'] ?? 'N/A'}'),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Coordinates: (${report['latitude'] ?? 'N/A'}, ${report['longitude'] ?? 'N/A'})'),
                ),
                const SizedBox(height: 16),
                // Display the image with edit functionality
                report['imageUrl'] != "No Image"
                    ? Image.network(
                        report['imageUrl'],
                        height: 120, // Adjust height as needed
                        width: MediaQuery.of(context).size.width *
                            0.8, // Full width image
                        fit: BoxFit.cover,
                      )
                    : const Placeholder(
                        fallbackHeight: 150,
                      ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Image'),
                    onPressed: () {
                      _selectImage(report['id']); // Select new image
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _launchMaps(report['latitude'], report['longitude']);
              },
              child: const Text('Visit Location'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _markAsCaptured(report);
                Navigator.of(context).pop(); // Close the dialog after marking
              },
              child: const Text('Mark as Captured'),
            ),
          ],
        );
      },
    );
  }

  // Function to mark an animal as captured
  void _markAsCaptured(Map<String, dynamic> report) async {
    try {
      // Load the volunteer details from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? loginDetails = prefs.getString('login_details');

      if (loginDetails != null) {
        // Decode the login details to get volunteer info
        Map<String, dynamic> volunteerDetails = jsonDecode(loginDetails);

        // Add the volunteer's details to the report
        report['volunteer'] = {
          'name': volunteerDetails['name'] ?? 'Unknown Name',
          'email': volunteerDetails['email'] ?? 'Unknown Email',
          'phone': volunteerDetails['phone'] ?? 'Unknown Phone'
        };

        // Add the animal report to the 'adopt_animal' collection
        await adoptAnimalRef.push().set(report);

        // Remove the animal report from the 'animals_spotted' collection
        await animalSpottedRef.child(report['id']).remove();

        // Remove the item from the local list (animalReports) and update the UI
        setState(() {
          animalReports.removeWhere((element) => element['id'] == report['id']);
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal marked as captured!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No volunteer details found. Please log in.')),
        );
      }
    } catch (error) {
      // Handle any errors that might occur during the process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking animal as captured: $error')),
      );
    }
  }

  // Function to open Google Maps with the provided coordinates
  Future<void> _launchMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
