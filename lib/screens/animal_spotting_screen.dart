import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AnimalSpottingScreen extends StatefulWidget {
  const AnimalSpottingScreen({super.key});

  @override
  _AnimalSpottingScreenState createState() => _AnimalSpottingScreenState();
}

class _AnimalSpottingScreenState extends State<AnimalSpottingScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference animalSpottedRef =
      FirebaseDatabase.instance.ref().child('animals_spotted');
  final FirebaseStorage storage = FirebaseStorage.instance;

  final TextEditingController _animalDescriptionController =
      TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _animalTypeController = TextEditingController();
  final TextEditingController _animalBreedController = TextEditingController();
  final TextEditingController _animalColorController = TextEditingController();

  String? _latitude;
  String? _longitude;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool isLoading = false;

// Function to request camera and storage permissions
  Future<bool> _requestPermissions() async {
    // Request camera permission
    PermissionStatus cameraStatus = await Permission.camera.request();

    // Check if the platform is Android and the API level is 30 or above
    bool isAndroid11OrAbove =
        Platform.isAndroid && (await getAndroidVersion()) >= 30;

    PermissionStatus storageStatus;

    if (isAndroid11OrAbove) {
      // Request Manage External Storage permission for Android 11 and above
      storageStatus = await Permission.manageExternalStorage.request();
    } else {
      // Request storage permission (for Android 10 and below)
      storageStatus = await Permission.storage.request();
    }

    if (cameraStatus.isGranted &&
        (isAndroid11OrAbove
            ? storageStatus.isGranted
            : storageStatus.isGranted)) {
      return true;
    } else {
      return false;
    }
  }

// Helper function to get Android version
  Future<int> getAndroidVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo; // Use the alias here
    return androidInfo.version.sdkInt; // Returns the SDK version
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and storage permission required')),
      );
      return;
    }

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // Function to upload image to Firebase Storage
  Future<void> _uploadImage(File image) async {
    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        storage.ref().child('spotted_animals/$imageName.jpg');

    try {
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        _uploadedImageUrl = await snapshot.ref.getDownloadURL();
        print('Image uploaded successfully: $_uploadedImageUrl');
      } else {
        throw Exception('Upload failed: ${snapshot.state}');
      }
    } catch (e) {
      print('Error during image upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

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
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // If image is selected, upload it
      if (_selectedImage != null) {
        await _uploadImage(_selectedImage!);
      }

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
        'imageUrl': _uploadedImageUrl ?? 'No Image',
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
          _selectedImage = null;
          _uploadedImageUrl = null;
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Capture Image'),
                ),
                const SizedBox(height: 10),
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 150,
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
