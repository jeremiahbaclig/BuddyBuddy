import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Settings",
            style: GoogleFonts.novaMono(color: Colors.indigoAccent)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.indigoAccent),
      ),
      body: const _Settings(),
    );
  }
}

class _Settings extends StatefulWidget {
  const _Settings({Key? key}) : super(key: key);

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<DarkMode>(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode, size: 35),
                title: const Text("Dark Mode"),
                subtitle: const Text("Change your theme."),
                trailing: Switch(
                  value: themeMode.darkMode,
                  activeTrackColor: Colors.indigoAccent,
                  activeColor: Colors.indigoAccent,
                  onChanged: (value) {
                    themeMode.changeMode();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
