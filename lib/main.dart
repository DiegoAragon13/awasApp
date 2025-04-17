import 'package:awas_app/utils/themes/theme.dart';
import 'package:flutter/material.dart';
import 'Pages/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeApp.lightTheme,
      darkTheme: ThemeApp.darktTheme,
      home: Splash(),
    );
  }
}
