import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeApp {
  ThemeApp._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    splashColor: Colors.transparent,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF213555),
    shadowColor: const Color.fromARGB(30, 0, 0, 0),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF213555),
      secondary: Color.fromARGB(255, 255, 255, 255), // Color más claro que el scaffold
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        color: const Color(0xFF213555),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        color: const Color(0xFF213555),
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static ThemeData darktTheme = ThemeData(
    splashColor: Colors.transparent,
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF213555),
    scaffoldBackgroundColor: const Color.fromARGB(255, 6, 6, 6),
    shadowColor: const Color.fromARGB(39, 7, 7, 13),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF213555),
      secondary: Color.fromARGB(
        255,
        9,
        9,
        9,
      ), // Color más claro que el scaffold
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 14,
        color: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        color: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
