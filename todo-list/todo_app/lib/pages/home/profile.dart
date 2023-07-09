import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/utils/animations.dart';
import 'package:todo_app/auth/auth.dart';
import 'package:todo_app/pages/auth/login.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/utils/rounded_button.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;

  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<DarkMode>(context);
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Profile",
        backButton: true,
        pushToWhere: "/",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileImage(
                  url: _currentUser.photoURL,
                ),
                const SizedBox(height: 16.0),
                Text(
                  '${_currentUser.displayName}',
                  style: themeMode.darkMode
                      ? GoogleFonts.novaMono(color: Colors.grey, fontSize: 24)
                      : GoogleFonts.novaMono(
                          color: Colors.black54, fontSize: 24),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '${_currentUser.email}',
                  style: themeMode.darkMode
                      ? GoogleFonts.novaMono(color: Colors.grey, fontSize: 18)
                      : GoogleFonts.novaMono(
                          color: Colors.black54, fontSize: 18),
                ),
                const SizedBox(height: 16.0),
                _currentUser.emailVerified
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Email Verified ",
                                style: GoogleFonts.novaMono(
                                    color: Colors.green, fontSize: 14)),
                            const WidgetSpan(
                              child: Icon(Icons.check_rounded, size: 14),
                            ),
                          ],
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Email Not Verified ",
                                style: GoogleFonts.novaMono(
                                    color: Colors.red, fontSize: 14)),
                            const WidgetSpan(
                              child: Icon(Icons.no_accounts_outlined, size: 14),
                            ),
                          ],
                        ),
                      ),
                _isSendingVerification
                    ? listOfAnimations[1].widget
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
                RoundedButton(
                  onPressed: () {
                    Auth.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => TodoApp(),
                      ),
                    );
                  },
                  title: "Log Out",
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  final String? url;

  const ProfileImage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: precacheImage(NetworkImage(url ?? ''), context),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(url!),
          );
        } else if (snapshot.error != null) {
          return const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/user_icon.png'),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
