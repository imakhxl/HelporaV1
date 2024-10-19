import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Color Scheme Constants
const kColor1 = Color(0xFF477B72);
const kColor2 = Color(0xFFF7BA34);
const kColor3 = Color(0xFFEFAA7C);
const kColor4 = Color(0xFFFCF1E2);

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _email;
  String? _phone;

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Fetch user details from Firestore users collection
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _name = userDoc['name'];
            _email = userDoc['email'];
            _phone = userDoc['phone'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: kColor1,
        elevation: 0,
      ),
      body: _name == null || _email == null || _phone == null
          ? Center(child: CircularProgressIndicator()) // Loading indicator while fetching data
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: kColor4,
                child: Icon(Icons.person, color: kColor1, size: 60),
              ),
            ),
            SizedBox(height: 30),

            // Name
            Text(
              'Name:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kColor1,
              ),
            ),
            SizedBox(height: 5),
            Text(
              _name ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 20),

            // Email
            Text(
              'Email:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kColor1,
              ),
            ),
            SizedBox(height: 5),
            Text(
              _email ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 20),

            // Phone Number
            Text(
              'Phone:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kColor1,
              ),
            ),
            SizedBox(height: 5),
            Text(
              _phone ?? 'N/A',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 40),

            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _auth.signOut(); // Sign out the user
                  Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kColor1,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
