import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/login.dart';
import 'package:todo_app/registration.dart';
import 'package:todo_app/settings.dart';
import 'package:todo_app/side_bar.dart';
import 'package:todo_app/todo.dart';
import 'package:todo_app/welcome.dart';

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
      initialRoute: 'welcome_screen',
      routes: {
        'welcome_screen': (context) => const WelcomeScreen(),
        'registration_screen': (context) => RegistrationScreen(),
        'login_screen': (context) => LoginScreen(),
        'home_screen': (context) => const _TodoApp(),
        'settings_screen': (context) => const Settings()
      },
      title: 'Buddy Buddy ʕ •ᴥ•ʔ',
      theme: themeMode.darkMode ? darkTheme : mainTheme,
    );
  }
}

class _TodoApp extends StatefulWidget {
  const _TodoApp({Key? key}) : super(key: key);

  @override
  State<_TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<_TodoApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Buddy Buddy",
            style: GoogleFonts.novaMono(color: Colors.indigoAccent)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.indigoAccent),
      ),
      drawer: const SideBar(),
      body: const TodoList(),
    );
  }
} // ʕ •ᴥ•ʔ

class DarkMode with ChangeNotifier {
  bool darkMode = false;

  changeMode() {
    darkMode = !darkMode;
    notifyListeners();
  }
}
