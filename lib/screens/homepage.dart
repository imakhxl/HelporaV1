import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpora_v1/screens/postchore.dart';
import 'package:helpora_v1/screens/profile.dart';

import 'choreDetails.dart';

// Color Scheme Constants
const kColor1 = Color(0xFF477B72);
const kColor2 = Color(0xFFF7BA34);
const kColor3 = Color(0xFFEFAA7C);
const kColor4 = Color(0xFFFCF1E2);

// const kTextFieldDecoration = InputDecoration(
//   hintText: '',
//   contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
//   border: OutlineInputBorder(
//     borderRadius: BorderRadius.all(Radius.circular(32.0)),
//   ),
//   enabledBorder: OutlineInputBorder(
//     borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
//     borderRadius: BorderRadius.all(Radius.circular(32.0)),
//   ),
//   focusedBorder: OutlineInputBorder(
//     borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
//     borderRadius: BorderRadius.all(Radius.circular(32.0)),
//   ),
// );

class HomePage extends StatefulWidget {
  static String id = 'home_screen';
  final String userId; // Add userId as a final variable

  // Update the constructor to accept userId
  HomePage({required this.userId}); // Use named parameter

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index for BottomNavigationBar

  // List of pages for navigation
  final List<Widget> _pages = [
    JobsPage(),
    PostChorePage(),
    Profile(),
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
        backgroundColor: kColor1,
        automaticallyImplyLeading: false,
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chores').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final chores = snapshot.data!.docs;

          if (chores.isEmpty) {
            return Center(child: Text('No chores available.'));
          }

          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two cards per row
              childAspectRatio: 0.7, // Adjust to control height and avoid overflow
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: chores.length,
            itemBuilder: (context, index) {
              var chore = chores[index];
              String choreName = chore['choreName'] ?? 'Unnamed Chore';
              String contact = chore['contact'] ?? 'No Contact Info';
              String location = chore['location'] ?? 'No Location';
              String? imageUrl = chore['imageUrl']; // May be null
              String choreId = chore['choreId'];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image or icon placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        height: 100,
                        width: double.infinity,
                        color: kColor3,
                        child: Icon(Icons.work, size: 50, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            choreName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kColor1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.phone, color: kColor2, size: 16),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  contact,
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.location_on, color: kColor3, size: 16),
                              SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Spacer(), // Pushes the button to the bottom
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChoreDetailsPage(choreId: choreId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12), // Adjust vertical padding for the button
                        ),
                        child: Text(
                          'View',
                          style: TextStyle(color: kColor4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return Center(child: Text('No data available.'));
      },
    );
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
