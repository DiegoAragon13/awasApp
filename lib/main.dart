import 'package:awas_app/utils/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Pages/splash.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeApp.lightTheme,
          darkTheme: ThemeApp.darktTheme,
          home: const Splash(),
        );
      },
    );
  }
}