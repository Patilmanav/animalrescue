import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ApprovedVolunteersScreen extends StatefulWidget {
  @override
  _ApprovedVolunteersScreenState createState() =>
      _ApprovedVolunteersScreenState();
}

class _ApprovedVolunteersScreenState extends State<ApprovedVolunteersScreen> {
  final DatabaseReference volunteersRef =
      FirebaseDatabase.instance.ref().child('approve_volunteers');

  List<Map<String, String>> approvedVolunteers = [];

  @override
  void initState() {
    super.initState();
    _fetchApprovedVolunteers();
  }

  // Fetch approved volunteers from the database
  void _fetchApprovedVolunteers() {
    volunteersRef
        .orderByChild('status')
        .equalTo('Approved')
        .onValue
        .listen((DatabaseEvent event) {
      final List<Map<String, String>> volunteersList = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          volunteersList.add({
            'name': value['name'],
            'email': value['email'], // Include email
            'phone': value['phone'], // Include phone
            'skills': value['skills'], // Include skills
            'date': value['timestamp'] != null
                ? DateTime.fromMillisecondsSinceEpoch(value['timestamp'])
                    .toLocal()
                    .toString()
                    .split(' ')[0]
                : 'N/A',
          });
        });
      }

      setState(() {
        approvedVolunteers = volunteersList;
      });
    });
  }

  // Function to show volunteer details in a dialog
  void _showVolunteerDetails(Map<String, String> volunteer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(volunteer['name']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Approved on: ${volunteer['date']}'),
              const SizedBox(height: 8),
              Text('Email: ${volunteer['email']}'),
              Text('Phone: ${volunteer['phone']}'),
              Text('Skills: ${volunteer['skills']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Close'),
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
        title: const Text('Approved Volunteers'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: approvedVolunteers.isEmpty
          ? const Center(child: Text('No approved volunteers found.'))
          : ListView.builder(
              itemCount: approvedVolunteers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading:
                        const Icon(Icons.person, color: Colors.green, size: 40),
                    title: Text(approvedVolunteers[index]['name']!),
                    subtitle: Text(
                        'Approved on: ${approvedVolunteers[index]['date']}'),
                    onTap: () => _showVolunteerDetails(
                        approvedVolunteers[index]), // Show details on tap
                  ),
                );
              },
            ),
    );
  }
}
