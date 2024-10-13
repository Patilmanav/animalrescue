import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RejectedVolunteersScreen extends StatefulWidget {
  @override
  _RejectedVolunteersScreenState createState() =>
      _RejectedVolunteersScreenState();
}

class _RejectedVolunteersScreenState extends State<RejectedVolunteersScreen> {
  final DatabaseReference volunteersRef =
      FirebaseDatabase.instance.ref().child('approve_volunteers');

  List<Map<String, String>> rejectedVolunteers = [];

  @override
  void initState() {
    super.initState();
    _fetchRejectedVolunteers();
  }

  // Fetch rejected volunteers from the database
  void _fetchRejectedVolunteers() {
    volunteersRef
        .orderByChild('status')
        .equalTo('Rejected')
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
            'reason': value['rejection_reason'] ?? 'No reason provided',
          });
        });
      }

      setState(() {
        rejectedVolunteers = volunteersList;
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
              Text('Reason for Rejection: ${volunteer['reason']}'),
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
        title: const Text('Rejected Volunteers'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: rejectedVolunteers.isEmpty
          ? const Center(child: Text('No rejected volunteers found.'))
          : ListView.builder(
              itemCount: rejectedVolunteers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading:
                        const Icon(Icons.person, color: Colors.red, size: 40),
                    title: Text(rejectedVolunteers[index]['name']!),
                    subtitle: Text(
                      'Reason: ${rejectedVolunteers[index]['reason']}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: () => _showVolunteerDetails(
                        rejectedVolunteers[index]), // Show details on tap
                  ),
                );
              },
            ),
    );
  }
}
