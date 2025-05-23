import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../models/chart_data.dart';

class AnalyticsChartCarousel extends StatefulWidget {
  const AnalyticsChartCarousel({super.key});

  @override
  State<AnalyticsChartCarousel> createState() => _AnalyticsChartCarouselState();
}

class _AnalyticsChartCarouselState extends State<AnalyticsChartCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Stream para escuchar cambios en tiempo real
  late Stream<QuerySnapshot> _firestoreStream;

  @override
  void initState() {
    super.initState();
    // Configurar el stream para escuchar cambios en tiempo real
    _firestoreStream = FirebaseFirestore.instance
        .collection('monitorAmbiental')
        .orderBy('fecha', descending: true)
        .limit(30)
        .snapshots();
  }

  List<ChartConfig> _procesarDatosFirestore(QuerySnapshot snapshot) {
    List<ChartData> gasData = [];
    List<ChartData> temperaturaData = [];
    List<ChartData> movimientoData = [];
    List<ChartData> movimientoDataHoy = []; // Nueva lista para movimiento del día actual

    // Obtener fecha de hoy (solo día, mes y año)
    final DateTime hoy = DateTime.now();
    final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final DateTime finHoy = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

    // Debug: Agregar print para verificar datos
    print("Documentos recibidos: ${snapshot.docs.length}");
    print("Filtrando movimiento para hoy: ${DateFormat('yyyy-MM-dd').format(hoy)}");

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['fecha'] as Timestamp).toDate();

      // Debug: Imprimir datos de movimiento
      print("Documento: ${doc.id}");
      print("Movimiento: ${data['movimiento']}");
      print("Timestamp: $timestamp");

      // Agregar datos normales para gas y temperatura (todos los registros)
      gasData.add(ChartData(timestamp, (data['gas'] ?? 0).toDouble()));
      temperaturaData.add(ChartData(timestamp, (data['temperatura'] ?? 0).toDouble()));

      // CORRECCIÓN: Lógica mejorada para detectar movimiento según tu estructura de Firebase
      final movimientoRaw = data['movimiento'];
      double movimientoValue = 0.0;

      if (movimientoRaw != null) {
        final movimientoStr = movimientoRaw.toString().toLowerCase().trim();
        print("Valor de movimiento (lowercase): '$movimientoStr'");

        // Verificar los valores específicos de tu Firebase
        if (movimientoStr == 'movimiento detectado' ||
            movimientoStr.contains('movimiento detectado')) {
          movimientoValue = 1.0;
          print("Movimiento detectado - asignando 1.0");
        } else if (movimientoStr == 'sin movimiento' ||
            movimientoStr.contains('sin movimiento')) {
          movimientoValue = 0.0;
          print("Sin movimiento - asignando 0.0");
        } else {
          // Fallback: verificar otras variantes comunes
          if (movimientoStr.contains('detectado') ||
              movimientoStr.contains('si') ||
              movimientoStr.contains('sí') ||
              movimientoStr.contains('yes') ||
              movimientoStr.contains('true') ||
              movimientoStr == '1') {
            movimientoValue = 1.0;
          } else if (movimientoStr.contains('no') ||
              movimientoStr.contains('false') ||
              movimientoStr == '0') {
            movimientoValue = 0.0;
          } else {
            // Si es un número, intentar parsearlo
            movimientoValue = double.tryParse(movimientoStr) ?? 0.0;
            movimientoValue = movimientoValue > 0 ? 1.0 : 0.0;
          }
        }
      }

      // Agregar a la lista completa de movimiento
      movimientoData.add(ChartData(timestamp, movimientoValue));

      // FILTRAR: Solo agregar a movimientoDataHoy si es del día actual
      if (timestamp.isAfter(inicioHoy.subtract(Duration(milliseconds: 1))) &&
          timestamp.isBefore(finHoy.add(Duration(milliseconds: 1)))) {
        movimientoDataHoy.add(ChartData(timestamp, movimientoValue));
        print("Registro del día actual agregado: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp)} - Valor: $movimientoValue");
      }

      print("Valor final procesado: $movimientoValue");
    }

    // Debug: Verificar datos procesados
    print("Datos de movimiento totales procesados: ${movimientoData.length}");
    print("Datos de movimiento del día actual: ${movimientoDataHoy.length}");
    print("Datos con movimiento detectado hoy: ${movimientoDataHoy.where((d) => d.value == 1.0).length}");
    print("Datos sin movimiento hoy: ${movimientoDataHoy.where((d) => d.value == 0.0).length}");

    for (var data in movimientoDataHoy.take(5)) { // Solo los primeros 5 para debug
      print("Hoy - Timestamp: ${data.timestamp}, Value: ${data.value}");
    }

    // Solo generar datos de prueba si realmente no hay datos del día actual
    if (movimientoDataHoy.isEmpty) {
      print("No hay datos de movimiento para hoy, generando datos de prueba para el día actual");
      movimientoDataHoy = _generarDatosMovimientoPruebaHoy();
    } else {
      print("Se encontraron ${movimientoDataHoy.length} registros de movimiento reales para hoy");
    }

    // Generar datos simulados para sensores adicionales
    List<ChartData> vibracionData = _generarDatosVibracion();
    List<ChartData> sonidoData = _generarDatosSonido();
    List<ChartData> humedadData = _generarDatosHumedad();

    // Ordenar datos cronológicamente para mejor visualización
    gasData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    temperaturaData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    movimientoDataHoy.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Ordenar datos del día actual

    return [
      ChartConfig(
        title: 'Nivel de Gas',
        subtitle: 'Concentración de gas detectada',
        color: const Color(0xFF4CAF50),
        gradientColor: const Color(0xFF81C784),
        data: gasData,
        unit: 'ppm',
        chartType: ChartType.area,
      ),
      ChartConfig(
        title: 'Temperatura',
        subtitle: 'Temperatura ambiente',
        color: const Color(0xFFFF6B35),
        gradientColor: const Color(0xFFFFAB91),
        data: temperaturaData,
        unit: '°C',
        chartType: ChartType.spline,
      ),
      ChartConfig(
        title: 'Detección de Movimiento',
        subtitle: 'Actividad del sensor PIR - Hoy', // Actualizar subtítulo
        color: const Color(0xFF2196F3),
        gradientColor: const Color(0xFF64B5F6),
        data: movimientoDataHoy, // USAR DATOS SOLO DEL DÍA ACTUAL
        unit: '',
        chartType: ChartType.column,
      ),
      ChartConfig(
        title: 'Vibración',
        subtitle: 'Nivel de vibraciones detectadas',
        color: const Color(0xFF9C27B0),
        gradientColor: const Color(0xFFBA68C8),
        data: vibracionData,
        unit: 'Hz',
        chartType: ChartType.spline,
      ),
      ChartConfig(
        title: 'Nivel de Sonido',
        subtitle: 'Intensidad de ruido ambiente',
        color: const Color(0xFFFF9800),
        gradientColor: const Color(0xFFFFCC02),
        data: sonidoData,
        unit: 'dB',
        chartType: ChartType.area,
      ),
      ChartConfig(
        title: 'Humedad',
        subtitle: 'Humedad relativa del ambiente',
        color: const Color(0xFF00BCD4),
        gradientColor: const Color(0xFF4DD0E1),
        data: humedadData,
        unit: '%',
        chartType: ChartType.spline,
      ),
    ];
  }

  // Método modificado para generar datos de prueba solo del día actual
  List<ChartData> _generarDatosMovimientoPruebaHoy() {
    List<ChartData> data = [];
    final DateTime hoy = DateTime.now();
    final DateTime inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final random = Random();

    // Generar datos cada hora desde las 00:00 hasta la hora actual
    for (int i = 0; i <= hoy.hour; i++) {
      final timestamp = inicioHoy.add(Duration(hours: i));
      // Simular detección de movimiento aleatoria (20% de probabilidad)
      double movimiento = random.nextDouble() < 0.2 ? 1.0 : 0.0;
      data.add(ChartData(timestamp, movimiento));
    }

    print("Datos de prueba generados para hoy: ${data.length} registros");
    return data;
  }

  // Agregar este método para generar datos de prueba (mantener el original)
  List<ChartData> _generarDatosMovimientoPrueba() {
    List<ChartData> data = [];
    final now = DateTime.now();
    final random = Random();

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Simular detección de movimiento aleatoria (20% de probabilidad)
      double movimiento = random.nextDouble() < 0.2 ? 1.0 : 0.0;
      data.add(ChartData(timestamp, movimiento));
    }

    return data;
  }

  // Generar datos simulados para vibración (0-50 Hz)
  List<ChartData> _generarDatosVibracion() {
    List<ChartData> data = [];
    final now = DateTime.now();
    final random = Random();

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Simular vibraciones con picos ocasionales
      double baseVibration = 5 + random.nextDouble() * 8; // 5-13 Hz base
      if (random.nextDouble() < 0.15) {
        baseVibration += random.nextDouble() * 25; // Picos hasta 38 Hz
      }
      data.add(ChartData(timestamp, baseVibration));
    }

    return data;
  }

  // Generar datos simulados para sonido (30-90 dB)
  List<ChartData> _generarDatosSonido() {
    List<ChartData> data = [];
    final now = DateTime.now();
    final random = Random();

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Simular niveles de sonido con variaciones naturales
      double baseSonido = 35 + random.nextDouble() * 20; // 35-55 dB base

      // Simular picos de ruido durante ciertas horas
      final hour = timestamp.hour;
      if (hour >= 7 && hour <= 22) {
        baseSonido += random.nextDouble() * 25; // Más ruido durante el día
      }

      data.add(ChartData(timestamp, baseSonido.clamp(30, 90)));
    }

    return data;
  }

  // Generar datos simulados para humedad (20-80%)
  List<ChartData> _generarDatosHumedad() {
    List<ChartData> data = [];
    final now = DateTime.now();
    final random = Random();

    for (int i = 29; i >= 0; i--) {
      final timestamp = now.subtract(Duration(hours: i));
      // Simular humedad con variaciones graduales
      double baseHumedad = 45 + random.nextDouble() * 25; // 45-70% base

      // Variaciones según la hora (más humedad en la madrugada)
      final hour = timestamp.hour;
      if (hour >= 2 && hour <= 6) {
        baseHumedad += random.nextDouble() * 10; // Mayor humedad en la madrugada
      }

      data.add(ChartData(timestamp, baseHumedad.clamp(20, 80)));
    }

    return data;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getLatestValue(List<ChartData> data, String unit) {
    if (data.isEmpty) return 'N/A';
    final latest = data.last.value;
    if (unit.isEmpty) {
      return latest == 1.0 ? 'SÍ' : 'NO';
    }
    return '${latest.toStringAsFixed(1)} $unit';
  }

  String _getAverageValue(List<ChartData> data, String unit) {
    if (data.isEmpty) return 'N/A';
    final average = data.map((e) => e.value).reduce((a, b) => a + b) / data.length;
    if (unit.isEmpty) {
      final detectionRate = (average * 100).toStringAsFixed(0);
      return '$detectionRate%';
    }
    return '${average.toStringAsFixed(1)}$unit';
  }

  Widget _buildChart(ChartConfig chart) {
    switch (chart.chartType) {
      case ChartType.area:
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('HH:mm'),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: MajorGridLines(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.all(8),
          series: <CartesianSeries<ChartData, DateTime>>[
            AreaSeries<ChartData, DateTime>(
              dataSource: chart.data,
              xValueMapper: (ChartData data, _) => data.timestamp,
              yValueMapper: (ChartData data, _) => data.value,
              color: chart.color.withOpacity(0.3),
              borderColor: chart.color,
              borderWidth: 2,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  chart.color.withOpacity(0.4),
                  chart.color.withOpacity(0.1),
                ],
              ),
            ),
          ],
        );

      case ChartType.spline:
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('HH:mm'),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: MajorGridLines(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.all(8),
          series: <CartesianSeries<ChartData, DateTime>>[
            SplineSeries<ChartData, DateTime>(
              dataSource: chart.data,
              xValueMapper: (ChartData data, _) => data.timestamp,
              yValueMapper: (ChartData data, _) => data.value,
              color: chart.color,
              width: 3,
              markerSettings: MarkerSettings(
                isVisible: true,
                height: 4,
                width: 4,
                color: chart.color,
                borderColor: Colors.white,
                borderWidth: 1,
              ),
            ),
          ],
        );

      case ChartType.column:
      default:
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('HH:mm'),
            // Mejorar el espaciado para gráficas de columnas
            maximumLabels: 8,
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            majorGridLines: MajorGridLines(
              width: 0.5,
              color: Colors.grey.withOpacity(0.3),
            ),
            labelStyle: const TextStyle(fontSize: 10, color: Colors.grey),
            minimum: 0,
            maximum: 1.2,
            // Personalizar las etiquetas del eje Y para movimiento
            labelFormat: '{value}',
            interval: 0.5,
          ),
          plotAreaBorderWidth: 0,
          margin: const EdgeInsets.all(8),
          series: <CartesianSeries<ChartData, DateTime>>[
            ColumnSeries<ChartData, DateTime>(
              dataSource: chart.data,
              xValueMapper: (ChartData data, _) => data.timestamp,
              yValueMapper: (ChartData data, _) => data.value,
              width: 0.8, // Aumentar el ancho de las columnas
              spacing: 0.1, // Reducir el espaciado entre columnas
              color: chart.color,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [chart.color, chart.gradientColor],
              ),
              // Agregar etiquetas de datos para mejor visualización
              dataLabelSettings: const DataLabelSettings(
                isVisible: false, // Puedes cambiar a true si quieres mostrar los valores
              ),
            ),
          ],
          // Mejorar el tooltip para gráficas de movimiento
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.x : point.y',
            header: '',
            canShowMarker: false,
          ),
        );
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? theme.colorScheme.surface
        : Colors.white;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando datos...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? theme.colorScheme.surface
        : Colors.white;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Forzar reconstrucción del StreamBuilder
                });
              },
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsContent(List<ChartConfig> charts, BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? theme.colorScheme.surface
        : Colors.white;
    final cardColor = isDarkMode
        ? theme.colorScheme.surfaceVariant
        : const Color(0xFFFAFAFA);

    return Column(
      children: [
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: charts.length,
            itemBuilder: (context, index) {
              final chart = charts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con título y estadísticas
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      chart.title,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: chart.color,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Indicador de actualización en tiempo real
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chart.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Actual',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getLatestValue(chart.data, chart.unit),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: chart.color,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getAverageValue(chart.data, chart.unit),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Gráfica
                    Expanded(
                      child: _buildChart(chart),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores de página mejorados
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicator(context, charts),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreStream,
      builder: (context, snapshot) {
        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        // Estado de error
        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        // Estado sin datos
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildErrorState(context, 'No hay datos disponibles');
        }

        // Procesar datos y construir gráficas
        final charts = _procesarDatosFirestore(snapshot.data!);
        return _buildChartsContent(charts, context);
      },
    );
  }

  List<Widget> _buildPageIndicator(BuildContext context, List<ChartConfig> charts) {
    return List<Widget>.generate(charts.length, (index) {
      final isActive = index == _currentPage;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isActive ? 20 : 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isActive
              ? charts[index].color
              : Colors.grey.withOpacity(0.3),
        ),
      );
    });
  }
}

// Enum para tipos de gráficas
enum ChartType { area, spline, column }

// Clase de configuración extendida
class ChartConfig {
  final String title;
  final String subtitle;
  final Color color;
  final Color gradientColor;
  final List<ChartData> data;
  final String unit;
  final ChartType chartType;

  ChartConfig({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradientColor,
    required this.data,
    required this.unit,
    required this.chartType,
  });
}