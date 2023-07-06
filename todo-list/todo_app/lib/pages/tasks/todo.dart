import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/utils/animations.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/auth/user.dart';
import 'package:todo_app/utils/utils.dart';

class TaskHolder {
  final String taskId;
  final String taskName;

  TaskHolder(this.taskId, this.taskName);
}

class TodoList extends StatefulWidget {
  final TaskHolder taskIdHolder;

  const TodoList({Key? key, required this.taskIdHolder}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = <Todo>[];
  final TextEditingController _textFieldController = TextEditingController();
  final db = FirebaseFirestore.instance;

  Map<String, dynamic> _createTask(Todo todo) {
    return {
      "name": todo.name,
      "completed": todo.completed,
      "id": todo.id,
      "userId": todo.userId,
      "taskId": todo.taskId,
      "timeLastSeen": todo.timeLastSeen,
      "secondsTilMidnight": todo.secondsTilMidnight,
      "completedBy": todo.completedBy,
      "completedList": todo.completedList
    };
  }

  void _addTodoItem(String name) {
    setState(() {
      var newId = Generator.createUniqueId(20);

      DateTime now = DateTime.now();
      DateTime nextDay = DateTime(now.year, now.month, now.day + 1);

      var todo = Todo(
          name: name,
          completed: false,
          id: newId,
          userId: CurrentUser.getCurrentUser().uid,
          taskId: widget.taskIdHolder.taskId,
          timeLastSeen: now.millisecondsSinceEpoch ~/ 1000,
          secondsTilMidnight: nextDay.millisecondsSinceEpoch ~/ 1000,
          completedBy: [],
          completedList: []);
      _todos.add(todo);

      db.collection("todo").doc(todo.id).set(_createTask(todo));
    });
    _textFieldController.clear();
  }

  void _handleTodoChange(Todo todo) {
    setState(() {
      String newEmail = CurrentUser.getCurrentUser().email!;

      todo.completed = !todo.completed;

      db.collection("todo").doc(todo.id).update({
        "completed": todo.completed,
      }).then((_) {
        print("Todo status updated successfully!");
      }).catchError((error) {
        print("Failed to update todo status: $error");
      });

      db.collection("todo").doc(todo.id).get().then((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          try {
            List<dynamic>? completedList =
                List<dynamic>.from(snapshot.data()?['completedList'] ?? []);

            bool emailFound = false;
            bool myUserCompleted = false;
            for (int i = 0; i < completedList.length; i++) {
              if (completedList[i]["email"] == newEmail) {
                emailFound = true;
                completedList[i]["didComplete"] =
                    !completedList[i]["didComplete"];
                myUserCompleted = completedList[i]["didComplete"];
                break;
              }
            }

            if (!emailFound) {
              completedList.add({"email": newEmail, "didComplete": true});
            }

            List<String> completedBy = List<String>.from(data['completedBy']);
            if (!completedBy.contains(newEmail)) {
              completedBy.add(newEmail);
            } else if (!myUserCompleted) {
              completedBy.removeWhere((element) => element == newEmail);
            }

            db
                .collection("todo")
                .doc(todo.id)
                .update({"completedList": completedList});

            db
                .collection("todo")
                .doc(todo.id)
                .update({"completedBy": completedBy});
          } catch (e) {
            print(e);
          }
        }
      });
    });
  }

  void _deleteTodo(Todo todo) {
    setState(() {
      db.collection("todo").doc(todo.id).delete().then(
            (doc) => print("Deleted todo successfully"),
            onError: (e) => print("Error updating document $e"),
          );

      _todos.removeWhere((element) => element.name == todo.name);
    });
  }

  Future<List<TodoItem>> _seedTodoItems() async {
    _todos.clear();
    await db.collection("todo").get().then((event) {
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

        if (keys.length < 2) {
          continue;
        }

        String name = values!.elementAt(keys.toList().indexOf('name'));
        bool completed = values.elementAt(keys.toList().indexOf('completed'));
        String id = values.elementAt(keys.toList().indexOf('id'));
        String userId = values.elementAt(keys.toList().indexOf('userId'));
        String taskId = values.elementAt(keys.toList().indexOf('taskId'));
        Iterable<dynamic>? completedBy;
        Iterable<dynamic>? completedList;
        dynamic timeLastSeen = null;
        dynamic secondsTilMidnight = null;

        DateTime now = DateTime.now();
        DateTime nextDay = DateTime(now.year, now.month, now.day + 1);
        try {
          timeLastSeen =
              values.elementAt(keys.toList().indexOf("timeLastSeen"));
        } catch (e) {
          timeLastSeen = now.millisecondsSinceEpoch ~/ 1000;
          db.collection("todo").doc(id).update({"timeLastSeen": timeLastSeen});
        }
        try {
          secondsTilMidnight =
              values.elementAt(keys.toList().indexOf("secondsTilMidnight"));
        } catch (e) {
          secondsTilMidnight = nextDay.millisecondsSinceEpoch ~/ 1000;
          db
              .collection("todo")
              .doc(id)
              .update({"secondsTilMidnight": secondsTilMidnight});
        }
        try {
          completedBy = List<String>.from(
              values.elementAt(keys.toList().indexOf("completedBy")) ?? []);
        } catch (e) {
          completedBy = [];
        }

        try {
          completedList = List<dynamic>.from(
              values.elementAt(keys.toList().indexOf("completedList")) ?? []);
        } catch (e) {
          completedList = [];
        }

        /*
          timeLastSeen and secondsTilMidnight are created on seed of the todo list.
          secondsTilMidnight: (midnight - currentTime)

          if they don't exist, then seed them accordingly
          otherwise, check that the time until midnight is less than
          (now - timeLastSeen)[which is the time elapsed since last time]

          if it is greater, then that means not enough time passed, so 
          completed for today is still valid
        */
        if (timeLastSeen != null && secondsTilMidnight != null) {
          if (secondsTilMidnight <
              (now.millisecondsSinceEpoch ~/ 1000 - timeLastSeen)) {
            completed = false;
            completedList = [];
            completedBy = [];
            print("Has been a midnight since last seen. Resetting completed.");
          }
        }

        if (taskId != widget.taskIdHolder.taskId) {
          continue;
        } else {
          _todos.add(Todo(
              name: name,
              completed: completed,
              id: id,
              userId: userId,
              taskId: taskId,
              timeLastSeen: now.millisecondsSinceEpoch ~/ 1000,
              secondsTilMidnight: nextDay.millisecondsSinceEpoch ~/ 1000,
              completedBy: completedBy as List<String>,
              completedList: completedList as List<dynamic>));
        }
      }
    });

