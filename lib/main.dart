import 'package:awas_app/providers/panel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awas_app/providers/segmented_control_provider.dart';
import 'package:awas_app/utils/themes/theme.dart';
import 'package:awas_app/Pages/splash.dart';
import 'package:awas_app/providers/theme_provider.dart';
import 'package:awas_app/providers/AlertsProvider.dart';
import 'package:awas_app/providers/contact_provider.dart';

import 'package:awas_app/Services/NotificationService.dart';
import 'package:awas_app/Services/BackgroundTaskHandler.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'Services/gemini_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  GeminiService.initialize();

  // Inicializar notificaciones y zona horaria
  tz.initializeTimeZones();
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SegmentedControlProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
        ChangeNotifierProvider(create: (_) => PanelProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ],
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
          home: const AppLifecycleWrapper(),
        );
      },
    );
  }
}

class AppLifecycleWrapper extends StatefulWidget {
  const AppLifecycleWrapper({super.key});

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper> {
  final AppLifecycleManager _lifecycleManager = AppLifecycleManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleManager);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleManager);
    _lifecycleManager.dispose();
    NotificationService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Splash();
  }
}
