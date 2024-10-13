import 'package:flutter/material.dart';

class ManageAuthoritiesScreen extends StatelessWidget {
  const ManageAuthoritiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Authorities'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: const Center(
        child: Text('Manage various authorities here'),
      ),
    );
  }
}
