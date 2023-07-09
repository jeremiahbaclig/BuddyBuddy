import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/main.dart';

class RoundedButton extends StatelessWidget {
  RoundedButton({required this.color, required this.title, this.onPressed});
  final Color color;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    var themeMode = Provider.of<DarkMode>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: themeMode.darkMode
                ? GoogleFonts.novaMono(color: Colors.grey)
                : GoogleFonts.novaMono(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
