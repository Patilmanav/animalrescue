import 'package:animalrescue/screens/AnimalDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // for date formatting

class VolunteerAdoptedAnimalScreen extends StatefulWidget {
  const VolunteerAdoptedAnimalScreen({Key? key}) : super(key: key);

  @override
  _VolunteerAdoptedAnimalScreenState createState() =>
      _VolunteerAdoptedAnimalScreenState();
}

class _VolunteerAdoptedAnimalScreenState
    extends State<VolunteerAdoptedAnimalScreen> {
  DatabaseReference adoptAnimalRef =
      FirebaseDatabase.instance.ref().child('adopt_animal');

  List<Map<String, dynamic>> pendingAdoptedAnimals = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingAdoptedAnimals();
  }

  // Fetch animals with status 'PENDING' or 'ADOPTED'
  void _fetchPendingAdoptedAnimals() {
    adoptAnimalRef.onValue.listen((DatabaseEvent event) {
      final Map<dynamic, dynamic>? data =
          event.snapshot.value as Map<dynamic, dynamic>?;
      List<Map<String, dynamic>> tempAnimals = [];

      if (data != null) {
        data.forEach((key, value) {
          if (value['status'] == 'PENDING' || value['status'] == 'ADOPTED') {
            tempAnimals.add({
              'key': key,
              ...Map<String, dynamic>.from(value),
            });
          }
        });
      }

      if (mounted) {
        setState(() {
          pendingAdoptedAnimals = tempAnimals;
        });
      }
    });
  }

  // Update animal status in Firebase Realtime Database

  void _updateAnimalStatus(String key, String newStatus) {
    DatabaseReference animalRef = adoptAnimalRef.child(key);

    Map<String, dynamic> updates = {'status': newStatus};

    // If the status is 'ADOPTED', add the adoption date
    if (newStatus == 'ADOPTED') {
      String adoptionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      updates['adoptionDate'] = adoptionDate;
    }

    animalRef.update(updates).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animal status updated to $newStatus')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer - Adopted Animals'),
      ),
      body: pendingAdoptedAnimals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pendingAdoptedAnimals.length,
              itemBuilder: (context, index) {
                var animal = pendingAdoptedAnimals[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(animal['animalType'] ?? 'Unnamed Animal'),
                    subtitle: Text('Status: ${animal['status']}'),
                    trailing: animal['status'] == 'PENDING'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () {
                                  _updateAnimalStatus(animal['key'], 'ADOPTED');
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _updateAnimalStatus(
                                      animal['key'], 'NOT ADOPTED');
                                },
                              ),
                            ],
                          )
                        : null,
                    // Navigate to the AnimalDetailsScreen when tapped
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalDetailsScreen(
                            animalData: animal,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
