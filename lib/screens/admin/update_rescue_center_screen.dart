import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UpdateRescueCenterScreen extends StatefulWidget {
  const UpdateRescueCenterScreen({super.key});

  @override
  _UpdateRescueCenterScreenState createState() =>
      _UpdateRescueCenterScreenState();
}

class _UpdateRescueCenterScreenState extends State<UpdateRescueCenterScreen> {
  // Controllers for each input field
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _contactController =
      TextEditingController(); // For admin contact

  final DatabaseReference _dbRef = FirebaseDatabase.instance
      .ref()
      .child('rescue_center'); // Reference to the 'rescue_center' node

  @override
  void dispose() {
    _areaController.dispose();
    _buildingController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  // Function to save the new address to Firebase
  void _saveAddress() async {
    String area = _areaController.text.trim();
    String building = _buildingController.text.trim();
    String street = _streetController.text.trim();
    String city = _cityController.text.trim();
    String postalCode = _postalCodeController.text.trim();
    String contact = _contactController.text.trim();

    if (area.isNotEmpty &&
        building.isNotEmpty &&
        street.isNotEmpty &&
        city.isNotEmpty &&
        postalCode.isNotEmpty &&
        contact.isNotEmpty) {
      try {
        // Update the rescue center's address in Firebase
        await _dbRef.update({
          'area': area,
          'building': building,
          'street': street,
          'city': city,
          'postalCode': postalCode,
          'contact': contact, // Admin contact details
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rescue Center Address Updated!')),
        );

        // Clear the input fields
        _areaController.clear();
        _buildingController.clear();
        _streetController.clear();
        _cityController.clear();
        _postalCodeController.clear();
        _contactController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Rescue Center Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _buildingController,
                decoration: const InputDecoration(
                  labelText: 'Building Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Admin Contact',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAddress,
                child: const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
