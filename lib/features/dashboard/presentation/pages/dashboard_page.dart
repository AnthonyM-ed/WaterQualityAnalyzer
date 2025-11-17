import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/data/services/csv_data_service.dart';
import '../../../../shared/data/services/simulated_data_service.dart';
import '../../../../shared/data/services/sensor_simulator_service.dart';
import '../../../../shared/domain/domain.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../charts/presentation/charts_page.dart';
import '../../../maps/presentation/map_page.dart';
import '../../../settings/presentation/settings_page.dart';
import 'station_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  List<WaterStation> _stations = [];
  Map<String, WaterQualityReading> _currentReadings = {};
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _useRealtimeSimulation = true; // Toggle between CSV and realtime
  final _sensorSimulator = SensorSimulatorService();

  @override
  void initState() {
    super.initState();
    _loadData();
    
    if (_useRealtimeSimulation) {
      // Start IoT sensor simulation (async)
      _startRealtimeUpdates();
    }
  }

  @override
  void dispose() {
    _sensorSimulator.stopSimulation();
    super.dispose();
  }

  /// Start real-time sensor simulation (mimics MQTT/Firebase)
  Future<void> _startRealtimeUpdates() async {
    print('🚀 Starting real-time sensor simulation...');
    
    // Subscribe to sensor updates
    _sensorSimulator.subscribe(_onSensorData);
    
    // Start simulation with 30 second intervals (loads CSV first)
    await _sensorSimulator.startSimulation(
      interval: const Duration(seconds: 30),
    );
  }

  /// Handle incoming sensor data (like MQTT message received)
  void _onSensorData(WaterQualityReading reading) {
    if (mounted) {
      setState(() {
        _currentReadings[reading.stationId] = reading;
      });
      
      // Show notification for critical alerts
      if (reading.alerts.isNotEmpty && 
          (reading.overallStatus == WaterQualityStatus.veryPoor || 
           reading.overallStatus == WaterQualityStatus.poor)) {
        _showAlertSnackbar(reading);
      }
    }
  }

  /// Show alert notification
  void _showAlertSnackbar(WaterQualityReading reading) {
    final station = _stations.firstWhere((s) => s.id == reading.stationId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⚠️ Alerta en ${station.name}: ${reading.alerts.first}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to station detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StationDetailPage(station: station),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Check if user is logged in
    final isLoggedIn = await AuthRepository.isLoggedIn();

    // Load stations
    final stations = SimulatedDataService.createDefaultStations();
    final readings = <String, WaterQualityReading>{};

    if (_useRealtimeSimulation) {
      // Use current sensor readings if available
      for (final station in stations) {
        if (_currentReadings.containsKey(station.id)) {
          readings[station.id] = _currentReadings[station.id]!;
        } else {
          // Generate initial reading
          readings[station.id] = SimulatedDataService.generateReading(station.id);
        }
      }
    } else {
      // Use CSV data (historical mode)
      for (final station in stations) {
        final stationReadings = await CsvDataService.getStationReadings(station.id);
        if (stationReadings.isNotEmpty) {
          readings[station.id] = stationReadings.last;
        } else {
          readings[station.id] = SimulatedDataService.generateReading(station.id);
        }
      }
    }

    setState(() {
      _stations = stations;
      _currentReadings = readings;
      _isLoading = false;
      _isLoggedIn = isLoggedIn;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monitor de Agua - Arequipa'),
            if (_useRealtimeSimulation)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'En vivo (actualiza cada 30s)',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          // Toggle between realtime and historical mode
          IconButton(
            icon: Icon(_useRealtimeSimulation ? Icons.sensors : Icons.history),
            tooltip: _useRealtimeSimulation ? 'Modo histórico' : 'Modo tiempo real',
            onPressed: () {
              setState(() {
                _useRealtimeSimulation = !_useRealtimeSimulation;
                if (_useRealtimeSimulation) {
                  _startRealtimeUpdates();
                } else {
                  _sensorSimulator.stopSimulation();
                }
              });
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones próximamente')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Gráficos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const ChartsPage();
      case 2:
        return const MapPage();
      case 3:
        if (_isLoggedIn) {
          return const SettingsPage();
        } else {
          return _buildLoginRequired();
        }
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview cards
          _buildOverviewCards(),
          const SizedBox(height: 24),
          
          // Stations list
          Text(
            'Estaciones Activas',
            style: AppTheme.subHeadingStyle,
          ),
          const SizedBox(height: 16),
          
          ..._stations.map((station) => _buildStationCard(station)),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    final activeStations = _stations.where((s) => s.status == StationStatus.active).length;
    final alerts = _currentReadings.values
        .expand((reading) => reading.alerts)
        .length;
    
    double avgQualityIndex = 0;
    if (_currentReadings.isNotEmpty) {
      avgQualityIndex = _currentReadings.values
          .map((r) => r.qualityIndex)
          .reduce((a, b) => a + b) / _currentReadings.length;
    }

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Puntos de Agua',
            activeStations.toString(),
            Icons.sensors,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Alertas Críticas',
            alerts.toString(),
            Icons.warning,
            alerts > 0 ? AppTheme.warningColor : AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Calidad General',
            '${avgQualityIndex.toStringAsFixed(1)}%',
            Icons.water_drop,
            AppTheme.getQualityColor(_getQualityStatus(avgQualityIndex)),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.captionStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(WaterStation station) {
    final reading = _currentReadings[station.id];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reading != null 
              ? AppTheme.getQualityColor(reading.overallStatus.name)
              : Colors.grey,
          child: const Icon(Icons.water_drop, color: Colors.white),
        ),
        title: Text(station.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${station.region} • ${station.waterBody}'),
            if (reading != null) ...[
              const SizedBox(height: 4),
              Text(
                'Calidad: ${reading.qualityIndex.toStringAsFixed(1)}% • ${_getQualityStatusText(reading.overallStatus.name)}',
                style: TextStyle(
                  color: AppTheme.getQualityColor(reading.overallStatus.name),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(station.status),
              color: _getStatusColor(station.status),
            ),
            if (reading != null && reading.alerts.isNotEmpty)
              Icon(
                Icons.warning,
                color: AppTheme.warningColor,
                size: 16,
              ),
          ],
        ),
        onTap: () {
          _showStationDetails(station, reading);
        },
      ),
    );
  }

  void _showStationDetails(WaterStation station, WaterQualityReading? reading) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailPage(
          station: station,
          latestReading: reading,
        ),
      ),
    );
  }

  // Helper methods
  String _getQualityStatus(double qualityIndex) {
    if (qualityIndex >= 90) return 'excellent';
    if (qualityIndex >= 70) return 'good';
    if (qualityIndex >= 50) return 'moderate';
    if (qualityIndex >= 25) return 'poor';
    return 'very_poor';
  }

  String _getQualityStatusText(String status) {
    switch (status) {
      case 'excellent':
        return 'Excelente';
      case 'good':
        return 'Buena';
      case 'moderate':
        return 'Moderada';
      case 'poor':
        return 'Pobre';
      case 'very_poor':
        return 'Muy Pobre';
      default:
        return 'Desconocida';
    }
  }

  IconData _getStatusIcon(StationStatus status) {
    switch (status) {
      case StationStatus.active:
        return Icons.check_circle;
      case StationStatus.inactive:
        return Icons.radio_button_unchecked;
      case StationStatus.maintenance:
        return Icons.build;
      case StationStatus.error:
        return Icons.error;
    }
  }

  Color _getStatusColor(StationStatus status) {
    switch (status) {
      case StationStatus.active:
        return AppTheme.successColor;
      case StationStatus.inactive:
        return Colors.grey;
      case StationStatus.maintenance:
        return AppTheme.warningColor;
      case StationStatus.error:
        return AppTheme.errorColor;
    }
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Configuración no disponible',
              style: AppTheme.headingStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Debes iniciar sesión con una cuenta registrada para acceder a la configuración',
              style: AppTheme.bodyStyle.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Iniciar Sesión'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: const Text('Volver al Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

}