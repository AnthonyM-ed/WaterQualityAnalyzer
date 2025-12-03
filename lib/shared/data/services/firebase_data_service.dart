import 'package:firebase_database/firebase_database.dart';
import '../../domain/domain.dart';

/// Servicio para sincronizar datos con Firebase Realtime Database
/// Soporta funcionamiento offline con sincronización automática
class FirebaseDataService {
  static final FirebaseDataService _instance = FirebaseDataService._internal();
  factory FirebaseDataService() => _instance;
  FirebaseDataService._internal();

  final _database = FirebaseDatabase.instance;

  // Referencias a nodos principales de Firebase
  DatabaseReference get _stationsRef => _database.ref('stations');
  DatabaseReference get _readingsRef => _database.ref('readings');
  DatabaseReference get _usersRef => _database.ref('users');

  /// Verificar conectividad real a Firebase (no cache local)
  Future<bool> isOnline() async {
    try {
      final testRef = _database.ref('_connection_test');
      await testRef.get().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('📴 Firebase: Timeout - usando cache offline');
          throw Exception('Connection timeout');
        },
      );
      return true;
    } catch (e) {
      print('📴 Firebase: Sin conexión real, usando cache offline');
      return false;
    }
  }

  // ==================== ESTACIONES ====================

  /// Guardar o actualizar una estación
  Future<void> saveStation(WaterStation station) async {
    try {
      await _stationsRef.child(station.id).set({
        'id': station.id,
        'name': station.name,
        'latitude': station.latitude,
        'longitude': station.longitude,
        'address': station.address,
        'region': station.region,
        'waterBody': station.waterBody,
        'description': station.description,
        'status': station.status.toString().split('.').last,
        'createdAt': station.createdAt.toIso8601String(),
        'lastUpdate': DateTime.now().toIso8601String(),
        'sensorIds': station.sensorIds,
      });
      print('Station ${station.id} saved to Firebase');
    } catch (e) {
      print('Error saving station: $e');
      rethrow;
    }
  }

  /// Obtener todas las estaciones (con listener en tiempo real)
  Stream<List<WaterStation>> watchStations() {
    return _stationsRef.onValue.map((event) {
      if (event.snapshot.value == null) return <WaterStation>[];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.values.map((stationData) {
        final station = Map<String, dynamic>.from(stationData as Map);
        return WaterStation(
          id: station['id'] as String,
          name: station['name'] as String,
          latitude: (station['latitude'] as num).toDouble(),
          longitude: (station['longitude'] as num).toDouble(),
          address: station['address'] as String? ?? '',
          region: station['region'] as String? ?? '',
          waterBody: station['waterBody'] as String? ?? '',
          description: station['description'] as String,
          status: _parseStationStatus(station['status'] as String),
          createdAt: DateTime.parse(station['createdAt'] as String),
          sensorIds: List<String>.from(station['sensorIds'] ?? []),
          metadata: const StationMetadata(
            elevation: 0,
            department: 'Arequipa',
            municipality: 'Caravelí',
            waterBodyType: 'río',
          ),
        );
      }).toList();
    });
  }

  /// Obtener una estación específica
  Future<WaterStation?> getStation(String stationId) async {
    try {
      final snapshot = await _stationsRef.child(stationId).get();
      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return WaterStation(
        id: data['id'] as String,
        name: data['name'] as String,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        address: data['address'] as String? ?? '',
        region: data['region'] as String? ?? '',
        waterBody: data['waterBody'] as String? ?? '',
        description: data['description'] as String,
        status: _parseStationStatus(data['status'] as String),
        createdAt: DateTime.parse(data['createdAt'] as String),
        sensorIds: List<String>.from(data['sensorIds'] ?? []),
        metadata: const StationMetadata(
          elevation: 0,
          department: 'Arequipa',
          municipality: 'Caravelí',
          waterBodyType: 'río',
        ),
      );
    } catch (e) {
      print('Error getting station: $e');
      return null;
    }
  }

  // ==================== LECTURAS ====================

  /// Guardar una lectura de sensor en Firebase
  /// Estructura: readings/{stationId}/{timestamp}
  Future<void> saveReading(WaterQualityReading reading) async {
    try {
      final timestamp = reading.timestamp.millisecondsSinceEpoch;
      
      await _readingsRef
          .child(reading.stationId)
          .child(timestamp.toString())
          .set({
        'id': reading.id,
        'stationId': reading.stationId,
        'timestamp': reading.timestamp.toIso8601String(),
        'parameters': reading.parameters,
        'qualityIndex': reading.qualityIndex,
        'overallStatus': reading.overallStatus.toString().split('.').last,
        'alerts': reading.alerts,
      });

      // También guardar como "latest" para acceso rápido
      await _readingsRef.child(reading.stationId).child('latest').set({
        'id': reading.id,
        'stationId': reading.stationId,
        'timestamp': reading.timestamp.toIso8601String(),
        'parameters': reading.parameters,
        'qualityIndex': reading.qualityIndex,
        'overallStatus': reading.overallStatus.toString().split('.').last,
        'alerts': reading.alerts,
      });

    } catch (e) {
      // Permitir funcionamiento offline
    }
  }

  /// Obtener la última lectura de una estación
  Future<WaterQualityReading?> getLatestReading(String stationId) async {
    try {
      final snapshot = await _readingsRef.child(stationId).child('latest').get();
      if (!snapshot.exists) return null;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return _parseReading(data);
    } catch (e) {
      print('Error getting latest reading: $e');
      return null;
    }
  }

  /// Stream de la última lectura (tiempo real)
  Stream<WaterQualityReading?> watchLatestReading(String stationId) {
    return _readingsRef.child(stationId).child('latest').onValue.map((event) {
      if (event.snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return _parseReading(data);
    });
  }

  Future<List<WaterQualityReading>> getHistoricalReadings({
    required String stationId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      final snapshot = await _readingsRef.child(stationId).get();
      
      if (!snapshot.exists) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final readings = <WaterQualityReading>[];

      data.forEach((key, value) {
        if (key == 'latest') return; // Ignorar el nodo "latest"
        
        try {
          final readingData = Map<String, dynamic>.from(value as Map);
          final reading = _parseReading(readingData);
          
          // Filtrar por rango de fechas en memoria
          if (startDate != null && reading.timestamp.isBefore(startDate)) return;
          if (endDate != null && reading.timestamp.isAfter(endDate)) return;
          
          readings.add(reading);
        } catch (e) {
          print('Error parsing reading with key $key: $e');
        }
      });

      // Ordenar por fecha (más reciente primero)
      readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Aplicar límite si es necesario
      if (readings.length > limit) {
        return readings.take(limit).toList();
      }

      return readings;
    } catch (e) {
      print('Error getting historical readings: $e');
      return [];
    }
  }

  /// Stream de lecturas históricas (tiempo real)
  Stream<List<WaterQualityReading>> watchHistoricalReadings({
    required String stationId,
    int limit = 100,
  }) {
    return _readingsRef
        .child(stationId)
        .limitToLast(limit)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return <WaterQualityReading>[];

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final readings = <WaterQualityReading>[];

      data.forEach((key, value) {
        if (key == 'latest') return;
        
        final readingData = Map<String, dynamic>.from(value as Map);
        readings.add(_parseReading(readingData));
      });

      readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return readings;
    });
  }

  // ==================== USUARIOS ====================

  /// Guardar información de usuario (complementa Firebase Auth)
  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
    required String dni,
  }) async {
    try {
      await _usersRef.child(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'dni': dni,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      });
      print('User $uid saved to Firebase');
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  /// Actualizar última fecha de login
  Future<void> updateUserLastLogin(String uid) async {
    try {
      await _usersRef.child(uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  /// Obtener información de usuario
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final snapshot = await _usersRef.child(uid).get();
      if (!snapshot.exists) return null;

      return Map<String, dynamic>.from(snapshot.value as Map);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // ==================== UTILIDADES ====================

  WaterQualityReading _parseReading(Map<String, dynamic> data) {
    // Convertir parameters de Map<dynamic, dynamic> a Map<String, double>
    final parametersRaw = data['parameters'] as Map?;
    final parameters = <String, double>{};
    if (parametersRaw != null) {
      parametersRaw.forEach((key, value) {
        parameters[key.toString()] = (value as num).toDouble();
      });
    }

    return WaterQualityReading(
      id: data['id'] as String,
      stationId: data['stationId'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
      parameters: parameters,
      qualityIndex: (data['qualityIndex'] as num).toDouble(),
      overallStatus: _parseQualityStatus(data['overallStatus'] as String),
      alerts: List<String>.from(data['alerts'] ?? []),
    );
  }

  StationStatus _parseStationStatus(String status) {
    switch (status) {
      case 'active':
        return StationStatus.active;
      case 'inactive':
        return StationStatus.inactive;
      case 'maintenance':
        return StationStatus.maintenance;
      case 'error':
        return StationStatus.error;
      default:
        return StationStatus.inactive;
    }
  }

  WaterQualityStatus _parseQualityStatus(String status) {
    switch (status) {
      case 'excellent':
        return WaterQualityStatus.excellent;
      case 'good':
        return WaterQualityStatus.good;
      case 'moderate':
        return WaterQualityStatus.moderate;
      case 'poor':
        return WaterQualityStatus.poor;
      case 'veryPoor':
        return WaterQualityStatus.veryPoor;
      default:
        return WaterQualityStatus.moderate;
    }
  }

  // ==================== SINCRONIZACIÓN ====================

  /// Verificar estado de conexión a Firebase
  Stream<bool> get connectionState {
    return _database.ref('.info/connected').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }

  /// Limpiar datos antiguos (mantener solo últimos N días)
  Future<void> cleanOldReadings({
    required String stationId,
    int daysToKeep = 90,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch;

      final snapshot = await _readingsRef.child(stationId).get();
      if (!snapshot.exists) return;

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      
      for (final key in data.keys) {
        if (key == 'latest') continue;
        
        final timestamp = int.tryParse(key);
        if (timestamp != null && timestamp < cutoffTimestamp) {
          await _readingsRef.child(stationId).child(key).remove();
          print('Removed old reading: $key');
        }
      }

      print('Cleaned old readings for station $stationId');
    } catch (e) {
      print('Error cleaning old readings: $e');
    }
  }
}
