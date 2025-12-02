import 'dart:async';
import 'dart:math';
import '../../domain/domain.dart';
import '../../../core/constants/app_constants.dart';
import 'csv_data_service.dart';
import 'firebase_data_service.dart';

/// Simulates IoT sensors sending data periodically
/// Uses REAL CSV data as baseline and adds small realistic variations
/// Mimics real sensor behavior: readings every 30 seconds with sensor drift
class SensorSimulatorService {
  static final SensorSimulatorService _instance = SensorSimulatorService._internal();
  factory SensorSimulatorService() => _instance;
  SensorSimulatorService._internal();

  Timer? _timer;
  final _random = Random();
  final List<Function(WaterQualityReading)> _listeners = [];
  
  // Simulate sensor state (can fail, disconnect, etc)
  final Map<String, bool> _sensorStatus = {
    'CA-08': true,
    'CA-09': true,
    'CA-10': true,
  };

  // Last readings for each station (to create realistic variations)
  final Map<String, WaterQualityReading?> _lastReadings = {
    'CA-08': null,
    'CA-09': null,
    'CA-10': null,
  };

  // Baseline readings from CSV (real historical data)
  final Map<String, List<WaterQualityReading>> _csvBaselineData = {};
  bool _csvDataLoaded = false;

  /// Start simulating sensor data
  /// [interval] - Time between readings (default 30 seconds like real sensors)
  Future<void> startSimulation({Duration interval = const Duration(seconds: 30)}) async {
    if (_timer != null) {
      print('Sensor simulation already running');
      return;
    }

    print('Starting IoT sensor simulation...');
    print('Loading real data from CSV as baseline...');
    
    // Load CSV data first
    await _loadCsvBaseline();
    
    print('Sensors will send data every ${interval.inSeconds}s');
    
    // Send initial readings immediately
    _generateAndBroadcastReadings();
    
    // Then continue periodically
    _timer = Timer.periodic(interval, (timer) async {
      _generateAndBroadcastReadings();
    });
  }

  /// Load CSV data as baseline for realistic simulation
  Future<void> _loadCsvBaseline() async {
    try {
      final stationIds = ['CA-08', 'CA-09', 'CA-10'];
      
      for (final stationId in stationIds) {
        final readings = await CsvDataService.getStationReadings(stationId);
        if (readings.isNotEmpty) {
          _csvBaselineData[stationId] = readings;
          print('Loaded ${readings.length} baseline readings for $stationId');
        }
      }
      
      _csvDataLoaded = true;
    } catch (e) {
      print('Error loading CSV baseline: $e');
      _csvDataLoaded = false;
    }
  }

