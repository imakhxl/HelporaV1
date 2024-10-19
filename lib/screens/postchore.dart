import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../constants.dart';

class PostChorePage extends StatefulWidget {
  @override
  _PostChorePageState createState() => _PostChorePageState();
}

class _PostChorePageState extends State<PostChorePage> {
  TextEditingController _choreNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _ownerNameController = TextEditingController();
  TextEditingController _rewardController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  bool _isUrgent = false;
  bool _isCompleted = false; // Chore completed toggle
  File? _choreImage;
  final _auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();

    // Show options to pick image from camera or gallery
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _choreImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _choreImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'chores/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _postChore() async {
    try {
      User? user = _auth.currentUser;
      String choreId = FirebaseFirestore.instance.collection('chores').doc().id;
      DateTime now = DateTime.now();
      String? imageUrl;

      // Upload image if one is selected
      if (_choreImage != null) {
        imageUrl = await _uploadImage(_choreImage!);
      }

      await FirebaseFirestore.instance.collection('chores').doc(choreId).set({
        'choreName': _choreNameController.text,
        'location': _locationController.text,
        'ownerName': _ownerNameController.text,
        'reward': _rewardController.text,
        'contact': _contactController.text,
        'isUrgent': _isUrgent,
        'isCompleted': _isCompleted, // Chore completion status
        'userId': user?.uid,
        'choreId': choreId,
        'postedAt': now,
        'imageUrl': imageUrl, // Store image URL in Firestore
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chore Posted Successfully')),
      );
      // Reset form
      _choreNameController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _ownerNameController.clear();
      _rewardController.clear();
      _contactController.clear();
      setState(() {
        _choreImage = null;
        _isUrgent = false;
        _isCompleted = false;
      });
    } catch (e) {
      print('Error posting chore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post chore')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post a Chore!!',
          style: kTextPoppins,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: kColor4,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: kColor4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chore Image
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _choreImage != null ? FileImage(_choreImage!) : null,
                      child: _choreImage == null
                          ? Icon(Icons.camera_alt, color: kColor1, size: 40)
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Chore Name
                TextField(
                  controller: _choreNameController,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Chore Name',
                    prefixIcon: Icon(Icons.task_alt, color: kColor1),
                  ),
                ),
                SizedBox(height: 20),

                //Desciption
                TextField(
                  controller: _descriptionController,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Chore Description',
                    prefixIcon: Icon(Icons.assignment, color: kColor1),
                  ),
                ),
                SizedBox(height: 20),
                // Location
                TextField(
                  controller: _locationController,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Location',
                    prefixIcon: Icon(Icons.location_on, color: kColor1),
                  ),
                ),
                SizedBox(height: 20),

                // Owner's Name
                TextField(
                  controller: _ownerNameController,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Owner\'s Name',
                    prefixIcon: Icon(Icons.person, color: kColor1),
                  ),
                ),
                SizedBox(height: 20),

                // Reward
                TextField(
                  controller: _rewardController,
                  keyboardType: TextInputType.number,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Reward',
                    prefixIcon: Icon(Icons.monetization_on, color: kColor1),
                  ),
                ),
                SizedBox(height: 20),

                // Contact No
                TextField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Contact Number',
                    prefixIcon: Icon(Icons.phone, color: kColor1),
                  ),
                ),
                SizedBox(height: 20),

                // Urgency Toggle
                Row(
                  children: [
                    Icon(Icons.warning, color: kColor2),
                    SizedBox(width: 10),
                    Text('Mark as Urgent',style: kTextPoppins,),
                    Switch(
                      value: _isUrgent,
                      onChanged: (value) {
                        setState(() {
                          _isUrgent = value;
                        });
                      },
                      activeColor: kColor2,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Chore Completed Toggle
                Row(
                  children: [
                    Icon(Icons.check_circle, color: kColor2),
                    SizedBox(width: 10),
                    Text('Mark as Completed', style: kTextPoppins,),
                    Switch(
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                      activeColor: kColor2,
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Post Chore Button
                Center(
                  child: ElevatedButton(
                    onPressed: _postChore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kColor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Post Chore',
                      style: TextStyle(color: kColor4, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
