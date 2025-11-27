import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../shared/data/services/firebase_data_service.dart';
import '../shared/data/services/simulated_data_service.dart';

/// Script para verificar qué datos hay en Firebase
/// flutter run -d windows lib/scripts/check_firebase_data.dart

Future<void> main() async {
  print('🔍 Verificando datos en Firebase...\n');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado\n');

    final firebaseService = FirebaseDataService();
    final stations = SimulatedDataService.createDefaultStations();

    for (final station in stations) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 Estación: ${station.name} (${station.id})');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // Obtener TODOS los datos sin filtros
      final readings = await firebaseService.getHistoricalReadings(
        stationId: station.id,
        limit: 10000,
      );

      if (readings.isEmpty) {
        print('❌ No hay datos para esta estación\n');
        continue;
      }

      print('📊 Total de lecturas: ${readings.length}');
      print('📅 Fecha más antigua: ${readings.last.timestamp}');
      print('📅 Fecha más reciente: ${readings.first.timestamp}');
      
      // Agrupar por fecha
      final Map<String, int> readingsByDate = {};
      for (final reading in readings) {
        final dateKey = '${reading.timestamp.year}-${reading.timestamp.month.toString().padLeft(2, '0')}-${reading.timestamp.day.toString().padLeft(2, '0')}';
        readingsByDate[dateKey] = (readingsByDate[dateKey] ?? 0) + 1;
      }

      print('\n📅 Lecturas por fecha:');
      final sortedDates = readingsByDate.keys.toList()..sort();
      for (final date in sortedDates) {
        print('   $date: ${readingsByDate[date]} lecturas');
      }
      print('');
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Verificación completada');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('Stack trace: $stackTrace');
  }
}
