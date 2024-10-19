import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpora_v1/screens/postchore.dart';
import 'package:helpora_v1/screens/profile.dart';

// Color Scheme Constants
const kColor1 = Color(0xFF477B72);
const kColor2 = Color(0xFFF7BA34);
const kColor3 = Color(0xFFEFAA7C);
const kColor4 = Color(0xFFFCF1E2);

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index for BottomNavigationBar

  // List of pages for navigation
  final List<Widget> _pages = [
    JobsPage(),
    PostChorePage(),
    ProfilePage(),
    MyChoresPage(),
  ];

  // This function handles BottomNavigationBar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColor4, // Background using the provided color scheme
      appBar: AppBar(
        title: Text('Helpora'),
        backgroundColor: kColor1, // Use your defined color
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('images/logowhite.png', height: 40), // Logo on the top right
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected page here
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: kColor1, // Bottom navigation using primary color (kColor1)
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0, 5),
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent, // Transparent background for custom design
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.work, color: _selectedIndex == 0 ? kColor2 : kColor3),
                label: 'Jobs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add, color: _selectedIndex == 1 ? kColor2 : kColor3),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: _selectedIndex == 2 ? kColor2 : kColor3),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment, color: _selectedIndex == 3 ? kColor2 : kColor3),
                label: 'My Chores',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: kColor2,
            unselectedItemColor: kColor3,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: _onItemTapped,
            selectedFontSize: 14,
            unselectedFontSize: 14,
          ),
        ),
      ),
    );
  }
}

// Jobs Page (dummy content for now)
class JobsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Jobs Page'));
  }
}

// PostChorePage (should use your actual PostChorePage implementation)


// Profile Page (dummy content for now)


// MyChoresPage (dummy content for now)
class MyChoresPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('My Chores Page'));
  }
}
