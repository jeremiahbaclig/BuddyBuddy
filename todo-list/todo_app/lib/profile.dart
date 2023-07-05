import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/auth.dart';
import 'package:todo_app/login.dart';
import 'package:todo_app/navbar.dart';
import 'package:todo_app/rounded_button.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;

  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Profile",
        backButton: true,
        pushToWhere: "home_screen",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_currentUser.displayName}',
            ),
            const SizedBox(height: 16.0),
            Text(
              '${_currentUser.email}',
            ),
            const SizedBox(height: 16.0),
            _currentUser.emailVerified
                ? RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Email Verified ",
                        ),
                        WidgetSpan(
                          child: Icon(Icons.check_rounded, size: 14),
                        ),
                      ],
                    ),
                  )
                : RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Email Not Verified ",
                        ),
                        WidgetSpan(
                          child: Icon(Icons.no_accounts_outlined, size: 14),
                        ),
                      ],
                    ),
                  ),
            _isSendingVerification
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: !_currentUser.emailVerified
                        ? [
                            RoundedButton(
                              onPressed: () async {
                                setState(() {
                                  _isSendingVerification = true;
                                });
                                await _currentUser.sendEmailVerification();
                                setState(() {
                                  _isSendingVerification = false;
                                });
                              },
                              title: "Verify email",
                              color: Colors.indigoAccent,
                            ),
                          ]
                        : [],
                  ),
          ],
        ),
      ),
    );
  }
}
