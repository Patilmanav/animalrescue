import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: true, // Replace with actual state
              onChanged: (bool value) {
                // Handle toggle change
              },
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: false, // Replace with actual state
              onChanged: (bool value) {
                // Handle toggle change
              },
            ),
            ListTile(
              title: const Text('Contact Support'),
              onTap: () {
                // Handle contact support action
              },
            ),
            const ListTile(
              title: Text('About'),
              subtitle: Text('App Version 1.0.0\nCredits: Your Team'),
            ),
          ],
        ),
      ),
    );
  }
}
