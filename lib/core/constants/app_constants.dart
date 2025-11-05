class AppConstants {
  // App Information
  static const String appName = 'Monitor de Agua Arequipa';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'water_quality_arequipa.db';
  static const int databaseVersion = 1;
  
  // Water Quality Parameters - Adapted for Peru (DIGESA standards)
  static const Map<String, Map<String, double>> waterQualityStandards = {
    'pH': {
      'min': 6.5,
      'max': 8.5,
      'optimal_min': 7.0,
      'optimal_max': 7.5,
    },
    'dissolved_oxygen': {
      'min': 5.0,
      'max': 14.0,
      'optimal_min': 7.0,
      'optimal_max': 10.0,
    },
    'turbidity': {
      'min': 0.0,
      'max': 1.0,
      'optimal_min': 0.0,
      'optimal_max': 0.3,
    },
    'temperature': {
      'min': 10.0, // Adjusted for Arequipa's altitude climate
      'max': 35.0,
      'optimal_min': 18.0,
      'optimal_max': 25.0,
    },
    'conductivity': {
      'min': 50.0,
      'max': 500.0,
      'optimal_min': 100.0,
      'optimal_max': 300.0,
    },
    'ammonia': {
      'min': 0.0,
      'max': 0.5,
      'optimal_min': 0.0,
      'optimal_max': 0.02,
    },
    'nitrites': {
      'min': 0.0,
      'max': 1.0,
      'optimal_min': 0.0,
      'optimal_max': 0.1,
    },
    'nitrates': {
      'min': 0.0,
      'max': 10.0,
      'optimal_min': 0.0,
      'optimal_max': 5.0,
    },
  };
  
  // Simulation Settings - More critical for informal settlements
  static const int dataUpdateIntervalSeconds = 30;
  static const int historicalDataDays = 30;
  static const int maxStationsSimulated = 10;
  
  // Geographic bounds for Arequipa, Peru
  static const double arequipaLatMin = -16.5;
  static const double arequipaLatMax = -16.3;
  static const double arequipaLngMin = -71.6;
  static const double arequipaLngMax = -71.4;
  
  // Default locations for water monitoring stations in Arequipa's informal settlements
  static const List<Map<String, dynamic>> defaultStations = [
    {
      'id': 'station_001',
      'name': 'Alto Selva Alegre - Pozo Comunitario',
      'latitude': -16.3988,
      'longitude': -71.5369,
      'description': 'Estación de monitoreo en pozo comunitario de pueblo joven',
    },
    {
      'id': 'station_002', 
      'name': 'Villa El Salvador - Tanque Cisterna',
      'latitude': -16.4102,
      'longitude': -71.5234,
      'description': 'Monitoreo de agua en tanque cisterna de asentamiento humano',
    },
    {
      'id': 'station_003',
      'name': 'Cerro Colorado - Pozo Artesanal',
      'latitude': -16.3756,
      'longitude': -71.5842,
      'description': 'Control de calidad en pozo artesanal de zona periférica',
    },
    {
      'id': 'station_004',
      'name': 'Ciudad de Dios - Punto de Acopio',
      'latitude': -16.4234,
      'longitude': -71.5123,
      'description': 'Estación en punto de acopio de agua para comunidad',
    },
    {
      'id': 'station_005',
      'name': 'Río Seco - Captación Río Chili',
      'latitude': -16.3567,
      'longitude': -71.5678,
      'description': 'Monitoreo cerca de captación del río Chili',
    },
  ];
  
  // Alert Types - Critical for informal settlements
  static const Map<String, String> alertTypes = {
    'critical': 'Crítico - No apto para consumo',
    'warning': 'Advertencia - Requiere tratamiento',
    'info': 'Información - Monitoreo continuo',
  };
  
  // Notification Settings
  static const String notificationChannelId = 'arequipa_water_alerts';
  static const String notificationChannelName = 'Alertas de Agua Segura';
  static const String notificationChannelDescription = 
      'Notificaciones sobre calidad del agua en pueblos jóvenes de Arequipa';
}