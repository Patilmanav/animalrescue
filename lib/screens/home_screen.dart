import 'package:flutter/material.dart';
import 'package:animalrescue/screens/adoption_screen.dart';
import 'package:animalrescue/screens/animal_spotting_screen.dart';
import 'package:animalrescue/screens/educational_resources_screen.dart';
import 'package:animalrescue/screens/settings.dart';
import 'package:animalrescue/screens/spotted_animal.dart';
import 'package:animalrescue/screens/user_profile.dart';
import 'package:animalrescue/screens/veterinary_assistance_screen.dart';
import 'package:animalrescue/screens/volunteer_network_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userType;

  HomeScreen(this.userType);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();

    // Initialize the screens based on userType
    _screens.addAll([
      widget.userType == 'Volunteer'
          ? SpottedAnimalsScreen()
          : AnimalSpottingScreen(),
      widget.userType == 'Volunteer'
          ? VolunteerNetworkScreen()
          : VeterinaryAssistanceScreen(),
      AdoptionAndFosterCareScreen(),
      UserProfileScreen(),
    ]);
  }

  // Drawer (Three-line menu)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Street Animal Rescue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Animal Spotting'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AnimalSpottingScreen()));
            },
          ),
          if (widget.userType == 'Volunteer')
            ListTile(
              leading: Icon(Icons.volunteer_activism),
              title: Text('Volunteer Network'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => VolunteerNetworkScreen()));
              },
            ),
          ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Veterinary Assistance'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VeterinaryAssistanceScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Spotting',
        ),
        BottomNavigationBarItem(
          icon: Icon(widget.userType == 'Volunteer'
              ? Icons.volunteer_activism
              : Icons.local_hospital),
          label: widget.userType == 'Volunteer' ? 'Volunteer' : 'Assistance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Adoption',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  // Floating Action Button for quick animal spotting report
  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => AnimalSpottingScreen()));
      },
      backgroundColor: Colors.green,
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Street Animal Rescue'),
        automaticallyImplyLeading: false, // This removes the back arrow
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
          )
        ],
      ),
      drawer: _buildDrawer(), // Three-line menu drawer
      body: _screens[
          _currentIndex], // Display selected screen from BottomNavigationBar
      bottomNavigationBar:
          _buildBottomNavigationBar(), // Modern bottom navigation
      floatingActionButton:
          _buildFloatingActionButton(), // FAB for quick actions
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