    return _todos.map((Todo todo) {
      return TodoItem(
          todo: todo,
          onTodoChanged: _handleTodoChange,
          removeTodo: _deleteTodo);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.taskIdHolder.taskName,
        customColor: Colors.grey,
        fontSize: 18,
        backButton: true,
        pushToWhere: "home",
      ),
      body: FutureBuilder(
          future: _seedTodoItems(),
          builder:
              (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot) {
            List<Widget> widgetChildren;
            if (snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: _todos
                        .map((Todo todo) {
                          return TodoItem(
                            todo: todo,
                            onTodoChanged: _handleTodoChange,
                            removeTodo: _deleteTodo,
                          );
                        })
                        .toList()
                        .isEmpty
                    ? [
                        Center(
                            child: Text("Let's add a task!",
                                style: GoogleFonts.novaMono(
                                  color: Colors.grey,
                                )))
                      ]
                    : _todos.map((Todo todo) {
                        return TodoItem(
                          todo: todo,
                          onTodoChanged: _handleTodoChange,
                          removeTodo: _deleteTodo,
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
                  child: Text('Error: ${snapshot.error}'),
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
        tooltip: 'Add a todo',
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
            title: Text(
              'Add a todo',
              style: GoogleFonts.novaMono(color: Colors.black87),
            ),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigoAccent)),
                hintText: 'Enter your todo',
              ),
              autofocus: true,
              style: GoogleFonts.novaMono(color: Colors.black87),
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
                onPressed: () {
                  Navigator.of(context).pop();
                  _addTodoItem(_textFieldController.text);
                },
                child: Text('Add',
                    style: GoogleFonts.novaMono(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Todo {
  Todo(
      {required this.name,
      required this.completed,
      required this.id,
      required this.userId,
      required this.taskId,
      this.timeLastSeen,
      this.secondsTilMidnight,
      this.completedBy,
      required this.completedList});
  String name;
  bool completed;
  String id;
  String userId;
  String taskId;
  int? timeLastSeen;
  int? secondsTilMidnight;
  List<String>? completedBy;
  List<dynamic> completedList;

  @override
  String toString() {
    return 'Todo(name: $name, completed: $completed, id: $id, userId: $userId, '
        'taskId: $taskId, timeLastSeen: $timeLastSeen, '
        'secondsTilMidnight: $secondsTilMidnight, '
        'completedBy: $completedBy, completedList: $completedList)';
  }
}

class TodoItem extends StatelessWidget {
  TodoItem(
      {required this.todo,
      required this.onTodoChanged,
      required this.removeTodo})
      : super(key: ObjectKey(todo));

  final Todo todo;
  final void Function(Todo todo) onTodoChanged;
  final void Function(Todo todo) removeTodo;

  bool _getCheckboxForUser() {
    for (var value in todo.completedList) {
      if (value["email"] == CurrentUser.getCurrentUser().email) {
        return value["didComplete"];
      }
    }

    return false;
  }

  bool? _myUserCompleted() {
    for (var value in todo.completedList) {
      if (value["email"] == CurrentUser.getCurrentUser().email) {
        return value["didComplete"];
      }
    }
  }

  TextStyle? _getTextStyle() {
    if (_myUserCompleted() ?? false) {
      return const TextStyle(
        color: Colors.black54,
        decoration: TextDecoration.lineThrough,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTodoChanged(todo);
      },
      leading: Checkbox(
        checkColor: Colors.greenAccent,
        activeColor: const Color.fromARGB(255, 178, 38, 83),
        value: _getCheckboxForUser(),
        onChanged: (value) {
          onTodoChanged(todo);
        },
      ),
      title: Row(children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(todo.name, style: _getTextStyle()),
              Text(
                todo.completedBy!.join(", ") ?? "",
                style: GoogleFonts.novaMono(
                    color: Colors.greenAccent, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Color.fromARGB(255, 178, 38, 83),
          ),
          alignment: Alignment.centerRight,
          onPressed: () {
            removeTodo(todo);
          },
        ),
      ]),
    );
  }
}
