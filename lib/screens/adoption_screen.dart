import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdoptionAndFosterCareScreen extends StatefulWidget {
  const AdoptionAndFosterCareScreen({super.key});

  @override
  _AdoptionAndFosterCareScreenState createState() =>
      _AdoptionAndFosterCareScreenState();
}

class _AdoptionAndFosterCareScreenState
    extends State<AdoptionAndFosterCareScreen> {
  final DatabaseReference adoptAnimalRef =
      FirebaseDatabase.instance.ref().child('adopt_animal');
  List<Map<String, dynamic>> adoptableAnimals = [];

  @override
  void initState() {
    super.initState();
    _fetchAdoptableAnimals();
  }

  // Fetch the adoptable animals data from Firebase Realtime Database
  void _fetchAdoptableAnimals() {
    adoptAnimalRef.onValue.listen((DatabaseEvent event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      List<Map<String, dynamic>> tempAnimals = [];

      if (data != null) {
        data.forEach((key, value) {
          tempAnimals.add(Map<String, dynamic>.from(value));
        });
      }

      setState(() {
        adoptableAnimals = tempAnimals;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption & Foster Care'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: adoptableAnimals.isEmpty
          ? const Center(child: Text('No animals available for adoption yet.'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: adoptableAnimals.length,
              itemBuilder: (context, index) {
                return _buildAnimalCard(adoptableAnimals[index]);
              },
            ),
    );
  }

  // Build each card for an animal
  Widget _buildAnimalCard(Map<String, dynamic> animal) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              'https://via.placeholder.com/150', // Replace with actual image URL if available
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              animal['animalBreed'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(animal['animalDescription'] ?? 'No description available'),
          ElevatedButton(
            onPressed: () {
              // Handle apply for adoption action
              _applyForAdoption(animal);
            },
            child: const Text('Apply for Adoption'),
          ),
        ],
      ),
    );
  }

  void _applyForAdoption(Map<String, dynamic> animal) {
    // Handle the adoption application process
    // You can add navigation to a form or another screen here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Applied to adopt: ${animal['animalDescription'] ?? 'Animal'}')),
    );
  }
}
