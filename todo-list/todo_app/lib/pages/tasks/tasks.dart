import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:todo_app/utils/animations.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/utils/rounded_button.dart';
import 'package:todo_app/pages/tasks/todo.dart';
import 'package:todo_app/auth/user.dart';
import 'package:todo_app/utils/utils.dart';
import 'package:todo_app/utils/validator.dart';

import '../../main.dart';

typedef TaskDeleteCallback = void Function(Task task);

class TaskList extends StatefulWidget {
  const TaskList({super.key, required this.onDeleteTask});
  final TaskDeleteCallback onDeleteTask;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final List<Task> _tasks = <Task>[];
  final TextEditingController _textFieldController = TextEditingController();
  final db = FirebaseFirestore.instance;

  static Map<String, dynamic> _createTask(Task task) {
    return {
      "name": task.name,
      "id": task.id,
      "userId": task.userId,
      "emails": task.emails
    };
  }

  void _addTaskItem(String name) {
    setState(() {
      var newId = Generator.createUniqueId(20);
      var task = Task(
          name: name,
          id: newId,
          userId: CurrentUser.getCurrentUser().uid,
          emails:
              List.generate(1, (index) => CurrentUser.getCurrentUser().email!));
      _tasks.add(task);

      db.collection("task").doc(task.id).set(_createTask(task));
    });
    _textFieldController.clear();
  }

  void deleteTask(Task task) {
    setState(() {
      db.collection("task").doc(task.id).delete().then(
        (doc) {
          print("Deleted task successfully");

          // Delete associated todos
          db.collection("todo").where("taskId", isEqualTo: task.id).get().then(
            (snapshot) {
              for (var doc in snapshot.docs) {
                doc.reference.delete().then(
                      (_) => print("Deleted associated todo successfully"),
                      onError: (e) =>
                          print("Error deleting associated todo: $e"),
                    );
              }
            },
          );
        },
        onError: (e) => print("Error updating document $e"),
      );
      _tasks.removeWhere((element) => element.name == task.name);
      widget.onDeleteTask(task);
    });
  }

