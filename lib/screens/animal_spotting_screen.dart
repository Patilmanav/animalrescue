import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AnimalSpottingScreen extends StatefulWidget {
  const AnimalSpottingScreen({super.key});

  @override
  _AnimalSpottingScreenState createState() => _AnimalSpottingScreenState();
}

class _AnimalSpottingScreenState extends State<AnimalSpottingScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference animalSpottedRef =
      FirebaseDatabase.instance.ref().child('animals_spotted');

  // Using TextEditingController for form fields
  final TextEditingController _animalDescriptionController =
      TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _animalTypeController = TextEditingController();
  final TextEditingController _animalBreedController = TextEditingController();
  final TextEditingController _animalColorController = TextEditingController();

  String? _latitude;
  String? _longitude;
  bool isLoading = false;

  // Fetch live location
  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Submit form and save data in Firebase
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Prepare the data for Firebase
      Map<String, String?> spottedAnimalData = {
        'animalDescription': _animalDescriptionController.text,
        'area': _areaController.text,
        'animalType': _animalTypeController.text,
        'animalBreed': _animalBreedController.text.isEmpty
            ? 'Unknown'
            : _animalBreedController.text,
        'animalColor': _animalColorController.text.isEmpty
            ? 'Unknown'
            : _animalColorController.text,
        'latitude': _latitude ?? 'Not set',
        'longitude': _longitude ?? 'Not set',
      };

      // Store the data in Firebase Realtime Database
      animalSpottedRef.push().set(spottedAnimalData).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );

        // Reset the form
        _formKey.currentState!.reset();
        _animalDescriptionController.clear();
        _areaController.clear();
        _animalTypeController.clear();
        _animalBreedController.clear();
        _animalColorController.clear();

        setState(() {
          _latitude = null;
          _longitude = null;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $error')),
        );
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _animalDescriptionController.dispose();
    _areaController.dispose();
    _animalTypeController.dispose();
    _animalBreedController.dispose();
    _animalColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Spotting'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _animalDescriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Animal Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(labelText: 'Area'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the area.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _animalTypeController,
                  decoration: const InputDecoration(
                      labelText: 'Animal Type (e.g., Dog, Cat)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the animal type.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _animalBreedController,
                  decoration: const InputDecoration(
                      labelText: 'Animal Breed (if known)'),
                ),
                TextFormField(
                  controller: _animalColorController,
                  decoration: const InputDecoration(labelText: 'Animal Color'),
                ),
                const SizedBox(height: 20),
                const Text('Location:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Latitude: ${_latitude ?? 'Not set'}'),
                    Text('Longitude: ${_longitude ?? 'Not set'}'),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : _getCurrentLocation,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Fetch Live Location'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Report Animal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
