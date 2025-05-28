import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Alert && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AlertsProvider extends ChangeNotifier {
  final List<Alert> _alerts = [];
  StreamSubscription<QuerySnapshot>? _alertsSubscription;

  AlertsProvider() {
    _startListeningToAlerts();
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
    return RiskAnalyzer.calculateIntelligentRisk(_alerts);
  }

  void addAlert(Alert alert) {
    // Evitar duplicados
    if (!_alerts.contains(alert)) {
      _alerts.add(alert);
      notifyListeners();
    }
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  void removeAlert(int id) {
    _alerts.removeWhere((alert) => alert.id == id);
    notifyListeners();
  }

  // Método para comenzar a escuchar cambios en tiempo real
  void _startListeningToAlerts() {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    _alertsSubscription = FirebaseFirestore.instance
        .collection('monitorAmbiental')
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(twentyFourHoursAgo))
        .orderBy('fecha', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        _processFirebaseSnapshot(snapshot);
      },
      onError: (error) {
        debugPrint('Error al escuchar alertas desde Firebase: $error');
      },
    );
  }

  // Procesar los datos del snapshot de Firebase
  void _processFirebaseSnapshot(QuerySnapshot snapshot) {
    final List<Alert> newAlerts = [];
    int idCounter = 1;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['fecha'] == null || data['fecha'] is! Timestamp) continue;

      final DateTime timestamp = (data['fecha'] as Timestamp).toDate();

      // Generar ID único basado en el documento y timestamp
      final String docId = doc.id;
      final int baseId = docId.hashCode.abs() % 100000;

      // Alerta de gas
      if (data['nivelGas'] != null && data['nivelGas'] == 'alto') {
        newAlerts.add(Alert(
          id: baseId + 1,
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
        newAlerts.add(Alert(
          id: baseId + 2,
          type: 'Intrusos',
          message: 'Movimiento detectado cuando no hay nadie en casa',
          timestamp: timestamp,
          severity: 'Alto',
          location: 'Puerta trasera',
        ));
      }

      // Alerta de temperatura alta
      if (data['temperatura'] != null && data['temperatura'] > 28) {
        newAlerts.add(Alert(
          id: baseId + 3,
          type: 'Temperatura',
          message: 'Temperatura elevada detectada',
          timestamp: timestamp,
          severity: 'Medio',
          location: 'Sala de estar',
        ));
      }

      // Alerta de agua (ejemplo adicional)
      if (data['nivelAgua'] != null && data['nivelAgua'] == 'alto') {
        newAlerts.add(Alert(
          id: baseId + 4,
          type: 'Agua',
          message: 'Nivel de agua elevado detectado',
          timestamp: timestamp,
          severity: 'Alto',
          location: 'Sótano',
        ));
      }
    }

    // Actualizar la lista de alertas
    _updateAlerts(newAlerts);
  }

  // Actualizar la lista de alertas evitando duplicados
  void _updateAlerts(List<Alert> newAlerts) {
    _alerts.clear();
    _alerts.addAll(newAlerts);

    // Ordenar por timestamp (más recientes primero)
    _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    notifyListeners();
  }

  // Método para recargar manualmente las alertas
  Future<void> refreshAlerts() async {
    try {
      // El stream ya se encarga de mantener los datos actualizados
      // Este método puede ser útil para forzar una actualización si es necesario
      debugPrint('Alertas actualizándose automáticamente...');
    } catch (e) {
      debugPrint('Error al refrescar alertas: $e');
    }
  }

  // Método para pausar la escucha (útil para optimización)
  void pauseListening() {
    _alertsSubscription?.pause();
  }

  // Método para reanudar la escucha
  void resumeListening() {
    _alertsSubscription?.resume();
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }
}
// Agregar estas clases auxiliares al final del archivo, antes del AlertsProvider

class RiskAnalyzer {
  // Pesos de riesgo por tipo de alerta
  static const Map<String, double> _alertTypeWeights = {
    'Gas': 4.0,           // Muy peligroso - riesgo de explosión/intoxicación
    'Intrusos': 3.5,      // Alto riesgo de seguridad
    'Agua': 3.0,          // Puede causar daños estructurales
    'Temperatura': 2.0,   // Menos crítico, más relacionado con confort
  };

