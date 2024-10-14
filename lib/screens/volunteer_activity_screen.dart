import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerActivityScreen extends StatefulWidget {
  const VolunteerActivityScreen({super.key});

  @override
  _VolunteerActivityScreenState createState() =>
      _VolunteerActivityScreenState();
}

class _VolunteerActivityScreenState extends State<VolunteerActivityScreen> {
  String volunteerEmail = '';
  List<Map<String, dynamic>> adoptedAnimals = [];
  final DatabaseReference adoptAnimalRef =
      FirebaseDatabase.instance.ref('adopt_animal');

  @override
  void initState() {
    super.initState();
    _loadVolunteerEmail();
  }

  // Load volunteer email from SharedPreferences
  void _loadVolunteerEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginDetails = prefs.getString('login_details');

    if (loginDetails != null) {
      Map<String, dynamic> userData = jsonDecode(loginDetails);
      setState(() {
        volunteerEmail = userData['email'] ?? '';
        _fetchAdoptedAnimals(); // Fetch animals after loading email
      });
    } else {
      // Handle case where no email is available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading volunteer email')),
      );
    }
  }

  // Fetch adopted animals from Firebase and filter by volunteer email
  void _fetchAdoptedAnimals() async {
    try {
      // Fetch the adopt_animal collection from the database
      DatabaseEvent event = await adoptAnimalRef.once();
      DataSnapshot snapshot =
          event.snapshot; // Extract the snapshot from the event
      Map<dynamic, dynamic>? animalData = snapshot.value as Map?;

      if (animalData != null) {
        List<Map<String, dynamic>> filteredAnimals = [];

        animalData.forEach((key, value) {
          Map<String, dynamic> animalReport = Map<String, dynamic>.from(value);

          // Check if the volunteer's email matches the one from SharedPreferences
          if (animalReport['volunteer'] != null &&
              animalReport['volunteer']['email'] == volunteerEmail) {
            filteredAnimals.add(animalReport);
          }
        });

        // Update the UI with the filtered animals
        setState(() {
          adoptedAnimals = filteredAnimals;
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching animals: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Activity'),
      ),
      body: adoptedAnimals.isEmpty
          ? const Center(
              child: Text('No animals adopted yet.'),
            )
          : ListView.builder(
              itemCount: adoptedAnimals.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> animal = adoptedAnimals[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title:
                        Text(animal['animalDescription'] ?? 'Unknown Animal'),
                    subtitle: Text('Area: ${animal['area'] ?? 'Unknown'}'),
                    trailing: Text(animal['animalType'] ?? 'Unknown Type'),
                  ),
                );
              },
            ),
    );
  }
}
