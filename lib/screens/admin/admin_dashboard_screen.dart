import 'package:flutter/material.dart';
import 'approve_volunteers_screen.dart';
import 'manage_authorities_screen.dart';
import 'approved_volunteers_screen.dart';
import 'rejected_volunteers_screen.dart';
import 'update_rescue_center_screen.dart'; // Import the new screen

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false, // This removes the back arrow
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildFeatureCard(context, 'Approve Volunteers', Icons.check_circle,
              ApproveVolunteersScreen()),
          _buildFeatureCard(context, 'Manage Authorities',
              Icons.admin_panel_settings, ManageAuthoritiesScreen()),
          _buildFeatureCard(context, 'View Approved Volunteers', Icons.thumb_up,
              ApprovedVolunteersScreen()),
          _buildFeatureCard(context, 'View Rejected Volunteers',
              Icons.thumb_down, RejectedVolunteersScreen()),
          // New Card for updating the rescue center address
          _buildFeatureCard(context, 'Update Rescue Center Address',
              Icons.location_on, UpdateRescueCenterScreen()),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
