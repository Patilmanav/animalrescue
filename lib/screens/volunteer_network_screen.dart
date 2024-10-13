import 'package:flutter/material.dart';

class VolunteerNetworkScreen extends StatelessWidget {
  const VolunteerNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Network'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Volunteers',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with your data length
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/50'), // Replace with actual URL
                    ),
                    title: Text('Volunteer Name $index'),
                    subtitle: const Text('Contact Info: volunteer@example.com'),
                    trailing: IconButton(
                      icon: const Icon(Icons.contact_phone),
                      onPressed: () {
                        // Handle contact action
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle sign up as a volunteer
              },
              child: const Text('Sign Up as a Volunteer'),
            ),
          ),
          // Section for pending requests (This can be a separate widget or expand on request)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Pending Volunteer Requests:',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Add a list of pending requests
        ],
      ),
    );
  }
}