  // Multiplicadores por severidad
  static const Map<String, double> _severityMultipliers = {
    'Alto': 3.0,
    'Medio': 2.0,
    'Bajo': 1.0,
  };

  // Umbrales de clasificación
  static const double _criticalThreshold = 15.0;
  static const double _highThreshold = 10.0;
  static const double _mediumThreshold = 5.0;

  static String calculateIntelligentRisk(List<Alert> alerts) {
    if (alerts.isEmpty) return 'Sin riesgo';

    double totalRiskScore = 0.0;

    // Calcular riesgo individual de cada alerta
    for (Alert alert in alerts) {
      double alertRisk = 0.0;

      // Peso base según el tipo de alerta
      alertRisk += _alertTypeWeights[alert.type] ?? 1.0;

      // Multiplicador por severidad
      final severityMultiplier = _severityMultipliers[alert.severity] ?? 1.0;
      alertRisk *= severityMultiplier;

      // Multiplicador por tiempo (alertas más recientes son más críticas)
      final timeMultiplier = _getTimeMultiplier(alert.timestamp);
      alertRisk *= timeMultiplier;

      // Bonificación por ubicación crítica
      alertRisk += _getLocationRiskBonus(alert.location, alert.type);

      totalRiskScore += alertRisk;
    }

    // Añadir riesgo por combinaciones peligrosas
    totalRiskScore += _getCombinationRisk(alerts);

    // Clasificar según el puntaje total
    if (totalRiskScore >= _criticalThreshold) return 'Crítico';
    if (totalRiskScore >= _highThreshold) return 'Alto';
    if (totalRiskScore >= _mediumThreshold) return 'Medio';
    return 'Bajo';
  }

  // Multiplicador por tiempo (alertas más recientes son más críticas)
  static double _getTimeMultiplier(DateTime alertTime) {
    final now = DateTime.now();
    final difference = now.difference(alertTime);

    if (difference.inMinutes <= 5) return 2.0;   // Muy reciente
    if (difference.inMinutes <= 30) return 1.5;  // Reciente
    if (difference.inHours <= 2) return 1.2;    // Relativamente reciente
    if (difference.inHours <= 6) return 1.0;    // Normal
    return 0.7; // Más antigua, menos crítica
  }

  // Bonificación de riesgo por ubicación
  static double _getLocationRiskBonus(String location, String alertType) {
    final Map<String, Map<String, double>> locationRisks = {
      'Cocina': {
        'Gas': 2.0,        // Gas en cocina es muy peligroso
        'Temperatura': 1.5, // Sobrecalentamiento en cocina
        'Agua': 1.0,       // Filtración en cocina
      },
      'Sótano': {
        'Agua': 2.0,       // Inundación en sótano es crítica
        'Gas': 1.5,        // Gas acumulado en sótano
        'Intrusos': 1.0,   // Acceso por sótano
      },
      'Puerta trasera': {
        'Intrusos': 2.0,   // Intrusión por puerta trasera
      },
      'Sala de estar': {
        'Temperatura': 1.0, // Sobrecalentamiento general
        'Intrusos': 1.5,   // Intrusos en área principal
      },
    };

    return locationRisks[location]?[alertType] ?? 0.0;
  }

  // Analizar combinaciones peligrosas
  static double _getCombinationRisk(List<Alert> alerts) {
    final Set<String> alertTypes = alerts.map((a) => a.type).toSet();
    double combinationBonus = 0.0;

    // Gas + Temperatura = Muy peligroso (riesgo de explosión)
    if (alertTypes.contains('Gas') && alertTypes.contains('Temperatura')) {
      combinationBonus += 5.0;
    }

    // Intrusos + Gas = Situación muy crítica
    if (alertTypes.contains('Intrusos') && alertTypes.contains('Gas')) {
      combinationBonus += 4.0;
    }

    // Agua + Temperatura = Posible problema eléctrico
    if (alertTypes.contains('Agua') && alertTypes.contains('Temperatura')) {
      combinationBonus += 3.0;
    }

    // Múltiples alertas del mismo tipo aumentan el riesgo
    for (String type in alertTypes) {
      final count = alerts.where((a) => a.type == type).length;
      if (count > 1) {
        combinationBonus += (count - 1) * 1.5;
      }
    }

    return combinationBonus;
  }
}

