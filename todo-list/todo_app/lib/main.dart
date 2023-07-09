import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/auth/firebase_options.dart';
import 'package:todo_app/pages/home/home.dart';
import 'package:todo_app/pages/auth/login.dart';
import 'package:todo_app/pages/navbar.dart';
import 'package:todo_app/pages/auth/registration.dart';
import 'package:todo_app/pages/home/settings.dart';
import 'package:todo_app/utils/side_bar.dart';
import 'package:todo_app/pages/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(
    ChangeNotifierProvider(
      create: (context) => DarkMode(),
      child: TodoApp(),
    ),
  );
}

class TodoApp extends StatefulWidget {
  TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  var mainTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.grey[200],
  );
  var darkTheme = ThemeData.dark();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<DarkMode>(context);

    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        body: const WelcomeScreen(),
        appBar: const CustomAppBar(title: "Buddy Buddy"),
        drawer: const SideBar(),
      ),
      routes: {
        'registration': (context) => RegisterPage(),
        'login': (context) => LoginPage(),
        'home': (context) => const HomeScreen(),
        'settings': (context) => const Settings(),
        'welcome': (context) => const WelcomeScreen(),
      },
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) =>
              const Scaffold(body: Center(child: Text('404 Not Found'))),
        );
      },
      title: 'Buddy Buddy ʕ •ᴥ•ʔ',
      theme: themeMode.darkMode ? darkTheme : mainTheme,
    );
  }
} // ʕ •ᴥ•ʔ

class DarkMode with ChangeNotifier {
  bool darkMode = false;

  changeMode() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    darkMode = (prefs.getBool('maybeDarkMode') ?? true);

    prefs.setBool('maybeDarkMode', !darkMode);
    notifyListeners();
  }
}
