import 'package:flutter/material.dart';
import 'package:helpora_v1/screens/homepage.dart';
import 'package:helpora_v1/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:helpora_v1/constants.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColor4,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
              Text(
                "Welcome Back !",
                style: TextStyle(
                    color: kColor1,
                    fontFamily: "Poppins",
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30.0,
              ),
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
              RoundedButton(
                colour: kColor2,
                title: 'Log In',
                onPressed: () async {
                  setState(() {
                    showSpinner = true; // Show spinner while processing
                  });

                  try {
                    // Check if email and password are provided
                    if (email == null ||
                        password == null ||
                        email!.isEmpty ||
                        password!.isEmpty) {
                      throw Exception("Email and password cannot be empty");
                    }

                    // Attempt to sign in the user with email and password
                    final userCredential =
                        await _auth.signInWithEmailAndPassword(
                      email: email!,
                      password: password!,
                    );

                    // If login is successful, navigate to HomePage
                    if (userCredential.user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            userId: userCredential.user!
                                .uid, // Use the user ID from userCredential
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // Handle specific exceptions
                    String errorMessage;
                    if (e is FirebaseAuthException) {
                      errorMessage = e.message ?? 'An unknown error occurred.';
                    } else {
                      errorMessage = e.toString();
                    }

                    // Show a Snackbar with an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors
                            .red, // Optional: Set a red background to indicate error
                        duration:
                            const Duration(seconds: 3), // Snackbar duration
                      ),
                    );
                  } finally {
                    setState(() {
                      showSpinner = false; // Hide spinner
                    });
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
