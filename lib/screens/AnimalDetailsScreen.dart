import 'package:flutter/material.dart';

class AnimalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> animalData;

  const AnimalDetailsScreen({Key? key, required this.animalData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(animalData['animalType'] ?? 'Animal Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animal Type: ${animalData['animalType']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Breed: ${animalData['animalBreed']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Color: ${animalData['animalColor']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${animalData['animalDescription']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Rescued by: ${animalData['volunteer']['name']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Volunteer Email: ${animalData['volunteer']['email']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${animalData['status']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (animalData['status'] == 'ADOPTED' &&
                animalData.containsKey('adoptionDate'))
              Text('Adoption Date: ${animalData['adoptionDate']}'),
          ],
        ),
      ),
    );
  }
}
