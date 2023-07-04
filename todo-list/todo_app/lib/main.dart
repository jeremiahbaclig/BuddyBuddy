import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/side_bar.dart';
import 'package:todo_app/todo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(ChangeNotifierProvider(
      create: (context) => DarkMode(), child: TodoApp()));
}

class TodoApp extends StatelessWidget {
  TodoApp({Key? key}) : super(key: key);
  var mainTheme = ThemeData.light();
  var darkTheme = ThemeData.dark();

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<DarkMode>(context);
    return MaterialApp(
      title: 'Buddy Buddy ʕ •ᴥ•ʔ',
      theme: themeMode.darkMode ? darkTheme : mainTheme,
      home: const _TodoApp(),
    );
  }
}

class _TodoApp extends StatefulWidget {
  const _TodoApp({Key? key}) : super(key: key);

  @override
  State<_TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<_TodoApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buddy Buddy ʕ •ᴥ•ʔ"),
      ),
      body: const TodoList(),
      drawer: const SideBar(),
    );
  }
}

class DarkMode with ChangeNotifier {
  bool darkMode = false;

  changeMode() {
    darkMode = !darkMode;
    notifyListeners();
  }
}
