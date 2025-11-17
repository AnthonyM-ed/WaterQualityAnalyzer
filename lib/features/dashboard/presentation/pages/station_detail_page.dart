import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../shared/domain/domain.dart';

class StationDetailPage extends StatelessWidget {
  final WaterStation station;
  final WaterQualityReading? latestReading;

  const StationDetailPage({
    super.key,
    required this.station,
    this.latestReading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la estación
            _buildStationImage(),
            
            // Información de la estación
            _buildStationInfo(),
            
            // Parámetros de calidad del agua
            if (latestReading != null) _buildWaterQualityParameters(),
            
            // Estado de la estación
            _buildStationStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/rio_acari_default.JPG'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                station.address,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información de la Estación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, 'Ubicación', station.address),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.terrain,
            'Elevación',
            '${station.metadata.elevation.toStringAsFixed(0)} m.s.n.m.',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.map,
            'Coordenadas',
            '${station.latitude.toStringAsFixed(4)}, ${station.longitude.toStringAsFixed(4)}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.info_outline, 'ID', station.id),
          ...[
          const SizedBox(height: 12),
          _buildInfoRow(Icons.description, 'Descripción', station.description!),
        ],
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterQualityParameters() {
    if (latestReading == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parámetros de Calidad del Agua',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Última actualización: ${_formatTimestamp(latestReading!.timestamp)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildParametersGrid(),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildParametersGrid() {
    final parameters = latestReading!.parameters;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        if (parameters.containsKey('pH'))
          _buildParameterCard(
            'pH',
            parameters['pH']!.toStringAsFixed(2),
            '-',
            _getParameterColor('pH', parameters['pH']!),
          ),
        if (parameters.containsKey('temperature'))
          _buildParameterCard(
            'Temperatura',
            parameters['temperature']!.toStringAsFixed(1),
            '°C',
            _getParameterColor('temperature', parameters['temperature']!),
          ),
        if (parameters.containsKey('tds'))
          _buildParameterCard(
            'TDS',
            parameters['tds']!.toStringAsFixed(0),
            'mg/L',
            _getParameterColor('tds', parameters['tds']!),
          ),
        if (parameters.containsKey('conductivity'))
          _buildParameterCard(
            'Conductividad',
            parameters['conductivity']!.toStringAsFixed(0),
            'µS/cm',
            _getParameterColor('conductivity', parameters['conductivity']!),
          ),
        if (parameters.containsKey('turbidity'))
          _buildParameterCard(
            'Turbidez',
            parameters['turbidity']!.toStringAsFixed(1),
            'UNT',
            _getParameterColor('turbidity', parameters['turbidity']!),
          ),
        if (parameters.containsKey('chlorine_residual'))
          _buildParameterCard(
            'Cloro Residual',
            parameters['chlorine_residual']!.toStringAsFixed(2),
            'mg/L',
            _getParameterColor('chlorine_residual', parameters['chlorine_residual']!),
          ),
      ],
    );
  }

  Widget _buildParameterCard(String name, String value, String unit, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationStatus() {
    final isActive = station.status == StationStatus.active;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado de la Estación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.error,
                  color: isActive ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isActive ? 'Estación Activa' : 'Estación Inactiva',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green[900] : Colors.red[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isActive
                            ? 'Transmitiendo datos en tiempo real'
                            : 'No hay datos disponibles',
                        style: TextStyle(
                          fontSize: 14,
                          color: isActive ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getParameterColor(String parameter, double value) {
    // Definir colores basados en los LMP
    switch (parameter) {
      case 'pH':
        if (value >= 6.5 && value <= 8.5) {
          return Colors.green;
        } else if (value >= 6.0 && value <= 9.0) {
          return Colors.orange;
        } else {
          return Colors.red;
        }
      case 'tds':
        if (value <= 500) {
          return Colors.green;
        } else if (value <= 1000) {
          return Colors.orange;
        } else {
          return Colors.red;
        }
      case 'turbidity':
        if (value <= 1.0) {
          return Colors.green;
        } else if (value <= 5.0) {
          return Colors.orange;
        } else {
          return Colors.red;
        }
      case 'chlorine_residual':
        if (value >= 0.5 && value <= 1.5) {
          return Colors.green;
        } else if (value >= 0.3 && value <= 5.0) {
          return Colors.orange;
        } else {
          return Colors.red;
        }
      case 'conductivity':
        if (value <= 500) {
          return Colors.green;
        } else if (value <= 1500) {
          return Colors.orange;
        } else {
          return Colors.red;
        }
      case 'temperature':
        if (value >= 18 && value <= 26) {
          return Colors.green;
        } else if (value >= 10 && value <= 35) {
          return Colors.orange;
        } else {
          return Colors.red;
        }
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    }
  }
}
