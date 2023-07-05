import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? backButton;
  final String? pushToWhere;

  const CustomAppBar(
      {super.key, required this.title, this.backButton, this.pushToWhere});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: backButton != null && backButton!
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.maybePop(context);
                if (pushToWhere != null) {
                  Navigator.pushNamed(context, pushToWhere!);
                }
              },
            )
          : null,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        title,
        style: GoogleFonts.novaMono(color: Colors.indigoAccent),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.indigoAccent),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Default AppBar height
}
