import 'package:flutter/material.dart';

class EducationalResourcesScreen extends StatelessWidget {
  const EducationalResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Resources'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Articles',
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
                    title: Text('Article Title $index'),
                    subtitle: const Text('Category: Handling'),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark),
                      onPressed: () {
                        // Handle bookmark action
                      },
                    ),
                    onTap: () {
                      // Open article details
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
