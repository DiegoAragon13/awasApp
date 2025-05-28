import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chart_data.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener todos los documentos de monitoreo ambiental
  static Future<List<Map<String, dynamic>>> getMonitoringData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('monitorAmbiental')
          .orderBy('fecha', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener datos: $e');
      return [];
    }
  }

  // Obtener datos de los últimos 7 días
  static Future<List<Map<String, dynamic>>> getLastWeekData() async {
    try {
      DateTime now = DateTime.now();
      DateTime weekAgo = now.subtract(Duration(days: 7));

      QuerySnapshot querySnapshot = await _firestore
          .collection('monitorAmbiental')
          .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .orderBy('fecha', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener datos de la semana: $e');
      return [];
    }
  }

  // Escuchar cambios en tiempo real
  static Stream<List<Map<String, dynamic>>> getRealtimeData() {
    return _firestore
        .collection('monitorAmbiental')
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}