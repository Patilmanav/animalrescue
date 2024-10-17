import 'package:animalrescue/screens/adoptionform_screen.dart';
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
  final DatabaseReference adoptedAnimalRef =
      FirebaseDatabase.instance.ref().child('adopted_animal');
  final DatabaseReference rescueCenterRef =
      FirebaseDatabase.instance.ref().child('rescue_center');

  List<Map<String, dynamic>> adoptableAnimals = [];
  String rescueCenterAddress = 'Fetching address...';

  @override
  void initState() {
    super.initState();
    _fetchAdoptableAnimals();
    _fetchRescueCenterAddress();
  }

  // Fetch the adoptable animals data from Firebase Realtime Database
  void _fetchAdoptableAnimals() {
    adoptAnimalRef.onValue.listen((DatabaseEvent event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      List<Map<String, dynamic>> tempAnimals = [];

      if (data != null) {
        data.forEach((key, value) {
          // Filter out animals with status "PENDING" or "ADOPTED"
          if (value['status'] != 'PENDING' && value['status'] != 'ADOPTED') {
            tempAnimals.add(Map<String, dynamic>.from(value));
          }
        });
      }

      // Only update the state if mounted to prevent the setState() after dispose error
      if (mounted) {
        setState(() {
          adoptableAnimals = tempAnimals;
        });
      }
    });
  }

  // Fetch the rescue center address from Firebase Realtime Database
  void _fetchRescueCenterAddress() async {
    DataSnapshot snapshot = await rescueCenterRef.child('address').get();
    if (snapshot.exists) {
      setState(() {
        rescueCenterAddress = snapshot.value.toString();
      });
    } else {
      setState(() {
        rescueCenterAddress = 'Address not available.';
      });
    }
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
              animal['imageUrl'] ??
                  'https://via.placeholder.com/150', // Replace with actual image URL
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              animal['animalType'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(animal['animalBreed'] ?? 'No description available'),
          ElevatedButton(
            onPressed: () {
              // Display the adoption form
              _applyForAdoption(animal);
            },
            child: const Text('Apply for Adoption'),
          ),
        ],
      ),
    );
  }

  void _applyForAdoption(Map<String, dynamic> animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdoptionFormScreen(animal: animal),
      ),
    );
  }
}
