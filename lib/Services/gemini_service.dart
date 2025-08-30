import 'package:flutter_gemini/flutter_gemini.dart';

import '../providers/AlertsProvider.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBpKE8T8J-PIFlg2cUtWCBBBfSCzYHIkWk';
  static Gemini? _instance;

  static void initialize() {
    Gemini.init(apiKey: _apiKey);
    _instance = Gemini.instance;
  }

  static Future<String> getRecommendations(List<Alert> alerts, String riskLevel) async {
    if (_instance == null) {
      initialize();
    }

    try {
      // Construir el contexto de las alertas
      final alertContext = _buildAlertContext(alerts, riskLevel);

      // Crear el prompt para Gemini
      final prompt = _buildPrompt(alertContext);

      // Llamar a Gemini
      final response = await _instance!.text(prompt);

      return response?.output ?? 'No se pudo generar recomendación en este momento.';
    } catch (e) {
      print('Error al obtener recomendaciones de Gemini: $e');
      return 'Error al conectar con el servicio de IA. Intente más tarde.';
    }
  }

  static String _buildAlertContext(List<Alert> alerts, String riskLevel) {
    if (alerts.isEmpty) {
      return 'No hay alertas activas. Sistema funcionando normalmente.';
    }

    StringBuffer context = StringBuffer();
    context.writeln('NIVEL DE RIESGO ACTUAL: $riskLevel');
    context.writeln('TOTAL DE ALERTAS: ${alerts.length}');
    context.writeln('\\nDETALLE DE ALERTAS:');

    // Agrupar alertas por tipo
    Map<String, List<Alert>> alertsByType = {};
    for (var alert in alerts) {
      alertsByType.putIfAbsent(alert.type, () => []).add(alert);
    }

    // Describir cada tipo de alerta
    alertsByType.forEach((type, typeAlerts) {
      context.writeln('\\n$type (${typeAlerts.length} alertas):');
      for (var alert in typeAlerts.take(3)) { // Máximo 3 por tipo para no saturar
        final timeAgo = _getTimeAgo(alert.timestamp);
        context.writeln('- ${alert.message} (${alert.severity},S}, $timeAgo)');
      }
    });

    // Añadir patrones detectados
    context.writeln('\\nPATRONES DETECTADOS:');
    if (alertsByType.containsKey('Gas') && alertsByType.containsKey('Temperatura')) {
      context.writeln('- Combinación Gas + Temperatura detectada (CRÍTICO)');
    }
    if (alertsByType.values.any((list) => list.length > 1)) {
      context.writeln('- Múltiples alertas del mismo tipo');
    }

    final recentAlerts = alerts.where((a) =>
    DateTime.now().difference(a.timestamp).inHours <= 1).length;
    if (recentAlerts > 0) {
      context.writeln('- $recentAlerts alertas en la última hora');
    }

    return context.toString();
  }

  static String _buildPrompt(String alertContext) {
    return '''
Eres un experto en seguridad doméstica y sistemas de monitoreo ambiental. 
Analiza la siguiente información de alertas de un sistema de hogar inteligente y proporciona recomendaciones específicas, prácticas y urgentes.

INFORMACIÓN DEL SISTEMA:
$alertContext

INSTRUCCIONES:
1. Analiza el nivel de riesgo y las alertas presentes
2. Identifica los problemas más críticos
3. Proporciona entre 2-4 recomendaciones específicas y accionables
4. Usa un tono profesional pero comprensible
5. Prioriza la seguridad personal
6. Incluye acciones inmediatas y de prevención
7. Mantén las recomendaciones concisas (máximo 2 líneas cada una)

FORMATO DE RESPUESTA:
• [Recomendación inmediata 1]
• [Recomendación inmediata 2]  
• [Recomendación preventiva 1]
• [Recomendación preventiva 2] (si aplica)

No incluyas introducción ni conclusión, solo las recomendaciones marcadas con viñetas.
''';
  }

  static String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'ahora mismo';
    if (difference.inMinutes < 60) return 'hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'hace ${difference.inHours}h';
    return 'hace ${difference.inDays} días';
  }
}