  Future<List<TaskItem>> _seedTaskItems() async {
    var currentUser = CurrentUser.getCurrentUser();
    _tasks.clear();
    await db.collection("task").get().then((event) {
      for (var doc in event.docs) {
        Iterable<dynamic>? values;
        Iterable<dynamic>? keys;
        try {
          values = doc.data().values;
          keys = doc.data().keys;
        } catch (e) {
          print("BAD DATA: ${e}");
          continue;
        }

        if (keys!.length < 2) {
          continue;
        }

        String name = values!.elementAt(keys!.toList().indexOf("name"));
        String id = values.elementAt(keys.toList().indexOf("id"));
        String userId = values.elementAt(keys.toList().indexOf("userId"));
        List<dynamic> emails =
            values.elementAt(keys.toList().indexOf("emails"));

        if (userId != currentUser.uid) {
          if ((emails.contains(currentUser.email))) {
            _tasks
                .add(Task(name: name, id: id, userId: userId, emails: emails));
          }
          continue;
        } else if (!(emails.contains(currentUser.email))) {
          continue;
        } else {
          _tasks.add(Task(name: name, id: id, userId: userId, emails: emails));
        }
      }
    });

    return _tasks.map((Task task) {
      return TaskItem(task: task, removeTask: deleteTask);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<DarkMode>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text:
                      "${CurrentUser.getCurrentUser().displayName ?? "Your User"}'s ",
                  style: GoogleFonts.novaMono(
                      color: Colors.indigoAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              TextSpan(
                text: "Tasks",
                style: themeMode.darkMode
                    ? GoogleFonts.novaMono(color: Colors.grey, fontSize: 16)
                    : GoogleFonts.novaMono(color: Colors.black54, fontSize: 16),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
          future: _seedTaskItems(),
          builder:
              (BuildContext context, AsyncSnapshot<List<TaskItem>> snapshot) {
            List<Widget> widgetChildren;
            if (snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: _tasks
                        .map((Task task) {
                          return TaskItem(
                            task: task,
                            removeTask: deleteTask,
                          );
                        })
                        .toList()
                        .isEmpty
                    ? [
                        Center(
                            child: Text(
                          "Let's start by creating a task list below!",
                          style: themeMode.darkMode
                              ? GoogleFonts.novaMono(color: Colors.grey)
                              : GoogleFonts.novaMono(color: Colors.black54),
                        ))
                      ]
                    : _tasks.map((Task task) {
                        return TaskItem(
                          task: task,
                          removeTask: deleteTask,
                        );
                      }).toList(),
              );
            } else if (snapshot.hasError) {
              widgetChildren = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Color.fromARGB(255, 178, 38, 83),
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text("Error: ${snapshot.error}"),
                ),
              ];
            } else {
              widgetChildren = <Widget>[
                Center(child: listOfAnimations[1].widget),
                Center(
                  child: Text("Awaiting data...",
                      style: GoogleFonts.novaMono(color: Colors.indigoAccent)),
                ),
              ];
            }
            return Column(
              children: widgetChildren,
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: "Add a list of tasks",
        backgroundColor: Colors.indigoAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var themeMode = Provider.of<DarkMode>(context);
        return Theme(
          data: Theme.of(context)
              .copyWith(dialogBackgroundColor: Theme.of(context).canvasColor),
          child: AlertDialog(
            title: Text(
              "Create a list of tasks",
              style: themeMode.darkMode
                  ? GoogleFonts.novaMono(color: Colors.grey)
                  : GoogleFonts.novaMono(color: Colors.black54),
            ),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigoAccent)),
                hintText: "Type here",
              ),
              autofocus: true,
              style: themeMode.darkMode
                  ? GoogleFonts.novaMono(color: Colors.grey)
                  : GoogleFonts.novaMono(color: Colors.black54),
            ),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 178, 38, 83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: GoogleFonts.novaMono(color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _addTaskItem(_textFieldController.text);
                },
                child: Text("Create",
                    style: GoogleFonts.novaMono(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Task {
  Task(
      {required this.name,
      required this.id,
      required this.userId,
      required this.emails});
  String name;
  String id;
  String userId;
  List<dynamic> emails;
}

class TaskItem extends StatelessWidget {
  TaskItem({required this.task, required this.removeTask})
      : super(key: ObjectKey(task));

  final Task task;
  final void Function(Task task) removeTask;
  final TextEditingController _textFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  showAlertDialog(BuildContext context, Task task) {
    Widget cancelButton = RoundedButton(
      title: "Back",
      onPressed: () {
        Navigator.of(context).pop();
      },
      color: Colors.indigoAccent,
    );
    Widget continueButton = RoundedButton(
      title: "Delete",
      onPressed: () {
        removeTask(task);
        Navigator.of(context).pop();
      },
      color: const Color.fromARGB(255, 178, 38, 83),
    );
    var themeMode = Provider.of<DarkMode>(context);
    AlertDialog alert = AlertDialog(
      title: Text("Are you sure?",
          style: themeMode.darkMode
              ? GoogleFonts.novaMono(color: Colors.grey)
              : GoogleFonts.novaMono(color: Colors.black54)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> shareTaskDialog(BuildContext context, Task task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var themeMode = Provider.of<DarkMode>(context);
        return Theme(
          data: Theme.of(context)
              .copyWith(dialogBackgroundColor: Theme.of(context).canvasColor),
          child: AlertDialog(
            title: Text(
              'Share this task list',
              style: themeMode.darkMode
                  ? GoogleFonts.novaMono(color: Colors.grey)
                  : GoogleFonts.novaMono(color: Colors.black54),
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _textFieldController,
                validator: (value) => Validator.validateEmail(email: value!),
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigoAccent)),
                  hintText: 'Enter email',
                ),
                autofocus: true,
                style: themeMode.darkMode
                    ? GoogleFonts.novaMono(color: Colors.grey)
                    : GoogleFonts.novaMono(color: Colors.black54),
              ),
            ),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 178, 38, 83),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.novaMono(color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var acs = ActionCodeSettings(
                        // URL you want to redirect back to.
                        // URL must be whitelisted in the Firebase Console.
                        url: 'https://buddybuddy.com',
                        handleCodeInApp: true,
                        iOSBundleId: 'com.example.todoApp',
                        androidPackageName: 'com.example.todoApp',
                        androidInstallApp: true,
                        androidMinimumVersion: '12');

                    Map<String, dynamic> createTask(Task task) => {
                          "name": task.name,
                          "id": task.id,
                          "userId": task.userId,
                          "emails": task.emails
                        };

                    var emailAuth = _textFieldController.text;
                    task.emails.add(emailAuth);

                    var db = FirebaseFirestore.instance;
                    db.collection("task").doc(task.id).set(createTask(task));

                    await FirebaseAuth.instance
                        .sendSignInLinkToEmail(
                            email: emailAuth, actionCodeSettings: acs)
                        .catchError((onError) =>
                            print('Error sending email verification $onError'))
                        .then((value) {
                      Navigator.of(context).pop();
                      print('Successfully sent email verification');
                    });
                  }
                },
                child: Text('Share',
                    style: GoogleFonts.novaMono(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<DarkMode>(context);
    return ListTile(
      title: Row(children: <Widget>[
        Expanded(
          child: Text(task.name,
              style: GoogleFonts.novaMono(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: "editTask",
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Let's go! ",
                      style: themeMode.darkMode
                          ? GoogleFonts.novaMono(color: Colors.grey)
                          : GoogleFonts.novaMono(color: Colors.black54),
                    ),
                    const WidgetSpan(
                      child: Icon(Icons.arrow_forward_rounded, size: 14),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "deleteTask",
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Delete ",
                      style: themeMode.darkMode
                          ? GoogleFonts.novaMono(color: Colors.grey)
                          : GoogleFonts.novaMono(color: Colors.black54),
                    ),
                    const WidgetSpan(
                      child: Icon(Icons.restore_from_trash_rounded, size: 14),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: "share",
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Share ",
                      style: themeMode.darkMode
                          ? GoogleFonts.novaMono(color: Colors.grey)
                          : GoogleFonts.novaMono(color: Colors.black54),
                    ),
                    const WidgetSpan(
                      child: Icon(Icons.share, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onSelected: (String value) {
            if (value == "editTask") {
              TaskHolder taskIdHolder = TaskHolder(task.id, task.name);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => TodoList(taskIdHolder: taskIdHolder),
                ),
              );
            } else if (value == "deleteTask") {
              showAlertDialog(context, task);
            } else if (value == "share") {
              shareTaskDialog(context, task);
            }
          },
        ),
      ]),
    );
  }
}
