import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final int id;
  final String type; // 'Gas', 'Agua', 'Intrusos', 'Temperatura'
  final String message;
  final DateTime timestamp;
  final String severity; // 'Alto', 'Medio', 'Bajo'
  final String location;

  Alert({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.severity,
    required this.location,
  });
}

class AlertsProvider extends ChangeNotifier {
  final List<Alert> _alerts = [];

  AlertsProvider() {
    fetchAlertsFromFirebase();
  }

  List<Alert> get alerts => _alerts;

  int get alertCount => _alerts.length;

  List<Alert> getFilteredAlerts(List<String> filters) {
    if (filters.isEmpty) return _alerts;
    return _alerts.where((alert) => filters.contains(alert.type)).toList();
  }

  int getFilteredAlertCount(List<String> filters) {
    return getFilteredAlerts(filters).length;
  }

  String calculateRiskLevel() {
    if (_alerts.any((alert) => alert.severity == 'Alto')) return 'Alto';
    if (_alerts.any((alert) => alert.severity == 'Medio')) return 'Medio';
    if (_alerts.isNotEmpty) return 'Bajo';
    return 'Sin riesgo';
  }

  void addAlert(Alert alert) {
    _alerts.add(alert);
    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  void removeAlert(int id) {
    _alerts.removeWhere((alert) => alert.id == id);
    notifyListeners();
  }

  Future<void> fetchAlertsFromFirebase() async {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('monitorAmbiental')
          .get();

      int idCounter = 1;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['fecha'] == null || data['fecha'] is! Timestamp) continue;

        final DateTime timestamp = (data['fecha'] as Timestamp).toDate();

        if (timestamp.isBefore(twentyFourHoursAgo)) continue;

        // Alerta de gas
        if (data['nivelGas'] != null && data['nivelGas'] == 'alto') {
          addAlert(Alert(
            id: idCounter++,
            type: 'Gas',
            message: 'Nivel de gas elevado detectado',
            timestamp: timestamp,
            severity: 'Alto',
            location: 'Cocina',
          ));
        }

        // Alerta de intrusos
        if (data['movimiento'] != null &&
            data['movimiento'] == 'movimiento detectado') {
          addAlert(Alert(
            id: idCounter++,
            type: 'Intrusos',
            message: 'Movimiento detectado cuando no hay nadie en casa',
            timestamp: timestamp,
            severity: 'Alto',
            location: 'Puerta trasera',
          ));
        }

        // Alerta de temperatura alta
        if (data['temperatura'] != null && data['temperatura'] > 28) {
          addAlert(Alert(
            id: idCounter++,
            type: 'Temperatura',
            message: 'Temperatura elevada detectada',
            timestamp: timestamp,
            severity: 'Medio',
            location: 'Sala de estar',
          ));
        }
      }
    } catch (e) {
      debugPrint('Error al cargar alertas desde Firebase: $e');
    }
  }
}