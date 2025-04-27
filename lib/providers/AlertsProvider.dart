import 'package:flutter/material.dart';

class Alert {
  final String type; // 'Gas', 'Agua', 'Intrusos'
  final String message;
  final DateTime timestamp;
  final String severity; // 'Alto', 'Medio', 'Bajo'

  Alert({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

class AlertsProvider extends ChangeNotifier {
  final List<Alert> _alerts = [];

  // Inicializar con algunos datos de ejemplo
  AlertsProvider() {
    // Agregue algunas alertas de prueba xd
    _alerts.add(
      Alert(
        type: 'Gas',
        message: 'Nivel de gas elevado detectado',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        severity: 'Alto',
      ),
    );
    _alerts.add(
      Alert(
        type: 'Agua',
        message: 'Posible fuga de agua detectada',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        severity: 'Medio',
      ),
    );
    _alerts.add(
      Alert(
        type: 'Intrusos',
        message: 'Movimiento detectado cuando no hay nadie en casa',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        severity: 'Alto',
      ),
    );
  }

  // Obtener todas las alertas
  List<Alert> get alerts => _alerts;

  // Obtener el número de alertas
  int get alertCount => _alerts.length;

  // Obtener alertas filtradas según los tipos
  List<Alert> getFilteredAlerts(List<String> filters) {
    if (filters.isEmpty) {
      return _alerts;
    }
    return _alerts.where((alert) => filters.contains(alert.type)).toList();
  }

  // Obtener el contador de alertas filtradas
  int getFilteredAlertCount(List<String> filters) {
    return getFilteredAlerts(filters).length;
  }

  // Calcular el nivel de riesgo basado en las alertas
  String calculateRiskLevel() {
    if (_alerts.any((alert) => alert.severity == 'Alto')) {
      return 'Alto';
    } else if (_alerts.any((alert) => alert.severity == 'Medio')) {
      return 'Medio';
    } else if (_alerts.isNotEmpty) {
      return 'Bajo';
    } else {
      return 'Sin riesgo';
    }
  }

  // Agregar una nueva alerta
  void addAlert(Alert alert) {
    _alerts.add(alert);
    notifyListeners();
  }

  // Limpiar todas las alertas
  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }
}