import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  DateTime? _lastNotificationTime;
  final Set<String> _notifiedDocuments = {};

  // Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    tz.initializeTimeZones(); // 🔹 inicializar zonas horarias

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Solicitar permisos
    await _requestPermissions();

    // Iniciar monitoreo en segundo plano
    _startBackgroundMonitoring();
  }

  // Callback cuando se toca una notificación
  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Payload de notificación: $payload');
      // Aquí puedes manejar la navegación cuando se toque la notificación
    }
  }

  // Solicitar permisos de notificación (solo Android)
  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }

  // Iniciar monitoreo en segundo plano
  void _startBackgroundMonitoring() {
    final now = DateTime.now();
    _lastNotificationTime = now;

    _firestoreSubscription = FirebaseFirestore.instance
        .collection('monitorAmbiental')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('fecha', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        _processNewAlerts(snapshot);
      },
      onError: (error) {
        debugPrint('Error en monitoreo de segundo plano: $error');
      },
    );
  }

  // Procesar nuevas alertas y enviar notificaciones
  void _processNewAlerts(QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final doc = change.doc;
        final data = doc.data() as Map<String, dynamic>;

        if (_notifiedDocuments.contains(doc.id)) continue;
        _notifiedDocuments.add(doc.id);

        if (data['fecha'] != null && data['fecha'] is Timestamp) {
          final DateTime alertTime = (data['fecha'] as Timestamp).toDate();

          if (_lastNotificationTime == null ||
              alertTime.isAfter(_lastNotificationTime!)) {
            _checkAndNotifyAlert(data, alertTime, doc.id);
          }
        }
      }
    }
  }

  // Verificar y enviar notificación para una alerta específica
  void _checkAndNotifyAlert(
      Map<String, dynamic> data, DateTime timestamp, String docId) {
    if (data['nivelGas'] != null && data['nivelGas'] == 'alto') {
      _showNotification(
        id: '${docId}_gas'.hashCode,
        title: '🚨 Alerta de Gas',
        body: 'Nivel de gas elevado detectado en la cocina',
        priority: NotificationPriority.high,
        alertType: 'Gas',
      );
    }

    if (data['movimiento'] != null &&
        data['movimiento'] == 'movimiento detectado') {
      _showNotification(
        id: '${docId}_intrusos'.hashCode,
        title: '🚨 Alerta de Seguridad',
        body: 'Movimiento detectado en puerta trasera',
        priority: NotificationPriority.high,
        alertType: 'Intrusos',
      );
    }

    if (data['temperatura'] != null && data['temperatura'] > 28) {
      _showNotification(
        id: '${docId}_temp'.hashCode,
        title: '🌡️ Alerta de Temperatura',
        body: 'Temperatura elevada: ${data['temperatura']}°C',
        priority: NotificationPriority.medium,
        alertType: 'Temperatura',
      );
    }

    if (data['nivelAgua'] != null && data['nivelAgua'] == 'alto') {
      _showNotification(
        id: '${docId}_agua'.hashCode,
        title: '💧 Alerta de Agua',
        body: 'Nivel de agua elevado detectado en sótano',
        priority: NotificationPriority.high,
        alertType: 'Agua',
      );
    }
  }

  // Mostrar notificación inmediata
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationPriority priority,
    required String alertType,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'awas_alerts',
      'Alertas AWAS',
      channelDescription: 'Notificaciones de alertas del sistema AWAS',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      color: Colors.blueGrey,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: alertType,
    );

    debugPrint('Notificación enviada: $title - $body');
  }

  // Programar notificación para más tarde (corregido con zonedSchedule v19+)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'awas_scheduled',
      'Recordatorios AWAS',
      channelDescription: 'Recordatorios programados del sistema AWAS',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ reemplazo
      payload: 'scheduled',
    );
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Pausar monitoreo
  void pauseMonitoring() {
    _firestoreSubscription?.pause();
  }

  // Reanudar monitoreo
  void resumeMonitoring() {
    _firestoreSubscription?.resume();
  }

  // Limpiar recursos
  void dispose() {
    _firestoreSubscription?.cancel();
    _notifiedDocuments.clear();
  }
}

enum NotificationPriority {
  low,
  medium,
  high,
  critical,
}
