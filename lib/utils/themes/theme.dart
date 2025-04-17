import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeApp {
  ThemeApp._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF213555),
    scaffoldBackgroundColor: Colors.white,
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
    useMaterial3: true,
    fontFamily: GoogleFonts.poppins().fontFamily,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF213555),
    scaffoldBackgroundColor: Colors.black,
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
