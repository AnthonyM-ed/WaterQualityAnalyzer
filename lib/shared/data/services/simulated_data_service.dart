import 'dart:math';
import '../../../core/constants/app_constants.dart';
import '../../domain/domain.dart';

class SimulatedDataService {
  static final Random _random = Random();
  
  // Generate simulated water quality readings for a station
  static WaterQualityReading generateReading(String stationId) {
    final timestamp = DateTime.now();
    final parameters = <String, double>{};
    final alerts = <String>[];
    
    // Simulate different parameters with realistic ranges
    for (final entry in AppConstants.waterQualityStandards.entries) {
      final parameter = entry.key;
      final standards = entry.value;
      
      double value;
      // 70% of the time generate values within optimal range
      // 20% of the time generate values within acceptable range  
      // 10% of the time generate values outside acceptable range (critical for informal settlements)
      final rand = _random.nextDouble();
      
      if (rand < 0.7) {
        // Optimal range
        value = _generateValueInRange(
          standards['optimal_min']!,
          standards['optimal_max']!,
        );
      } else if (rand < 0.9) {
        // Acceptable range but not optimal
        if (_random.nextBool()) {
          value = _generateValueInRange(
            standards['min']!,
            standards['optimal_min']!,
          );
        } else {
          value = _generateValueInRange(
            standards['optimal_max']!,
            standards['max']!,
          );
        }
      } else {
        // Out of range (critical alert for informal settlements)
        if (_random.nextBool()) {
          value = standards['min']! - _random.nextDouble() * 2;
          alerts.add('$parameter por debajo del límite mínimo - PELIGROSO PARA CONSUMO');
        } else {
          value = standards['max']! + _random.nextDouble() * 2;
          alerts.add('$parameter por encima del límite máximo - PELIGROSO PARA CONSUMO');
        }
      }
      
      parameters[parameter] = double.parse(value.toStringAsFixed(2));
    }
    
    // Calculate overall quality index and status
    final qualityIndex = _calculateQualityIndex(parameters);
    final status = _getQualityStatus(qualityIndex);
    
    return WaterQualityReading(
      id: 'reading_${stationId}_${timestamp.millisecondsSinceEpoch}',
      stationId: stationId,
      timestamp: timestamp,
      parameters: parameters,
      overallStatus: status,
      qualityIndex: qualityIndex,
      alerts: alerts,
    );
  }
  
  // Generate historical data for charts
  static List<WaterQualityReading> generateHistoricalData(
    String stationId, {
    required int days,
    required int samplesPerDay,
  }) {
    final readings = <WaterQualityReading>[];
    final now = DateTime.now();
    
    for (int day = days; day >= 0; day--) {
      for (int sample = 0; sample < samplesPerDay; sample++) {
        final timestamp = now.subtract(
          Duration(
            days: day,
            hours: (24 / samplesPerDay * sample).round(),
          ),
        );
        
        final reading = generateReading(stationId);
        readings.add(reading.copyWith(
          id: 'reading_${stationId}_${timestamp.millisecondsSinceEpoch}',
          timestamp: timestamp,
        ));
      }
    }
    
    return readings.reversed.toList();
  }
  
  // Generate measurement data for a specific sensor
  static List<Measurement> generateSensorMeasurements(
    String sensorId,
    String stationId,
    String parameter, {
    required int count,
  }) {
    final measurements = <Measurement>[];
    final now = DateTime.now();
    final standards = AppConstants.waterQualityStandards[parameter];
    
    if (standards == null) return measurements;
    
    for (int i = 0; i < count; i++) {
      final timestamp = now.subtract(
        Duration(minutes: AppConstants.dataUpdateIntervalSeconds ~/ 60 * i),
      );
      
      final value = _generateValueInRange(
        standards['min']!,
        standards['max']!,
      );
      
      measurements.add(Measurement(
        id: 'measurement_${sensorId}_${timestamp.millisecondsSinceEpoch}',
        sensorId: sensorId,
        stationId: stationId,
        parameter: parameter,
        value: value,
        unit: _getParameterUnit(parameter),
        timestamp: timestamp,
        quality: _getRandomMeasurementQuality(),
      ));
    }
    
    return measurements.reversed.toList();
  }
  
  // Create simulated stations based on default locations
  static List<WaterStation> createDefaultStations() {
    return AppConstants.defaultStations.map((stationData) {
      final station = WaterStation(
        id: stationData['id'],
        name: stationData['name'],
        description: stationData['description'],
        latitude: stationData['latitude'],
        longitude: stationData['longitude'],
        address: '${stationData['name']}, Arequipa, Perú',
        region: 'Región Arequipa',
        waterBody: _getWaterBodyType(stationData['name']),
        status: StationStatus.active,
        createdAt: DateTime.now().subtract(
          Duration(days: _random.nextInt(365)),
        ),
        lastDataUpdate: DateTime.now().subtract(
          Duration(minutes: _random.nextInt(60)),
        ),
        sensorIds: _generateSensorIds(stationData['id']),
        metadata: StationMetadata(
          elevation: 2300 + _random.nextDouble() * 500, // Arequipa altitude
          department: 'Arequipa',
          municipality: _getMunicipalityFromName(stationData['name']),
          waterBodyType: _getWaterBodyType(stationData['name']),
          depth: 2.0 + _random.nextDouble() * 8.0,
        ),
      );
      
      return station;
    }).toList();
  }
  