  /// Stop sensor simulation
  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
    print('Sensor simulation stopped');
  }

  /// Subscribe to sensor data updates (like MQTT subscription)
  void subscribe(Function(WaterQualityReading) onData) {
    _listeners.add(onData);
    print('New subscriber connected (${_listeners.length} total)');
  }

  /// Unsubscribe from updates
  void unsubscribe(Function(WaterQualityReading) onData) {
    _listeners.remove(onData);
    print('Subscriber disconnected (${_listeners.length} remaining)');
  }

  /// Simulate sensor failure/recovery
  void setSensorStatus(String stationId, bool isOnline) {
    _sensorStatus[stationId] = isOnline;
    print('${isOnline ? "✅" : "❌"} Sensor $stationId ${isOnline ? "online" : "offline"}');
  }

  /// Generate and broadcast readings for all stations
  void _generateAndBroadcastReadings() {
    final stationIds = ['CA-08', 'CA-09', 'CA-10'];
    
    for (final stationId in stationIds) {
      if (_sensorStatus[stationId] != true) {
        print('Sensor $stationId offline, skipping...');
        continue;
      }

      final reading = _generateReading(stationId);
      _lastReadings[stationId] = reading;
      
      // Save to Firebase (with offline support)
      _saveToFirebase(reading);
      
      // Broadcast to all listeners (simulate MQTT publish)
      for (final listener in _listeners) {
        listener(reading);
      }
    }
  }

  /// Guardar lectura en Firebase (funciona offline con cache)
  Future<void> _saveToFirebase(WaterQualityReading reading) async {
    try {
      await FirebaseDataService().saveReading(reading);
    } catch (e) {
      // Ignorar errores (persistencia offline activa)
    }
  }

  /// Generar lectura realista basada en datos CSV con pequeñas variaciones
  WaterQualityReading _generateReading(String stationId) {
    final lastReading = _lastReadings[stationId];
    final now = DateTime.now();
    
    // Get base values from CSV data (real historical data)
    final baseValues = _getBaseValuesFromCsv(stationId);
    
    // Generate parameters with realistic variations
    var parameters = <String, double>{};
    baseValues.forEach((param, baseValue) {
      double value;
      
      if (lastReading != null && lastReading.parameters.containsKey(param)) {
        // Vary from last reading (sensor drift - small variations)
        final lastValue = lastReading.parameters[param]!;
        final variation = _getVariation(param);
        value = lastValue + (_random.nextDouble() * 2 - 1) * variation;
      } else {
        // First reading: use CSV base value with small random offset
        final variation = _getVariation(param) * 0.5; // Half variation for first reading
        value = baseValue + (_random.nextDouble() * 2 - 1) * variation;
      }
      
      // Apply realistic constraints
      value = _constrainValue(param, value);
      parameters[param] = value;
    });

    // Simulate occasional sensor anomalies (5% chance - less than before)
    if (_random.nextDouble() < 0.05) {
      parameters = _simulateAnomaly(stationId, parameters);
    }

    // Calculate quality status
    final qualityIndex = _calculateQualityIndex(parameters);
    final status = _getQualityStatus(qualityIndex);
    
    // Generate alerts
    final alerts = _generateAlerts(parameters);

    return WaterQualityReading(
      id: '${stationId}_${now.millisecondsSinceEpoch}',
      stationId: stationId,
      timestamp: now,
      parameters: parameters,
      overallStatus: status,
      qualityIndex: qualityIndex,
      alerts: alerts,
    );
  }

  /// Get base values from CSV data (uses average of recent readings)
  Map<String, double> _getBaseValuesFromCsv(String stationId) {
    if (!_csvDataLoaded || !_csvBaselineData.containsKey(stationId)) {
      // Fallback to default values if CSV not loaded
      print('Using fallback values for $stationId (CSV not loaded)');
      return _getFallbackValues(stationId);
    }

    final readings = _csvBaselineData[stationId]!;
    if (readings.isEmpty) {
      return _getFallbackValues(stationId);
    }

    // Use the last 5 readings to calculate average (more stable baseline)
    final recentReadings = readings.length > 5 
        ? readings.sublist(readings.length - 5)
        : readings;

    final parameters = <String, double>{};
    final paramSums = <String, double>{};
    final paramCounts = <String, int>{};

    for (final reading in recentReadings) {
      reading.parameters.forEach((param, value) {
        paramSums[param] = (paramSums[param] ?? 0) + value;
        paramCounts[param] = (paramCounts[param] ?? 0) + 1;
      });
    }

    paramSums.forEach((param, sum) {
      parameters[param] = sum / paramCounts[param]!;
    });

    return parameters;
  }

  /// Fallback values when CSV is not available
  Map<String, double> _getFallbackValues(String stationId) {
    switch (stationId) {
      case 'CA-08': // Zona Media Alta - Best quality
        return {
          'pH': 7.6,
          'tds': 180.0,
          'turbidity': 1.2,
          'chlorine_residual': 0.7,
        };
      case 'CA-09': // Pueblo Acarí - Medium quality
        return {
          'pH': 7.4,
          'tds': 170.0,
          'turbidity': 2.5,
          'chlorine_residual': 0.4,
        };
      case 'CA-10': // Zona Baja - Worst quality
        return {
          'pH': 7.1,
          'tds': 1650.0,
          'turbidity': 3.5,
          'chlorine_residual': 0.15,
        };
      default:
        return {};
    }
  }

  /// Get expected variation for each parameter (sensor precision)
  double _getVariation(String param) {
    switch (param) {
      case 'pH':
        return 0.3; // ±0.3 pH units
      case 'tds':
        return 50.0; // ±50 ppm
      case 'turbidity':
        return 0.5; // ±0.5 NTU
      case 'chlorine_residual':
        return 0.2; // ±0.2 mg/L
      default:
        return 0.0;
    }
  }

  /// Constrain values to realistic ranges
  double _constrainValue(String param, double value) {
    switch (param) {
      case 'pH':
        return value.clamp(5.0, 11.5);
      case 'tds':
        return value.clamp(50.0, 3000.0);
      case 'turbidity':
        return value.clamp(0.1, 10.0);
      case 'chlorine_residual':
        return value.clamp(0.0, 2.0);
      default:
        return value;
    }
  }

  /// Simulate sensor anomalies (contamination events, malfunctions)
  Map<String, double> _simulateAnomaly(String stationId, Map<String, double> parameters) {
    final anomalyType = _random.nextInt(4);
    
    switch (anomalyType) {
      case 0: // pH spike (chemical discharge)
        parameters['pH'] = 9.5 + _random.nextDouble() * 1.5;
        print('⚠️ [$stationId] ANOMALY: pH spike detected!');
        break;
      case 1: // Turbidity spike (sediment/rain)
        parameters['turbidity'] = 5.0 + _random.nextDouble() * 3.0;
        print('[$stationId] ANOMALY: High turbidity!');
        break;
      case 2: // Low chlorine (treatment failure)
        parameters['chlorine_residual'] = 0.0 + _random.nextDouble() * 0.1;
        print('[$stationId] ANOMALY: Low chlorine!');
        break;
      case 3: // TDS spike (contamination)
        parameters['tds'] = parameters['tds']! * 1.5;
        print('[$stationId] ANOMALY: TDS spike!');
        break;
    }
    
    return parameters;
  }

  /// Calculate quality index (0-100)
  double _calculateQualityIndex(Map<String, double> parameters) {
    double totalScore = 0;
    int paramCount = 0;
    final standards = AppConstants.waterQualityStandards;

    parameters.forEach((param, value) {
      final standard = standards[param];
      if (standard != null) {
        double score = 100;
        
        if (standard['min'] != null && value < standard['min']!) {
          score = (value / standard['min']!) * 100;
        } else if (standard['max'] != null && value > standard['max']!) {
          score = (standard['max']! / value) * 100;
        }
        
        totalScore += score.clamp(0, 100);
        paramCount++;
      }
    });

    return paramCount > 0 ? totalScore / paramCount : 0;
  }

  /// Get quality status from index
  WaterQualityStatus _getQualityStatus(double index) {
    if (index >= 90) return WaterQualityStatus.excellent;
    if (index >= 75) return WaterQualityStatus.good;
    if (index >= 60) return WaterQualityStatus.moderate;
    if (index >= 40) return WaterQualityStatus.poor;
    return WaterQualityStatus.veryPoor;
  }

  /// Generate alerts for out-of-range parameters
  List<String> _generateAlerts(Map<String, double> parameters) {
    final alerts = <String>[];
    final standards = AppConstants.waterQualityStandards;

    parameters.forEach((param, value) {
      final standard = standards[param];
      if (standard != null) {
        if (standard['min'] != null && value < standard['min']!) {
          alerts.add('$param por debajo del límite (${value.toStringAsFixed(2)} < ${standard['min']})');
        } else if (standard['max'] != null && value > standard['max']!) {
          alerts.add('$param excede el límite (${value.toStringAsFixed(2)} > ${standard['max']})');
        }
      }
    });

    return alerts;
  }

  /// Clean up resources
  void dispose() {
    stopSimulation();
    _listeners.clear();
    _lastReadings.clear();
  }
}
