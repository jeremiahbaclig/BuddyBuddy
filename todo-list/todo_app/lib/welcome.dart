import 'package:flutter/material.dart';
import 'rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bear.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RoundedButton(
                color: Colors.indigoAccent,
                title: 'Log In',
                onPressed: () {
                  Navigator.pushNamed(context, 'login_screen');
                },
              ),
              RoundedButton(
                color: Colors.indigoAccent,
                title: 'Register',
                onPressed: () {
                  Navigator.pushNamed(context, 'registration_screen');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