  // Generate sensors for a station
  static List<Sensor> createSensorsForStation(String stationId) {
    final sensors = <Sensor>[];
    final sensorTypes = [
      {'type': SensorType.ph, 'parameter': 'pH', 'unit': 'pH'},
      {'type': SensorType.dissolvedOxygen, 'parameter': 'dissolved_oxygen', 'unit': 'mg/L'},
      {'type': SensorType.temperature, 'parameter': 'temperature', 'unit': '°C'},
      {'type': SensorType.turbidity, 'parameter': 'turbidity', 'unit': 'NTU'},
      {'type': SensorType.conductivity, 'parameter': 'conductivity', 'unit': 'µS/cm'},
      {'type': SensorType.ammonia, 'parameter': 'ammonia', 'unit': 'mg/L'},
      {'type': SensorType.nitrites, 'parameter': 'nitrites', 'unit': 'mg/L'},
      {'type': SensorType.nitrates, 'parameter': 'nitrates', 'unit': 'mg/L'},
    ];
    
    for (int i = 0; i < sensorTypes.length; i++) {
      final sensorData = sensorTypes[i];
      final standards = AppConstants.waterQualityStandards[sensorData['parameter']];
      
      if (standards != null) {
        sensors.add(Sensor(
          id: '${stationId}_sensor_${i + 1}',
          stationId: stationId,
          name: '${sensorData['parameter']} Sensor',
          type: sensorData['type'] as SensorType,
          parameter: sensorData['parameter'] as String,
          unit: sensorData['unit'] as String,
          minValue: standards['min']!,
          maxValue: standards['max']!,
          accuracy: 0.01,
          status: SensorStatus.active,
          installedAt: DateTime.now().subtract(
            Duration(days: _random.nextInt(365)),
          ),
          lastCalibration: DateTime.now().subtract(
            Duration(days: _random.nextInt(30)),
          ),
          nextCalibration: DateTime.now().add(
            Duration(days: 30 + _random.nextInt(60)),
          ),
          config: const SensorConfig(
            readingInterval: 30,
            transmissionInterval: 300,
          ),
        ));
      }
    }
    
    return sensors;
  }
  
  // Helper methods
  static double _generateValueInRange(double min, double max) {
    return min + (_random.nextDouble() * (max - min));
  }
  
  static double _calculateQualityIndex(Map<String, double> parameters) {
    double totalScore = 0;
    int parameterCount = 0;
    
    for (final entry in parameters.entries) {
      final parameter = entry.key;
      final value = entry.value;
      final standards = AppConstants.waterQualityStandards[parameter];
      
      if (standards != null) {
        double score;
        final optimalMin = standards['optimal_min']!;
        final optimalMax = standards['optimal_max']!;
        final min = standards['min']!;
        final max = standards['max']!;
        
        if (value >= optimalMin && value <= optimalMax) {
          score = 100;
        } else if (value >= min && value <= max) {
          if (value < optimalMin) {
            score = 70 + (30 * (value - min) / (optimalMin - min));
          } else {
            score = 70 + (30 * (max - value) / (max - optimalMax));
          }
        } else {
          score = 0;
        }
        
        totalScore += score;
        parameterCount++;
      }
    }
    
    return parameterCount > 0 ? totalScore / parameterCount : 0;
  }
  
  static WaterQualityStatus _getQualityStatus(double qualityIndex) {
    if (qualityIndex >= 90) return WaterQualityStatus.excellent;
    if (qualityIndex >= 70) return WaterQualityStatus.good;
    if (qualityIndex >= 50) return WaterQualityStatus.moderate;
    if (qualityIndex >= 25) return WaterQualityStatus.poor;
    return WaterQualityStatus.veryPoor;
  }
  
  static MeasurementQuality _getRandomMeasurementQuality() {
    final rand = _random.nextDouble();
    if (rand < 0.8) return MeasurementQuality.excellent;
    if (rand < 0.95) return MeasurementQuality.good;
    return MeasurementQuality.fair;
  }
  
  static String _getParameterUnit(String parameter) {
    switch (parameter) {
      case 'pH':
        return 'pH';
      case 'temperature':
        return '°C';
      case 'turbidity':
        return 'NTU';
      case 'conductivity':
        return 'µS/cm';
      default:
        return 'mg/L';
    }
  }
  
  static List<String> _generateSensorIds(String stationId) {
    return List.generate(8, (index) => '${stationId}_sensor_${index + 1}');
  }
  
  static String _getWaterBodyType(String stationName) {
    if (stationName.contains('Pozo')) return 'pozo';
    if (stationName.contains('Cisterna') || stationName.contains('Tanque')) return 'tanque_cisterna';
    if (stationName.contains('Río') || stationName.contains('Chili')) return 'río';
    if (stationName.contains('Acopio')) return 'punto_acopio';
    return 'fuente_comunitaria';
  }
  
  static String _getMunicipalityFromName(String stationName) {
    if (stationName.contains('Alto Selva Alegre')) return 'Alto Selva Alegre';
    if (stationName.contains('Villa El Salvador')) return 'Cercado de Arequipa';
    if (stationName.contains('Cerro Colorado')) return 'Cerro Colorado';
    if (stationName.contains('Ciudad de Dios')) return 'Cerro Colorado';
    if (stationName.contains('Río Seco')) return 'Miraflores';
    return 'Arequipa';
  }
}