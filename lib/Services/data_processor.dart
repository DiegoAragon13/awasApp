import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chart_data.dart';
import 'package:awas_app/Services/firebase_service.dart';

class DataProcessor {
  static Future<List<ChartData>> processTemperatureData() async {
    List<Map<String, dynamic>> rawData = await FirebaseService.getLastWeekData();
    return _processData(rawData, 'temperatura');
  }

  static Future<List<ChartData>> processGasData() async {
    List<Map<String, dynamic>> rawData = await FirebaseService.getLastWeekData();
    return _processData(rawData, 'gas');
  }

  static Future<List<ChartData>> processMovementData() async {
    List<Map<String, dynamic>> rawData = await FirebaseService.getLastWeekData();
    return _processMovementData(rawData);
  }

  static List<ChartData> _processData(List<Map<String, dynamic>> rawData, String field) {
    Map<String, List<double>> dailyValues = {};

    for (var item in rawData) {
      try {
        Timestamp timestamp = item['fecha'];
        DateTime date = timestamp.toDate();
        String dayKey = '${date.year}-${date.month}-${date.day}';

        double value = 0.0;
        if (field == 'temperatura') {
          value = (item[field] ?? 0.0).toDouble();
        } else if (field == 'gas') {
          value = (item[field] ?? 0).toDouble();
        }

        if (!dailyValues.containsKey(dayKey)) {
          dailyValues[dayKey] = [];
        }
        dailyValues[dayKey]!.add(value);
      } catch (e) {
        print('Error procesando dato: $e');
      }
    }

    // Crear datos para los últimos 7 días
    List<ChartData> chartData = [];
    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String dayKey = '${day.year}-${day.month}-${day.day}';

      double averageValue = 0.0;
      if (dailyValues.containsKey(dayKey) && dailyValues[dayKey]!.isNotEmpty) {
        averageValue = dailyValues[dayKey]!.reduce((a, b) => a + b) / dailyValues[dayKey]!.length;
      }

      chartData.add(ChartData(day, averageValue));
    }

    return chartData;
  }

  static List<ChartData> _processMovementData(List<Map<String, dynamic>> rawData) {
    Map<String, int> dailyMovements = {};

    for (var item in rawData) {
      try {
        Timestamp timestamp = item['fecha'];
        DateTime date = timestamp.toDate();
        String dayKey = '${date.year}-${date.month}-${date.day}';

        String movementStr = item['movimiento'] ?? 'sin movimiento';
        bool hasMovement = movementStr.contains('detectado');

        if (!dailyMovements.containsKey(dayKey)) {
          dailyMovements[dayKey] = 0;
        }
        if (hasMovement) {
          dailyMovements[dayKey] = dailyMovements[dayKey]! + 1;
        }
      } catch (e) {
        print('Error procesando movimiento: $e');
      }
    }

    // Crear datos para los últimos 7 días
    List<ChartData> chartData = [];
    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String dayKey = '${day.year}-${day.month}-${day.day}';

      double movementCount = (dailyMovements[dayKey] ?? 0).toDouble();
      chartData.add(ChartData(day, movementCount));
    }

    return chartData;
  }
}