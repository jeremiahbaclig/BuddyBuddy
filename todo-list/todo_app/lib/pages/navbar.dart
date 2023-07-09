import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? backButton;
  final String? pushToWhere;
  final List<Widget>? actionWidgets;
  final Color? customColor;
  final double? fontSize;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.backButton,
      this.pushToWhere,
      this.actionWidgets,
      this.customColor,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: backButton != null && backButton!
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushNamed(
                    context, pushToWhere != null ? pushToWhere! : "");
              },
            )
          : null,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        title,
        style: GoogleFonts.novaMono(
            color: customColor ?? Colors.indigoAccent,
            fontSize: fontSize ?? 20),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.indigoAccent),
      actions: actionWidgets ?? [],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Default AppBar height
}
