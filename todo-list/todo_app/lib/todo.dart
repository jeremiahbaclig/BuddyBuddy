import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = <Todo>[];
  final TextEditingController _textFieldController = TextEditingController();
  final db = FirebaseFirestore.instance;

  get _createUniqueId {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        20, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  Map<String, dynamic> _createTask(Todo task) {
    return {
      "name": task.name,
      "completed": task.completed,
      "id": task.id,
      "userId": task.userId
    };
  }

  void _addTodoItem(String name) {
    setState(() {
      var newId = _createUniqueId;
      var todo =
          Todo(name: name, completed: false, id: newId, userId: "TO_CREATE");
      _todos.add(todo);

      db.collection("task").doc(todo.id).set(_createTask(todo));
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
      db.collection("task").doc(todo.id).delete().then(
            (doc) => print("Deleted task successfully"),
            onError: (e) => print("Error updating document $e"),
          );

      _todos.removeWhere((element) => element.name == todo.name);
    });
  }

  Future<List<TodoItem>> _seedTodoItems() async {
    _todos.clear();
    await db.collection("task").get().then((event) {
      for (var doc in event.docs) {
        var values = doc.data().values;
        var keys = doc.data().keys;

        String name = values.elementAt(keys.toList().indexOf('name'));
        bool completed = values.elementAt(keys.toList().indexOf('completed'));
        String id = values.elementAt(keys.toList().indexOf('id'));
        String userId = values.elementAt(keys.toList().indexOf('userId'));

        print("$name $completed $id");
        _todos.add(
            Todo(name: name, completed: completed, id: id, userId: userId));
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
      body: FutureBuilder(
          future: _seedTodoItems(),
          builder:
              (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot) {
            List<Widget> widgetChildren;
            if (snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: _todos.map((Todo todo) {
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
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
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
        tooltip: 'Add a task',
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
              'Add a task',
            ),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(
                hintText: 'Enter your task',
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
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _addTodoItem(_textFieldController.text);
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

class Todo {
  Todo(
      {required this.name,
      required this.completed,
      required this.id,
      required this.userId});
  String name;
  bool completed;
  String id;
  String userId;
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
    if (!checked) return null;

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
        activeColor: Colors.red,
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
            Icons.delete,
            color: Colors.red,
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
