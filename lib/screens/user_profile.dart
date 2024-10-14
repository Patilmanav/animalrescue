import 'dart:convert';

import 'package:animalrescue/screens/settings.dart';
import 'package:animalrescue/screens/volunteer_activity_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String userName = '';
  String userEmail = '';
  String userRole = 'user'; // default role

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from local storage
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the saved user data
    String? loginDetails = prefs.getString('login_details');

    if (loginDetails != null) {
      // Decode the JSON string to a Map
      Map<String, dynamic> userData = jsonDecode(loginDetails);

      setState(() {
        userName = userData['name'] ?? 'Unknown User';
        userEmail = userData['email'] ?? 'Unknown Email';
        userRole = userData['userType'] ?? 'user'; // Check the role
      });
    } else {
      setState(() {
        userName = 'Unknown User';
        userEmail = 'Unknown Email';
        userRole = 'user'; // Default to regular user if no data
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/100'), // Replace with actual user image
            ),
            const SizedBox(height: 10),
            Text(userName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(userEmail, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _buildListOptions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build different options based on user role
  List<Widget> _buildListOptions() {
    List<Widget> options = [];

    if (userRole == 'User') {
      options.addAll([
        ListTile(
          title: const Text('My Reports'),
          onTap: () {
            // Navigate to My Reports
          },
        ),
        ListTile(
          title: const Text('Adopted Animals'),
          onTap: () {
            // Navigate to Adopted Animals
          },
        ),
      ]);
    } else if (userRole == 'Volunteer') {
      options.addAll([
        ListTile(
          title: const Text('My Volunteer Activity'),
          onTap: () {
            // Navigate to Volunteer Activity
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => VolunteerActivityScreen()));
          },
        ),
      ]);
    }

    // Common option for both user and volunteer
    options.add(
      ListTile(
        title: const Text('Settings'),
        onTap: () {
          // Navigate to Settings
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => SettingsScreen()));
        },
      ),
    );

    return options;
  }
}
