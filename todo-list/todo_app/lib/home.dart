import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app/auth.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/navbar.dart';
import 'package:todo_app/profile.dart';
import 'package:todo_app/side_bar.dart';
import 'package:todo_app/tasks.dart';
import 'package:todo_app/welcome.dart';

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
    return Scaffold(
        appBar: CustomAppBar(
          title: "Buddy Buddy",
          actionWidgets: <Widget>[
            PopupMenuButton<String>(
              icon: const Icon(Icons.person_outlined),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'myUser',
                  child: Text('My User'),
                ),
                const PopupMenuItem<String>(
                  value: 'logOut',
                  child: Text('Log Out'),
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
        body: const TaskList());
  }
}
