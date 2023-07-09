import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/auth/auth.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/pages/home/profile.dart';
import 'package:todo_app/utils/animations.dart';
import 'package:todo_app/utils/side_bar.dart';
import 'package:todo_app/pages/tasks/tasks.dart';
import 'package:todo_app/pages/welcome.dart';

import '../../utils/rounded_button.dart';

late User loggedinUser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  late Future<User?> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = getCurrentUser();
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<DarkMode>(context);
    return FutureBuilder<User?>(
      future: _futureUser,
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: listOfAnimations[1].widget);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return Column(children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "Errors authenticating...",
                  style: themeMode.darkMode
                      ? GoogleFonts.novaMono(color: Colors.grey)
                      : GoogleFonts.novaMono(color: Colors.black54)),
              const WidgetSpan(
                child: Icon(Icons.check_rounded, size: 14),
              ),
            ])),
            RoundedButton(
              onPressed: () {
                Navigator.pushNamed(context, "login");
              },
              title: "Return",
              color: Colors.indigoAccent,
            )
          ]);
        } else {
          loggedinUser = snapshot.data!;

          return Scaffold(
              appBar: CustomAppBar(
                title: "Buddy Buddy",
                actionWidgets: <Widget>[
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.person_outlined),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'myUser',
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "My User ",
                                style: themeMode.darkMode
                                    ? GoogleFonts.novaMono(color: Colors.grey)
                                    : GoogleFonts.novaMono(
                                        color: Colors.black54),
                              ),
                              const WidgetSpan(
                                child: Icon(Icons.person_outline_rounded,
                                    size: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'logOut',
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Log Out ",
                                style: themeMode.darkMode
                                    ? GoogleFonts.novaMono(color: Colors.grey)
                                    : GoogleFonts.novaMono(
                                        color: Colors.black54),
                              ),
                              const WidgetSpan(
                                child: Icon(Icons.login_rounded, size: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onSelected: (String value) {
                      if (value == 'myUser') {
                        User? user = FirebaseAuth.instance.currentUser;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(user: user!),
                          ),
                        );
                      } else if (value == 'logOut') {
                        Auth.signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => TodoApp(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              drawer: const SideBar(),
              body: TaskList(
                onDeleteTask: (Task task) {},
              ));
        }
      },
    );
  }
}
