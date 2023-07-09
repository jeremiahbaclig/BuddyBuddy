import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late NavigatorState _navigator;

  @override
  void initState() {
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.resumed.toString()) {
        // Handle app resumed event
        // Specify the page you want to navigate to when the app is resumed
        await Future.delayed(Duration.zero); // Add this line
        _navigator.pushReplacementNamed('welcome');
      }
      return null;
    });
  }

  @override
  void dispose() {
    SystemChannels.lifecycle.setMessageHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<DarkMode>(context);

    return MaterialApp(
      navigatorKey: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<void>(
              builder: (context) {
                _navigator = Navigator.of(context);
                return WillPopScope(
                  onWillPop: () async {
                    // Specify the page you want to navigate to when the back button is pressed
                    _navigator.pushReplacementNamed('welcome');

                    // Return false to prevent the app from exiting
                    return false;
                  },
                  child: const HomeScreen(),
                );
              },
            );
          case 'registration':
            return MaterialPageRoute<void>(
              builder: (context) => RegisterPage(),
            );
          case 'login':
            return MaterialPageRoute<void>(
              builder: (context) => LoginPage(),
            );
          case 'settings':
            return MaterialPageRoute<void>(
              builder: (context) => const Settings(),
            );
          case 'welcome':
            return MaterialPageRoute<void>(
              builder: (context) => const WelcomeScreen(),
            );
          default:
            return MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const Scaffold(body: Center(child: Text('404 Not Found'))),
            );
        }
      },
      title: 'Buddy Buddy ʕ •ᴥ•ʔ',
      theme: themeMode.darkMode ? darkTheme : mainTheme,
    );
  }
}

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
