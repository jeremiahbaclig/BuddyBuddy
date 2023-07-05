import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/navbar.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/user.dart';
import 'package:todo_app/utils.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final List<Task> _tasks = <Task>[];
  final TextEditingController _textFieldController = TextEditingController();
  final db = FirebaseFirestore.instance;

  Map<String, dynamic> _createTask(Task task) {
    return {
      "name": task.name,
      "id": task.id,
      "userId": task.userId,
      "sharedByUserId": task.sharedByUserId ?? ""
    };
  }

  void _addTaskItem(String name) {
    setState(() {
      var newId = Generator.createUniqueId(20);
      var task =
          Task(name: name, id: newId, userId: CurrentUser.getCurrentUser().uid);
      _tasks.add(task);

      db.collection("task").doc(task.id).set(_createTask(task));
    });
    _textFieldController.clear();
  }

  void _deleteTask(Task task) {
    setState(() {
      db.collection("task").doc(task.id).delete().then(
            (doc) => print("Deleted task successfully"),
            onError: (e) => print("Error updating document $e"),
          );

      _tasks.removeWhere((element) => element.name == task.name);
    });
  }

  Future<List<TaskItem>> _seedTaskItems() async {
    _tasks.clear();
    await db.collection("task").get().then((event) {
      for (var doc in event.docs) {
        var values = doc.data().values;
        var keys = doc.data().keys;

        dynamic sharedByUserId = null;
        String name = values.elementAt(keys.toList().indexOf('name'));
        String id = values.elementAt(keys.toList().indexOf('id'));
        String userId = values.elementAt(keys.toList().indexOf('userId'));
        try {
          sharedByUserId =
              values.elementAt(keys.toList().indexOf('sharedByUserId'));
        } catch (e) {}

        _tasks.add(Task(
            name: name,
            id: id,
            userId: userId,
            sharedByUserId: sharedByUserId));
      }
    });

    return _tasks.map((Task task) {
      return TaskItem(task: task, removeTask: _deleteTask);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('My Tasks',
            style: GoogleFonts.novaMono(color: Colors.blueGrey, fontSize: 18)),
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
                children: _tasks.map((Task task) {
                  return TaskItem(
                    task: task,
                    removeTask: _deleteTask,
                  );
                }).toList(),
              );
            } else if (snapshot.hasError) {
              widgetChildren = <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                ),
              ];
            } else {
              widgetChildren = const <Widget>[
                Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                Center(
                  child: Text('Awaiting data...'),
                ),
              ];
            }
            return Column(
              children: widgetChildren,
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(),
        tooltip: 'Add a list A task',
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
        return Theme(
          data: Theme.of(context)
              .copyWith(dialogBackgroundColor: Theme.of(context).canvasColor),
          child: AlertDialog(
            title: const Text(
              'Create a list of tasks',
            ),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigoAccent)),
                hintText: 'Type here',
              ),
              autofocus: true,
            ),
            actions: <Widget>[
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.indigoAccent),
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
                child: const Text('Add'),
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
      this.sharedByUserId});
  String name;
  String id;
  String userId;
  String? sharedByUserId;
}

class TaskItem extends StatelessWidget {
  TaskItem({required this.task, required this.removeTask})
      : super(key: ObjectKey(task));

  final Task task;
  final void Function(Task task) removeTask;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(children: <Widget>[
        Expanded(
          child: Text(task.name,
              style: GoogleFonts.novaMono(
                  color: Colors.blueGrey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic)),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'editTask',
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Edit ",
                    ),
                    WidgetSpan(
                      child: Icon(Icons.mode_edit_outlined, size: 14),
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'deleteTask',
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Delete ",
                    ),
                    WidgetSpan(
                      child: Icon(Icons.restore_from_trash_rounded, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
          onSelected: (String value) {
            if (value == 'editTask') {
              TaskHolder taskIdHolder = TaskHolder(task.id, task.name);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => TodoList(taskIdHolder: taskIdHolder),
                ),
              );
            } else if (value == 'deleteTask') {
              removeTask(task);
            }
          },
        ),
      ]),
    );
  }
}
