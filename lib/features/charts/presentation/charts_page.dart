import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../shared/data/services/firebase_data_service.dart';
import '../../../shared/data/services/simulated_data_service.dart';
import '../../../shared/domain/domain.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  List<WaterStation> _stations = [];
  String _selectedStationId = '';
  String _selectedParameter = 'pH';
  String _selectedPeriod = '24h'; // 24h, 7d, 30d, 90d
  final List<Map<String, dynamic>> _historicalData = [];
  bool _isLoading = true;
  final _firebaseData = FirebaseDataService();

  final List<String> _parameters = ['pH', 'tds', 'turbidity', 'chlorine_residual'];
  final Map<String, String> _parameterLabels = {
    'pH': 'pH',
    'tds': 'TDS (mg/L)',
    'turbidity': 'Turbidez (UNT)',
    'chlorine_residual': 'Cloro Residual (mg/L)',
  };

  final Map<String, String> _periodLabels = {
    '24h': 'Últimas 24 horas',
    '7d': 'Últimos 7 días',
    '30d': 'Últimos 30 días',
    '90d': 'Últimos 90 días',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load stations
    _stations = SimulatedDataService.createDefaultStations();
    if (_stations.isNotEmpty && _selectedStationId.isEmpty) {
      _selectedStationId = _stations.first.id;
    }

    // Generate historical data
    await _generateHistoricalData();

    setState(() => _isLoading = false);
  }

  Future<void> _generateHistoricalData() async {
    _historicalData.clear();

    // Mostrar indicador de carga mientras procesa
    setState(() => _isLoading = true);

    // Calcular el período de tiempo
    final Duration duration;
    final int estimatedReadings;
    
    switch (_selectedPeriod) {
      case '24h':
        duration = const Duration(hours: 24);
        estimatedReadings = 48; // ~cada 30 min
        break;
      case '7d':
        duration = const Duration(days: 7);
        estimatedReadings = 336; // 7 * 48
        break;
      case '30d':
        duration = const Duration(days: 30);
        estimatedReadings = 1440; // 30 * 48
        break;
      case '90d':
        duration = const Duration(days: 90);
        estimatedReadings = 4320; // 90 * 48
        break;
      default:
        duration = const Duration(days: 7);
        estimatedReadings = 336;
    }
    
    // Try to load from Firebase first (cloud-first strategy)
    final now = DateTime.now();
    final startDate = now.subtract(duration);
    
    print('📅 Fetching data from Firebase');
    print('   Período: $_selectedPeriod');
    print('   Start: ${startDate.toIso8601String()}');
    print('   End: ${now.toIso8601String()}');
    print('   Station: $_selectedStationId');
    
    // Obtener TODOS los datos sin límite para poder muestrear correctamente
    var readings = await _firebaseData.getHistoricalReadings(
      stationId: _selectedStationId,
      startDate: startDate,
      endDate: now,
      limit: 10000, // Límite alto para obtener todos los datos del período
    );

    // Si tenemos demasiados datos, aplicar muestreo inteligente
    // Para gráficos más fluidos, limitar a máximo 100 puntos
    if (readings.isNotEmpty) {
      final maxPoints = _selectedPeriod == '24h' ? 50 : estimatedReadings;
      if (readings.length > maxPoints) {
        readings = _sampleReadings(readings, maxPoints);
      }
    }

    // Convert to chart data (invertir orden para que el gráfico vaya de antiguo a reciente)
    // readings ya está ordenado de más reciente a más antiguo, necesitamos revertir
    final reversedReadings = readings.reversed.toList();
    
    for (final reading in reversedReadings) {
      _historicalData.add({
        'date': reading.timestamp,
        'pH': reading.parameters['pH'] ?? 7.0,
        'tds': reading.parameters['tds'] ?? 500,
        'turbidity': reading.parameters['turbidity'] ?? 2.0,
        'chlorine_residual': reading.parameters['chlorine_residual'] ?? 1.0,
      });
    }
    
    setState(() => _isLoading = false);
  }

  /// Muestrear lecturas manteniendo distribución uniforme en el tiempo
  List<WaterQualityReading> _sampleReadings(
    List<WaterQualityReading> readings,
    int targetCount,
  ) {
    if (readings.length <= targetCount) return readings;

    // Estrategia: tomar muestras uniformemente distribuidas
    final sampled = <WaterQualityReading>[];
    final step = readings.length / targetCount;

    for (int i = 0; i < targetCount; i++) {
      final index = (i * step).floor();
      if (index < readings.length) {
        sampled.add(readings[index]);
      }
    }

    return sampled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.show_chart, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gráficos Históricos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Análisis de tendencias',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Station selector
              DropdownButtonFormField<String>(
                initialValue: _selectedStationId.isNotEmpty ? _selectedStationId : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Estación',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _stations.map((station) {
                  return DropdownMenuItem(
                    value: station.id,
                    child: Text(
                      station.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      _selectedStationId = value;
                      _isLoading = true;
                    });
                    await _generateHistoricalData();
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Period and parameter selectors
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPeriod,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Período',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _periodLabels.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setState(() {
                            _selectedPeriod = value;
                            _isLoading = true;
                          });
                          await _generateHistoricalData();
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedParameter,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Parámetro',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _parameters.map((param) {
                        return DropdownMenuItem(
                          value: param,
                          child: Text(
                            _parameterLabels[param] ?? param,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedParameter = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chart content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Line chart
                      _buildLineChart(),
                      const SizedBox(height: 24),

                      // Stats cards
                      _buildStatsCards(),
                      const SizedBox(height: 24),

                      // All parameters comparison
                      _buildAllParametersChart(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    if (_historicalData.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('No hay datos disponibles')),
      );
    }

    final spots = <FlSpot>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < _historicalData.length; i++) {
      final value = _historicalData[i][_selectedParameter] as double;
      spots.add(FlSpot(i.toDouble(), value));
      if (value < minY) minY = value;
      if (value > maxY) maxY = value;
    }

    // Add padding to Y axis (more for large values like TDS)
    final range = maxY - minY;
    
    // Si todos los valores son iguales (range = 0), usar un rango por defecto
    if (range == 0) {
      final baseValue = maxY;
      minY = math.max(0, baseValue - 1);
      maxY = baseValue + 1;
    } else {
      final yPadding = range > 100 ? range * 0.15 : range * 0.25;
      minY = math.max(0, minY - yPadding);
      maxY = maxY + yPadding;
    }

    // Get standard limits
    final standards = AppConstants.waterQualityStandards[_selectedParameter];
    final minLimit = standards?['min'];
    final maxLimit = standards?['max'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _parameterLabels[_selectedParameter] ?? _selectedParameter,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tendencia: ${_periodLabels[_selectedPeriod]}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: math.max(0.1, (maxY - minY) / 5),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _historicalData.length > 6 ? (_historicalData.length / 6).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _historicalData.length) {
                            final date = _historicalData[index]['date'] as DateTime;
                            
                            // Para 24h mostrar hora, para otros períodos mostrar día/mes
                            if (_selectedPeriod == '24h') {
                              final hour = date.hour;
                              final period = hour >= 12 ? 'pm' : 'am';
                              final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '$displayHour$period',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: spots.length <= 30,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                  // Reference lines for limits
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      if (minLimit != null)
                        HorizontalLine(
                          y: minLimit,
                          color: Colors.orange,
                          strokeWidth: 1.5,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            style: const TextStyle(fontSize: 10, color: Colors.orange),
                            labelResolver: (line) => 'Mín: ${minLimit.toStringAsFixed(1)}',
                          ),
                        ),
                      if (maxLimit != null)
                        HorizontalLine(
                          y: maxLimit,
                          color: Colors.red,
                          strokeWidth: 1.5,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(right: 5, top: 5),
                            style: const TextStyle(fontSize: 10, color: Colors.red),
                            labelResolver: (line) => 'Máx: ${maxLimit.toStringAsFixed(1)}',
                          ),
                        ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = _historicalData[spot.x.toInt()]['date'] as DateTime;
                          return LineTooltipItem(
                            '${date.day}/${date.month}\n${spot.y.toStringAsFixed(2)}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Legend
            if (minLimit != null || maxLimit != null)
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (minLimit != null)
                    _buildLegendItem('Límite Mínimo', Colors.orange, isDashed: true),
                  if (maxLimit != null)
                    _buildLegendItem('Límite Máximo', Colors.red, isDashed: true),
                  _buildLegendItem('Valores medidos', AppTheme.primaryColor),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            border: isDashed ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    if (_historicalData.isEmpty) return const SizedBox.shrink();

    final values = _historicalData
        .map((data) => data[_selectedParameter] as double)
        .toList();

    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);

    // Calculate trend
    final firstValue = values.first;
    final lastValue = values.last;
    final trend = lastValue - firstValue;
    final trendPercent = (trend / firstValue) * 100;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: _buildStatCard(
              'Promedio',
              avg.toStringAsFixed(2),
              Icons.analytics_outlined,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: _buildStatCard(
              'Mínimo',
              min.toStringAsFixed(2),
              Icons.arrow_downward,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: _buildStatCard(
              'Máximo',
              max.toStringAsFixed(2),
              Icons.arrow_upward,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: _buildStatCard(
              'Tendencia',
              '${trendPercent >= 0 ? '+' : ''}${trendPercent.toStringAsFixed(1)}%',
              trendPercent >= 0 ? Icons.trending_up : Icons.trending_down,
              trendPercent >= 0 ? Colors.orange : Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllParametersChart() {
    if (_historicalData.isEmpty) return const SizedBox.shrink();

    // Calculate average for each parameter
    final averages = <String, double>{};
    for (final param in _parameters) {
      final values = _historicalData.map((data) => data[param] as double).toList();
      averages[param] = values.reduce((a, b) => a + b) / values.length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparación de Parámetros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Promedios del período (TDS normalizado x0.01)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxYForComparison(averages),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final param = _parameters[group.x.toInt()];
                        final rawValue = averages[param] ?? 0;
                        return BarTooltipItem(
                          '${_parameterLabels[param]}\n${rawValue.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _parameters.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: 60,
                                child: Text(
                                  _parameterLabels[_parameters[index]]!,
                                  style: const TextStyle(fontSize: 9),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  barGroups: _parameters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final param = entry.value;
                    final rawValue = averages[param] ?? 0;
                    // Normalize TDS for display (divide by 100)
                    final value = param == 'tds' ? rawValue * 0.01 : rawValue;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value,
                          color: _getParameterColor(param),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxYForComparison(Map<String, double> averages) {
    // Normalize values for better visualization
    // TDS has much larger values than others
    double maxValue = 0;
    for (final entry in averages.entries) {
      final value = entry.key == 'tds' ? entry.value * 0.01 : entry.value;
      maxValue = math.max(maxValue, value);
    }
    return maxValue * 1.3; // Add 30% padding
  }

  Color _getParameterColor(String parameter) {
    switch (parameter) {
      case 'pH':
        return Colors.blue;
      case 'tds':
        return Colors.orange;
      case 'turbidity':
        return Colors.brown;
      case 'chlorine_residual':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
