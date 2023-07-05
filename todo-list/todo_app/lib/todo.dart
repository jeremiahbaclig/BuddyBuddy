import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/navbar.dart';
import 'package:todo_app/user.dart';
import 'package:todo_app/utils.dart';

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
      "taskId": todo.taskId
    };
  }

  void _addTodoItem(String name) {
    setState(() {
      var newId = Generator.createUniqueId(20);
      var todo = Todo(
          name: name,
          completed: false,
          id: newId,
          userId: CurrentUser.getCurrentUser().uid,
          taskId: widget.taskIdHolder.taskId);
      _todos.add(todo);

      db.collection("todo").doc(todo.id).set(_createTask(todo));
    });
    _textFieldController.clear();
  }

  void _handleTodoChange(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
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
        var values = doc.data().values;
        var keys = doc.data().keys;

        String name = values.elementAt(keys.toList().indexOf('name'));
        bool completed = values.elementAt(keys.toList().indexOf('completed'));
        String id = values.elementAt(keys.toList().indexOf('id'));
        String userId = values.elementAt(keys.toList().indexOf('userId'));
        String taskId = values.elementAt(keys.toList().indexOf('taskId'));

        if (userId != CurrentUser.getCurrentUser().uid) {
          continue;
        } else if (taskId != widget.taskIdHolder.taskId) {
          continue;
        } else {
          _todos.add(Todo(
              name: name,
              completed: completed,
              id: id,
              userId: userId,
              taskId: taskId));
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
        pushToWhere: "home_screen",
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
                            child: Text("Let's start by adding a task!",
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
      required this.taskId});
  String name;
  bool completed;
  String id;
  String userId;
  String taskId;
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

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return GoogleFonts.novaMono(color: Colors.grey);

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
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
        value: todo.completed,
        onChanged: (value) {
          onTodoChanged(todo);
        },
      ),
      title: Row(children: <Widget>[
        Expanded(
          child: Text(todo.name, style: _getTextStyle(todo.completed)),
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
