import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpora_v1/constants.dart'; // Import Firebase Auth

class ChoreDetailsPage extends StatefulWidget {
  final String choreId;

  const ChoreDetailsPage({Key? key, required this.choreId}) : super(key: key);

  @override
  _ChoreDetailsPageState createState() => _ChoreDetailsPageState();
}

class _ChoreDetailsPageState extends State<ChoreDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? choreDetails;
  bool isInterested = false;

  @override
  void initState() {
    super.initState();
    _fetchChoreDetails();
  }

  Future<void> _fetchChoreDetails() async {
    try {
      final docSnapshot =
          await _firestore.collection('chores').doc(widget.choreId).get();
      if (docSnapshot.exists) {
        setState(() {
          choreDetails = docSnapshot.data();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _toggleInterest() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (!isInterested) {
        // Add to interestedChores collection
        await _firestore.collection('interestedChores').add({
          'choreId': widget.choreId,
          'choreName': choreDetails?['choreName'] ?? 'Not available',
          'description': choreDetails?['description'] ?? 'Not available',
          'location': choreDetails?['location'] ?? 'Not available',
          'ownerName': choreDetails?['ownerName'] ?? 'Not available',
          'reward': choreDetails?['reward'] ?? 'Not available',
          'contact': choreDetails?['contact'] ?? 'Not available',
          'isUrgent': choreDetails?['isUrgent'] ?? false,
          'userId': user.uid,
          'postedAt': choreDetails?['postedAt'] ?? DateTime.now(),
          'imageUrl': choreDetails?['imageUrl'],
        });
      } else {
        // Logic to remove from interestedChores can be implemented here
      }

      setState(() {
        isInterested = !isInterested; // Toggle interest status
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (choreDetails == null) {
      return Scaffold(
        backgroundColor: kColor4,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kColor4,
      appBar: AppBar(
        title: const Text(
          "Chore Details",
          style: kTextPoppins,
        ),
        backgroundColor: kColor1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Make the column take the full width
          children: [
            // Chore Image
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(choreDetails!['imageUrl'] ??
                      'https://via.placeholder.com/150'), // Default image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Chore Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chore Name
                  Row(
                    children: [
                      Icon(Icons.task_alt, color: kColor1),
                      const SizedBox(width: 8.0),
                      Text(
                        choreDetails!['choreName'] ?? 'Not available',
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  //Description
                  Row(
                    children: [
                      Icon(Icons.assignment, color: kColor1),
                      const SizedBox(width: 8.0),
                      Text(
                        choreDetails!['description'] ?? 'Not available',
                        style: kTextPoppins,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: kColor1),
                      const SizedBox(width: 8.0),
                      Text(
                        choreDetails!['location'] ?? 'Not available',
                        style: kTextPoppins,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Owner Name
                  Row(
                    children: [
                      Icon(Icons.person, color: kColor1),
                      const SizedBox(width: 8.0),
                      Text(
                        choreDetails!['ownerName'] ?? 'Not available',
                        style: kTextPoppins,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Reward
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: kColor1),
                      const SizedBox(width: 8.0),
                      Text(
                        choreDetails!['reward'] ?? 'Not available',
                        style: kTextPoppins,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Contact
                  Row(
                    children: [
                      Icon(Icons.phone, color: kColor1),
                      const SizedBox(width: 8.0),
                      Text(
                        choreDetails!['contact'] ?? 'Not available',
                        style: kTextPoppins,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Urgency Status
                  Row(
                    children: [
                      Icon(Icons.warning, color: kColor1),
                      const SizedBox(width: 8.0),
                      Text(
                        choreDetails!['isUrgent'] == true
                            ? "Urgent"
                            : "Not Urgent",
                        style: kTextPoppins,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),

            // Interested Button (Expanded to full width)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _toggleInterest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInterested ? kColor2 : kColor3,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Expand vertically
                ),
                child: Text(
                  isInterested ? "Interested" : "Show Interest",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      color: kColor4,
                      fontWeight: FontWeight.w600), // Increase font size
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
