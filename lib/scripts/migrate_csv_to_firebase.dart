import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';
import '../shared/data/services/csv_data_service.dart';
import '../shared/data/services/firebase_data_service.dart';
import '../shared/data/services/simulated_data_service.dart';
import '../shared/domain/domain.dart';

/// Script para migrar datos del CSV a Firebase
/// EJECUTAR SOLO UNA VEZ
/// 
/// Para ejecutar desde la terminal:
/// flutter run -d windows lib/scripts/migrate_csv_to_firebase.dart
/// 
/// O desde VS Code, abrir este archivo y presionar F5

Future<void> runMigrator() async {
  print('🚀 Iniciando migración de CSV a Firebase...\n');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado\n');

    // Habilitar persistencia
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);

    final firebaseService = FirebaseDataService();
    final stations = SimulatedDataService.createDefaultStations();

    print('📊 Estaciones a procesar: ${stations.length}');
    for (final station in stations) {
      print('   - ${station.name} (${station.id})');
    }
    print('');

    // Migrar datos por estación
    int totalReadings = 0;
    int successfulSaves = 0;
    int failedSaves = 0;

    for (final station in stations) {
      print('🔄 Procesando estación: ${station.name} (${station.id})');
      
      // Obtener lecturas históricas del CSV (últimos 90 días)
      final readings = await CsvDataService.getHistoricalReadings(
        station.id,
        days: 90,
      );

      print('   Lecturas encontradas en CSV: ${readings.length}');
      totalReadings += readings.length;

      if (readings.isEmpty) {
        print('   ⚠️ No hay datos en CSV para esta estación\n');
        continue;
      }

      // Guardar cada lectura en Firebase
      // IMPORTANTE: Ajustar fechas del CSV al año actual (2025) para que sean relevantes
      final now = DateTime.now();
      int stationSuccess = 0;
      int stationFailed = 0;

      for (int i = 0; i < readings.length; i++) {
        try {
          // Ajustar la fecha al año actual manteniendo mes y día
          final originalDate = readings[i].timestamp;
          final adjustedDate = DateTime(
            now.year, // Usar año actual (2025)
            originalDate.month,
            originalDate.day,
            originalDate.hour,
            originalDate.minute,
            originalDate.second,
          );
          
          // Crear nueva lectura con fecha ajustada
          final adjustedReading = WaterQualityReading(
            id: readings[i].id,
            stationId: readings[i].stationId,
            timestamp: adjustedDate,
            parameters: readings[i].parameters,
            qualityIndex: readings[i].qualityIndex,
            overallStatus: readings[i].overallStatus,
            alerts: readings[i].alerts,
          );
          
          await firebaseService.saveReading(adjustedReading);
          stationSuccess++;
          
          // Mostrar progreso cada 10 lecturas
          if ((i + 1) % 10 == 0) {
            print('   Progreso: ${i + 1}/${readings.length} lecturas guardadas...');
          }
        } catch (e) {
          stationFailed++;
          print('   ❌ Error guardando lectura ${i + 1}: $e');
        }
      }

      successfulSaves += stationSuccess;
      failedSaves += stationFailed;

      print('   ✅ Completado: $stationSuccess guardadas, $stationFailed fallidas\n');
      
      // Pequeña pausa para no saturar Firebase
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Resumen final
    print('═══════════════════════════════════════════════════════════');
    print('📈 RESUMEN DE MIGRACIÓN');
    print('═══════════════════════════════════════════════════════════');
    print('Total de estaciones procesadas: ${stations.length}');
    print('Total de lecturas encontradas: $totalReadings');
    print('✅ Guardadas exitosamente: $successfulSaves');
    print('❌ Fallidas: $failedSaves');
    print('📊 Tasa de éxito: ${totalReadings > 0 ? ((successfulSaves / totalReadings) * 100).toStringAsFixed(2) : 0}%');
    print('═══════════════════════════════════════════════════════════\n');

    if (successfulSaves > 0) {
      print('🎉 Migración completada con éxito!');
      print('Puedes verificar los datos en Firebase Console:');
      print('https://console.firebase.google.com/project/water-quality-db-630a8/database/water-quality-db-630a8-default-rtdb/data\n');
    } else {
      print('⚠️ No se pudo guardar ninguna lectura. Verifica tu conexión a internet.\n');
    }

  } catch (e, stackTrace) {
    print('❌ ERROR FATAL: $e');
    print('Stack trace: $stackTrace');
  }

  print('✨ Script finalizado. Presiona cualquier tecla para salir...');
}
