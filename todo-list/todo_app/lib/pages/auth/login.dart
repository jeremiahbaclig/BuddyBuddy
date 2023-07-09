import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/utils/animations.dart';
import 'package:todo_app/auth/auth.dart';
import 'package:todo_app/pages/home/home.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/pages/home/profile.dart';
import 'package:todo_app/pages/auth/registration.dart';
import 'package:todo_app/utils/rounded_button.dart';
import 'package:todo_app/utils/validator.dart';

import '../../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<DarkMode>(context);

    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: "Buddy Buddy",
          backButton: true,
          pushToWhere: "/",
        ),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'Login',
                        style: themeMode.darkMode
                            ? GoogleFonts.novaMono(
                                color: Colors.grey, fontSize: 24)
                            : GoogleFonts.novaMono(
                                color: Colors.black54, fontSize: 24),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _emailTextController,
                            focusNode: _focusEmail,
                            validator: (value) => Validator.validateEmail(
                              email: value!,
                            ),
                            decoration: InputDecoration(
                              hintText: "email",
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 178, 38, 83),
                                ),
                              ),
                            ),
                            style: themeMode.darkMode
                                ? GoogleFonts.novaMono(
                                    color: Colors.grey, fontSize: 16)
                                : GoogleFonts.novaMono(
                                    color: Colors.black54, fontSize: 16),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordTextController,
                            focusNode: _focusPassword,
                            obscureText: true,
                            validator: (value) => Validator.validatePassword(
                              password: value!,
                            ),
                            decoration: InputDecoration(
                              hintText: "password",
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 178, 38, 83),
                                ),
                              ),
                            ),
                            style: themeMode.darkMode
                                ? GoogleFonts.novaMono(
                                    color: Colors.grey, fontSize: 16)
                                : GoogleFonts.novaMono(
                                    color: Colors.black54, fontSize: 16),
                          ),
                          const SizedBox(height: 24.0),
                          _isProcessing
                              ? listOfAnimations[1].widget
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: RoundedButton(
                                        title: "Sign In",
                                        color: Colors.indigoAccent,
                                        onPressed: () async {
                                          _focusEmail.unfocus();
                                          _focusPassword.unfocus();

                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              _isProcessing = true;
                                            });

                                            User? user = await Auth
                                                .signInUsingEmailPassword(
                                              email: _emailTextController.text,
                                              password:
                                                  _passwordTextController.text,
                                              context: context,
                                            );

                                            setState(() {
                                              _isProcessing = false;
                                            });

                                            if (user != null) {
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const HomeScreen(),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 24.0),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Create an account?',
                                  style: GoogleFonts.novaMono(
                                    color: Colors.indigoAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              _focusEmail.unfocus();
                              _focusPassword.unfocus();

                              setState(() {
                                _isProcessing = true;
                              });

                              User? user = await Auth.signInWithGoogle(context);

                              setState(() {
                                _isProcessing = false;
                              });

                              if (user != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              }
                            },
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Sign in with\n',
                                    style: themeMode.darkMode
                                        ? GoogleFonts.novaMono(
                                            color: Colors.grey, fontSize: 16)
                                        : GoogleFonts.novaMono(
                                            color: Colors.black54,
                                            fontSize: 16),
                                  ),
                                  const TextSpan(
                                    text: ' G',
                                    style: TextStyle(
                                      color: Color(0xFF008744), // Green
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'o',
                                    style: TextStyle(
                                      color: Color(0xFFD50F25), // Red
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'o',
                                    style: TextStyle(
                                      color: Color(0xFFF4B400), // Yellow
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'g',
                                    style: TextStyle(
                                      color: Color(0xFF4285F4), // Blue
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'l',
                                    style: TextStyle(
                                      color: Color(0xFF008744), // Green
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'e',
                                    style: TextStyle(
                                      color: Color(0xFFD50F25), // Red
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Center(
                child: listOfAnimations[1].widget,
              );
            }
          },
        ),
      ),
    );
  }
}
