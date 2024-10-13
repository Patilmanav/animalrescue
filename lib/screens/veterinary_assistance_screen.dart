import 'package:flutter/material.dart';

class VeterinaryAssistanceScreen extends StatelessWidget {
  const VeterinaryAssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veterinary Assistance'),
            automaticallyImplyLeading: false, // This removes the back arrow

      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Veterinarians',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with actual data length
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Veterinarian Name $index'),
                    subtitle: const Text('Contact Info: vet@example.com\nDistance: 1.2 miles\nServices: Check-up, Vaccination'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Schedule an appointment
                      },
                      child: const Text('Schedule'),
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
                // Emergency helpline action
              },
              child: const Text('Emergency Helpline'),
            ),
          ),
        ],
      ),
    );
  }
}
