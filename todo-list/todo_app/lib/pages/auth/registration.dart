import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/utils/animations.dart';
import 'package:todo_app/auth/auth.dart';
import 'package:todo_app/pages/home/home.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/pages/home/profile.dart';
import 'package:todo_app/utils/rounded_button.dart';
import 'package:todo_app/utils/validator.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  bool _isFormFilled = false;

  @override
  void initState() {
    super.initState();

    // Add listeners to text controllers
    _nameTextController.addListener(_updateFormFilledStatus);
    _emailTextController.addListener(_updateFormFilledStatus);
    _passwordTextController.addListener(_updateFormFilledStatus);
  }

  void _updateFormFilledStatus() {
    setState(() {
      _isFormFilled = _nameTextController.text.isNotEmpty &&
          _emailTextController.text.isNotEmpty &&
          _passwordTextController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<DarkMode>(context);
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: "Buddy Buddy",
          backButton: true,
          pushToWhere: "login",
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Register',
                    style: themeMode.darkMode
                        ? GoogleFonts.novaMono(color: Colors.grey, fontSize: 24)
                        : GoogleFonts.novaMono(
                            color: Colors.black54, fontSize: 24),
                  ),
                ),
                Form(
                  key: _registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _nameTextController,
                        focusNode: _focusName,
                        validator: (value) => Validator.validateName(
                          name: value!,
                        ),
                        decoration: InputDecoration(
                          hintText: "name",
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
                      const SizedBox(height: 16.0),
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
                      const SizedBox(height: 16.0),
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
                      const SizedBox(height: 32.0),
                      _isProcessing
                          ? listOfAnimations[1].widget
                          : Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isFormFilled && !_isProcessing
                                        ? () async {
                                            setState(() {
                                              _isProcessing = true;
                                            });

                                            if (_registerFormKey.currentState!
                                                .validate()) {
                                              User? user =
                                                  await Auth.registerUsingEmailPassword(
                                                      name: _nameTextController
                                                          .text,
                                                      email:
                                                          _emailTextController
                                                              .text,
                                                      password:
                                                          _passwordTextController
                                                              .text,
                                                      context: context);

                                              setState(() {
                                                _isProcessing = false;
                                              });

                                              if (user != null) {
                                                Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const HomeScreen(),
                                                  ),
                                                  ModalRoute.withName('/'),
                                                );
                                              }
                                            } else {
                                              setState(() {
                                                _isProcessing = false;
                                              });
                                            }
                                          }
                                        : null,
                                    child: RoundedButton(
                                      title: "Sign Up",
                                      color: _isFormFilled && !_isProcessing
                                          ? Colors.indigoAccent
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
