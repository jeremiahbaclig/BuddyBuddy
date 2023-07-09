import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/auth/auth.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/pages/home/profile.dart';
import 'package:todo_app/utils/side_bar.dart';
import 'package:todo_app/pages/tasks/tasks.dart';
import 'package:todo_app/pages/welcome.dart';

late User loggedinUser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<DarkMode>(context);
    return Scaffold(
        appBar: CustomAppBar(
          title: "Buddy Buddy",
          actionWidgets: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(Icons.person_outlined),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'myUser',
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "My User ",
                          style: themeMode.darkMode
                              ? GoogleFonts.novaMono(color: Colors.grey)
                              : GoogleFonts.novaMono(color: Colors.black54),
                        ),
                        const WidgetSpan(
                          child: Icon(Icons.person_outline_rounded, size: 14),
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
                              : GoogleFonts.novaMono(color: Colors.black54),
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
}
