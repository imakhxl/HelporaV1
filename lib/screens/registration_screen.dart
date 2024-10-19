import 'package:helpora_v1/main.dart';

import 'package:flutter/material.dart';
import 'package:helpora_v1/rounded_button.dart';
import 'package:helpora_v1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;  // Firestore instance
  String? email;
  String? password;
  String? name;
  String? phoneNumber;
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
    return true;
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
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 48.0),

              // Name TextField
              TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  name = value;
                },
                decoration:
                kTextFieldDecoration.copyWith(hintText: "Enter your name"),
              ),
              const SizedBox(height: 8.0),

              // Phone Number TextField
              TextField(
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  phoneNumber = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "Enter your phone number"),
              ),
              const SizedBox(height: 8.0),

              // Email TextField
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                },
                decoration:
                kTextFieldDecoration.copyWith(hintText: "Enter your email"),
              ),
              const SizedBox(height: 8.0),

              // Password TextField
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "Enter your password"),
              ),
              const SizedBox(height: 24.0),

              // Register Button
              RoundedButton(
                colour: Colors.blueAccent,
                title: 'Register',
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });

                  if (validateFields()) {
                    try {
                      // Create new user in Firebase Auth
                      final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );

                      if (newUser != null) {
                        // Store additional user details in Firestore
                        await _firestore.collection('users').doc(newUser.user!.uid).set({
                          'name': name,
                          'email': email,
                          'phoneNumber': phoneNumber,
                          'userId': newUser.user!.uid, // Storing userId
                        });

                        // Navigate to HomeScreen (or desired screen)
                        // Navigator.pushNamed(context, HomeScreen.id);
                      }
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: Unable to create user. Please try again.'),
                        ),
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
                      SnackBar(
                        content: Text('Please enter valid information.'),
                        backgroundColor: Colors.red, // Optional: Set a background color for the Snackbar
                        duration: Duration(seconds: 3), // Optional: Set the duration for the Snackbar
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
