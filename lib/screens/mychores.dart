import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helpora_v1/constants.dart';

// const kColor1 = Color(0xFF477B72);
// const kColor2 = Color(0xFFF7BA34);
// const kColor3 = Color(0xFFEFAA7C);
// const kColor4 = Color(0xFFFCF1E2);
 const kPrimaryColor = Color(0xFF344955);

class MyChoresPage extends StatefulWidget {
  @override
  _MyChoresPageState createState() => _MyChoresPageState();
}

class _MyChoresPageState extends State<MyChoresPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Chores'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chores')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final chores = snapshot.data?.docs;
          if (chores == null || chores.isEmpty) {
            return Center(
              child: Text('No chores found!'),
            );
          }
          return ListView.builder(
            itemCount: chores.length,
            itemBuilder: (context, index) {
              final chore = chores[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chore Name
                      Row(
                        children: [
                          Icon(Icons.task_alt, color: kPrimaryColor),
                          SizedBox(width: 8),
                          Text(
                            chore['choreName'] ?? 'No Chore Name',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, color: kColor1),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Location: ${chore['location'] ?? 'Unknown'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Reward
                      Row(
                        children: [
                          Icon(Icons.monetization_on, color: kColor2),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reward: ${chore['reward'] ?? 'None'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Urgency and Completion Status
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            'Urgent: ${chore['isUrgent'] ? "Yes" : "No"}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Completed: ${chore['isCompleted'] ? "Yes" : "No"}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Owner Name
                      Row(
                        children: [
                          Icon(Icons.person, color: kColor3),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Owner: ${chore['ownerName'] ?? 'Unknown'}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Interested People Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add functionality to show interested people
                          },
                          icon: Icon(Icons.people, color: Colors.white),
                          label: Text('Interested People'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: kColor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      // Image (if available)
                      chore['imageUrl'] != null
                          ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            chore['imageUrl'],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : Container(), // Show no image if imageUrl is not available
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
