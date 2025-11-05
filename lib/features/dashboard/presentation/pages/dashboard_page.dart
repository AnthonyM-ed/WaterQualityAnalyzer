import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/data/services/simulated_data_service.dart';
import '../../../../shared/domain/domain.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate simulated data
    final stations = SimulatedDataService.createDefaultStations();
    final readings = <String, WaterQualityReading>{};

    for (final station in stations) {
      readings[station.id] = SimulatedDataService.generateReading(station.id);
    }

    setState(() {
      _stations = stations;
      _currentReadings = readings;
      _isLoading = false;
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
        title: const Text('Monitor de Agua - Arequipa'),
        actions: [
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
            icon: Icon(Icons.warning_amber),
            label: 'Alertas',
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
        return _buildPlaceholder('Gráficos', Icons.show_chart);
      case 2:
        return _buildPlaceholder('Alertas', Icons.warning_amber);
      case 3:
        return _buildPlaceholder('Mapa', Icons.map);
      case 4:
        return _buildPlaceholder('Configuración', Icons.settings);
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

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Próximamente',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showStationDetails(WaterStation station, WaterQualityReading? reading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      station.name,
                      style: AppTheme.subHeadingStyle,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (reading != null) ...[
                Text(
                  'Parámetros Actuales',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: reading.parameters.entries.map((entry) {
                      return _buildParameterTile(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParameterTile(String parameter, double value) {
    return ListTile(
      title: Text(_getParameterDisplayName(parameter)),
      subtitle: Text(_getParameterUnit(parameter)),
      trailing: Text(
        value.toStringAsFixed(2),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
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

  String _getParameterDisplayName(String parameter) {
    switch (parameter) {
      case 'pH':
        return 'pH';
      case 'dissolved_oxygen':
        return 'Oxígeno Disuelto';
      case 'temperature':
        return 'Temperatura';
      case 'turbidity':
        return 'Turbidez';
      case 'conductivity':
        return 'Conductividad';
      case 'ammonia':
        return 'Amoníaco';
      case 'nitrites':
        return 'Nitritos';
      case 'nitrates':
        return 'Nitratos';
      default:
        return parameter;
    }
  }

  String _getParameterUnit(String parameter) {
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
}