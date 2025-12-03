import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/data/services/csv_data_service.dart';
import '../../../shared/data/services/firebase_data_service.dart';
import '../../../shared/data/services/simulated_data_service.dart';
import '../../../shared/domain/domain.dart';
import '../../dashboard/presentation/pages/station_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  List<WaterStation> _stations = [];
  final Map<String, WaterQualityReading> _latestReadings = {};
  bool _isLoading = true;
  final _firebaseData = FirebaseDataService();

  // Center point: CA-09 (closest to Acarí town)
  static const LatLng _centerLocation = LatLng(
    -15.432483077524447,
    -74.61690904237376,
  );

  @override
  void initState() {
    super.initState();
    _loadStationsAndMarkers();
  }

  Future<void> _loadStationsAndMarkers() async {
    setState(() => _isLoading = true);

    try {
      // Load stations
      _stations = SimulatedDataService.createDefaultStations();

      // Get latest readings 
      for (var station in _stations) {
        // Try Firebase first (cloud-first strategy)
        final firebaseReading = await _firebaseData.getLatestReading(station.id);
        
        if (firebaseReading != null) {
          // Use Firebase data (real-time from cloud)
          _latestReadings[station.id] = firebaseReading;
        } else {
          // Fallback to CSV if Firebase has no data
          final stationReadings = await CsvDataService.getStationReadings(station.id);
          if (stationReadings.isNotEmpty) {
            _latestReadings[station.id] = stationReadings.last;
          } else {
            // Last resort: generate simulated data
            final reading = SimulatedDataService.generateReading(station.id);
            _latestReadings[station.id] = reading;
          }
        }
      }

      // Create markers with updated data
      _createMarkers();
    } catch (e) {
      debugPrint('Error loading stations: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _createMarkers() {
    _markers.clear();

    for (var station in _stations) {
      final reading = _latestReadings[station.id];
      if (reading == null) continue;

      final hasIssues = _hasQualityIssues(reading);
      final color = hasIssues ? Colors.red : Colors.blue;

      final marker = Marker(
        width: 40,
        height: 40,
        point: LatLng(station.latitude, station.longitude),
        child: GestureDetector(
          onTap: () => _onMarkerTapped(station),
          child: Icon(
            Icons.location_on,
            color: color,
            size: 40,
          ),
        ),
      );

      _markers.add(marker);
    }

    setState(() {});
  }

  bool _hasQualityIssues(WaterQualityReading reading) {
    final standards = AppConstants.waterQualityStandards;

    // Check pH (6.5 - 8.5)
    final ph = reading.parameters['pH'] ?? 7.0;
    if (ph < standards['pH']!['min']! || ph > standards['pH']!['max']!) {
      return true;
    }

    // Check TDS (≤ 1000 mg/L)
    final tds = reading.parameters['tds'] ?? 0;
    if (tds > standards['tds']!['max']!) {
      return true;
    }

    // Check Turbidity (≤ 5.0 UNT)
    final turbidity = reading.parameters['turbidity'] ?? 0;
    if (turbidity > standards['turbidity']!['max']!) {
      return true;
    }

    // Check Residual Chlorine (0.5 - 5.0 mg/L)
    final chlorine = reading.parameters['chlorine_residual'] ?? 1.0;
    if (chlorine < standards['chlorine_residual']!['min']! ||
        chlorine > standards['chlorine_residual']!['max']!) {
      return true;
    }

    return false;
  }

  void _onMarkerTapped(WaterStation station) {
    // Animate to marker
    _mapController.move(
      LatLng(station.latitude, station.longitude),
      15.0,
    );

    // Show bottom sheet with station info
    _showStationBottomSheet(station);
  }

  void _showStationBottomSheet(WaterStation station) {
    final reading = _latestReadings[station.id];
    if (reading == null) return;

    final ph = reading.parameters['pH'] ?? 7.0;
    final tds = reading.parameters['tds'] ?? 0;
    final turbidity = reading.parameters['turbidity'] ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Station name
            Text(
              station.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Elevation
            Text(
              'Elevación: ${station.metadata.elevation}m',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Quick parameters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat(
                  'pH',
                  ph.toStringAsFixed(1),
                  _isPhNormal(ph),
                ),
                _buildQuickStat(
                  'TDS',
                  '${tds.toInt()} mg/L',
                  tds <= AppConstants.waterQualityStandards['tds']!['max']!,
                ),
                _buildQuickStat(
                  'Turbidez',
                  '${turbidity.toStringAsFixed(1)} UNT',
                  turbidity <= AppConstants.waterQualityStandards['turbidity']!['max']!,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Details button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToStationDetail(station),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ver Detalles Completos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, bool isNormal) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isNormal ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  bool _isPhNormal(double ph) {
    final standards = AppConstants.waterQualityStandards['pH']!;
    return ph >= standards['min']! && ph <= standards['max']!;
  }

  void _navigateToStationDetail(WaterStation station) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailPage(
          station: station,
          latestReading: _latestReadings[station.id],
        ),
      ),
    );
  }

  void _centerOnCA09() {
    _mapController.move(_centerLocation, 14.0);
  }

  void _showAllStations() {
    if (_stations.isEmpty) return;

    // Calculate bounds
    double minLat = _stations.first.latitude;
    double maxLat = _stations.first.latitude;
    double minLng = _stations.first.longitude;
    double maxLng = _stations.first.longitude;

    for (var station in _stations) {
      if (station.latitude < minLat) minLat = station.latitude;
      if (station.latitude > maxLat) maxLat = station.latitude;
      if (station.longitude < minLng) minLng = station.longitude;
      if (station.longitude > maxLng) maxLng = station.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    // Fit bounds with padding
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
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
          child: Row(
            children: [
              const Icon(Icons.map, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mapa de Estaciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Cuenca río Acarí, Caravelí',
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
        ),

        // Map
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _centerLocation,
                        initialZoom: 14.0,
                        minZoom: 10.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        // OpenStreetMap tile layer
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.water_quality',
                        ),
                        // Markers layer
                        MarkerLayer(
                          markers: _markers,
                        ),
                      ],
                    ),

                    // Control buttons
                    Positioned(
                      right: 16,
                      bottom: 100,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'showAll',
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: _showAllStations,
                            tooltip: 'Mostrar todas',
                            child: const Icon(Icons.fullscreen, color: Colors.blue),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'centerCA09',
                            mini: true,
                            backgroundColor: Colors.white,
                            onPressed: _centerOnCA09,
                            tooltip: 'Centrar en CA-09',
                            child: const Icon(Icons.my_location, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),

                    // Legend
                    Positioned(
                      left: 16,
                      bottom: 100,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Leyenda',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.blue, size: 20),
                                const SizedBox(width: 4),
                                const Text('Normal', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.red, size: 20),
                                const SizedBox(width: 4),
                                const Text('Supera LMP', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_stations.length} estaciones',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
