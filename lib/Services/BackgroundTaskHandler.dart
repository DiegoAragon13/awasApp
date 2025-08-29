import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BackgroundTaskHandler {
  static const String _isolateName = 'background_isolate';
  static const String _portName = 'background_port';

  static SendPort? _uiSendPort;
  static Isolate? _backgroundIsolate;

  // Configurar el background isolate
  static Future<void> setupBackgroundIsolate() async {
    final ReceivePort receivePort = ReceivePort();
    _backgroundIsolate = await Isolate.spawn(
      _backgroundIsolateEntryPoint,
      receivePort.sendPort,
    );

    _uiSendPort = await receivePort.first as SendPort;

    // Registrar el puerto para comunicación
    IsolateNameServer.registerPortWithName(
      receivePort.sendPort,
      _portName,
    );
  }

  // Punto de entrada del isolate de segundo plano
  static void _backgroundIsolateEntryPoint(SendPort uiSendPort) async {
    // Configurar puerto de recepción para el isolate de segundo plano
    final ReceivePort backgroundReceivePort = ReceivePort();
    uiSendPort.send(backgroundReceivePort.sendPort);

    // Inicializar Firebase en el isolate de segundo plano
    await Firebase.initializeApp();

    // Configurar notificaciones locales (solo Android)
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Configurar listener de Firestore en segundo plano
    _setupFirestoreListener(flutterLocalNotificationsPlugin);

    // Mantener el isolate activo
    await for (final message in backgroundReceivePort) {
      if (message == 'stop') {
        break;
      }
    }
  }

  // Configurar listener de Firestore
  static void _setupFirestoreListener(
      FlutterLocalNotificationsPlugin notificationsPlugin,
      ) {
    final now = DateTime.now();

    FirebaseFirestore.instance
        .collection('monitorAmbiental')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('fecha', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        _processNewAlertsInBackground(snapshot, notificationsPlugin);
      },
      onError: (error) {
        debugPrint('Error en background listener: $error');
      },
    );
  }

  // Procesar alertas en segundo plano
  static void _processNewAlertsInBackground(
      QuerySnapshot snapshot,
      FlutterLocalNotificationsPlugin notificationsPlugin,
      ) async {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final doc = change.doc;
        final data = doc.data() as Map<String, dynamic>;

        if (data['fecha'] != null && data['fecha'] is Timestamp) {
          final DateTime alertTime = (data['fecha'] as Timestamp).toDate();
          await _sendBackgroundNotification(
              data,
              alertTime,
              doc.id,
              notificationsPlugin
          );
        }
      }
    }
  }

  // Enviar notificación desde segundo plano
  static Future<void> _sendBackgroundNotification(
      Map<String, dynamic> data,
      DateTime timestamp,
      String docId,
      FlutterLocalNotificationsPlugin notificationsPlugin,
      ) async {
    // Verificar alertas y enviar notificaciones

    // Gas
    if (data['nivelGas'] != null && data['nivelGas'] == 'alto') {
      await _showBackgroundNotification(
        notificationsPlugin,
        id: '${docId}_gas'.hashCode,
        title: '🚨 ALERTA CRÍTICA - Gas',
        body: 'Nivel de gas peligroso detectado en la cocina',
        payload: 'gas_alert',
      );
    }

    // Intrusos
    if (data['movimiento'] != null && data['movimiento'] == 'movimiento detectado') {
      await _showBackgroundNotification(
        notificationsPlugin,
        id: '${docId}_intrusos'.hashCode,
        title: '🚨 ALERTA DE SEGURIDAD',
        body: 'Movimiento detectado en puerta trasera',
        payload: 'intruder_alert',
      );
    }

    // Temperatura
    if (data['temperatura'] != null && data['temperatura'] > 28) {
      await _showBackgroundNotification(
        notificationsPlugin,
        id: '${docId}_temp'.hashCode,
        title: '🌡️ Alerta de Temperatura',
        body: 'Temperatura elevada: ${data['temperatura']}°C',
        payload: 'temperature_alert',
      );
    }

    // Agua
    if (data['nivelAgua'] != null && data['nivelAgua'] == 'alto') {
      await _showBackgroundNotification(
        notificationsPlugin,
        id: '${docId}_agua'.hashCode,
        title: '💧 ALERTA DE AGUA',
        body: 'Nivel de agua crítico en sótano',
        payload: 'water_alert',
      );
    }
  }

  // Mostrar notificación en segundo plano
  static Future<void> _showBackgroundNotification(
      FlutterLocalNotificationsPlugin plugin, {
        required int id,
        required String title,
        required String body,
        required String payload,
      }) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'awas_background_alerts',
      'Alertas AWAS (Segundo Plano)',
      channelDescription: 'Notificaciones críticas del sistema AWAS',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true, // Para alertas críticas
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      color: Colors.blueGrey,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
      ticker: title,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await plugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    debugPrint('Notificación de segundo plano enviada: $title');
  }

  // Detener el isolate de segundo plano
  static void stopBackgroundIsolate() {
    _uiSendPort?.send('stop');
    _backgroundIsolate?.kill(priority: Isolate.immediate);
    _backgroundIsolate = null;
    _uiSendPort = null;
    IsolateNameServer.removePortNameMapping(_portName);
  }
}

// Clase para manejar el estado de la aplicación y notificaciones
class AppLifecycleManager extends WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  bool _isInForeground = true;
  bool _backgroundIsolateStarted = false;

  bool get isInForeground => _isInForeground;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _isInForeground = true;
        _stopBackgroundNotifications();
        debugPrint('App en primer plano - notificaciones normales activas');
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _isInForeground = false;
        _startBackgroundNotifications();
        debugPrint('App en segundo plano - notificaciones de fondo activas');
        break;

      case AppLifecycleState.hidden:
        break;
    }
  }

  void _startBackgroundNotifications() {
    if (!_backgroundIsolateStarted) {
      BackgroundTaskHandler.setupBackgroundIsolate();
      _backgroundIsolateStarted = true;
    }
  }

  void _stopBackgroundNotifications() {
    if (_backgroundIsolateStarted) {
      BackgroundTaskHandler.stopBackgroundIsolate();
      _backgroundIsolateStarted = false;
    }
  }

  void dispose() {
    _stopBackgroundNotifications();
  }
}