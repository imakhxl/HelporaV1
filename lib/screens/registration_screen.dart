import 'dart:typed_data';
import 'dart:io'; // For File class

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'homepage.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Firestore instance
  String? email;
  String? password;
  String? name;
  String? phoneNumber;

  File? _idProofImage; // File for the ID proof image
  bool showSpinner = false;

  // Input validation function
  bool validateFields() {
    if (email == null || !email!.contains('@')) {
      return false;
    }
    if (password == null || password!.length < 6) {
      return false;
    }
    if (name == null || name!.isEmpty) {
      return false;
    }
    if (phoneNumber == null || phoneNumber!.length < 10) {
      return false;
    }
    if (_idProofImage == null) {
      return false;
    }
    return true;
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'idproofs/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = FirebaseStorage.instance
          .ref()
          .child(fileName);

      UploadTask uploadTask = ref.putFile(image);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
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
                  Navigator.of(context).pop();
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    _idProofImage = File(pickedFile!.path);
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  setState(() {
                    _idProofImage = File(pickedFile!.path);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(hintText: "Enter your name"),
              ),
              const SizedBox(height: 8.0),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  phoneNumber = value;
                },
                decoration: InputDecoration(hintText: "Enter your phone number"),
              ),
              const SizedBox(height: 8.0),
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(hintText: "Enter your email"),
              ),
              const SizedBox(height: 8.0),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: InputDecoration(hintText: "Enter your password"),
              ),
              const SizedBox(height: 24.0),

              // ID Proof Upload Button
              TextButton(
                onPressed: _pickImage,
                child: Text('Upload ID Proof'),
              ),

              // Show uploaded image preview (optional)
              _idProofImage != null
                  ? Image.file(_idProofImage!)
                  : Text("No image selected"),

              const SizedBox(height: 24.0),

              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  if (validateFields()) {
                    try {
                      final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );

                      if (newUser != null) {
                        // Upload the ID proof image and get its download URL
                        String? imageUrl;
                        if (_idProofImage != null) {
                          imageUrl = await _uploadImage(_idProofImage!);
                        }

                        // Store additional user details in Firestore
                        await _firestore.collection('users').doc(newUser.user!.uid).set({
                          'name': name,
                          'email': email,
                          'phoneNumber': phoneNumber,
                          'humanityPoints': 0,
                          'userId': newUser.user!.uid,
                          'idProofUrl': imageUrl, // Store image URL
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(userId: newUser.user!.uid)),
                        );
                      }
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: Unable to create user. Please try again.')),
                      );
                    } finally {
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  } else {
                    setState(() {
                      showSpinner = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter valid information.')),
                    );
                  }
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


