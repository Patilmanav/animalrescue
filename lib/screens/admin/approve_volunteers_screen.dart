import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../models/volunteer.dart';

class ApproveVolunteersScreen extends StatefulWidget {
  ApproveVolunteersScreen({super.key});

  @override
  _ApproveVolunteersScreenState createState() =>
      _ApproveVolunteersScreenState();
}

class _ApproveVolunteersScreenState extends State<ApproveVolunteersScreen> {
  final DatabaseReference volunteersRef =
      FirebaseDatabase.instance.ref().child('approve_volunteers');

  List<Volunteer> pendingVolunteers = [];
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchPendingVolunteers();
  }

  // Function to generate a random password
  String _generateRandomPassword({int length = 8}) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }

  // Fetch pending volunteers from the database
  void _fetchPendingVolunteers() {
    volunteersRef
        .orderByChild('status')
        .equalTo('Not Approved')
        .onValue
        .listen((DatabaseEvent event) {
      final List<Volunteer> volunteersList = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          volunteersList.add(Volunteer(
            id: key,
            name: value['name'],
            email: value['email'],
            phone: value['phone'],
            status: value['status'],
          ));
        });
      }

      setState(() {
        pendingVolunteers = volunteersList;
        isLoading = false; // Stop loading
      });
    });
  }

// Approve volunteer logic and generate login info
  void _approveVolunteer(Volunteer volunteer) async {
    try {
      // Generate a random password
      String password = _generateRandomPassword();

      // Update the volunteer status to 'Approved'
      await volunteersRef.child(volunteer.id).update({'status': 'Approved'});

      // Store the login info in another collection
      DatabaseReference loginInfoRef =
          FirebaseDatabase.instance.ref().child('volunteers');
      await loginInfoRef.child(volunteer.id).set({
        'email': volunteer.email,
        'password': password,
        'name': volunteer.name,
        'phone': volunteer.phone
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Volunteer approved. Login info generated.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving volunteer: $error')),
      );
    }
  }

  // Reject volunteer logic with reason
  void _rejectVolunteer(Volunteer volunteer) async {
    final reason = await _showRejectionDialog(context);

    // Once the reason is collected (or left blank), update the volunteer's status
    if (reason != null) {
      try {
        await volunteersRef.child(volunteer.id).update({
          'status': 'Rejected',
          'rejection_reason': reason,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Volunteer rejected. Reason: $reason')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting volunteer: $error')),
        );
      }
    }
  }

  // Function to show a dialog for the rejection reason
  Future<String?> _showRejectionDialog(BuildContext context) {
    final TextEditingController _reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Volunteer'),
          content: TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without a reason
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_reasonController.text);
              },
              child: const Text('Reject'),
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
        title: const Text('Approve Volunteers'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pendingVolunteers.length,
              itemBuilder: (context, index) {
                final volunteer = pendingVolunteers[index];
                return _buildVolunteerTile(volunteer);
              },
            ),
    );
  }

  Widget _buildVolunteerTile(Volunteer volunteer) {
    return ListTile(
      title: Text(volunteer.name),
      subtitle: Text(volunteer.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              _approveVolunteer(volunteer);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              _rejectVolunteer(volunteer);
            },
          ),
        ],
      ),
    );
  }
}
