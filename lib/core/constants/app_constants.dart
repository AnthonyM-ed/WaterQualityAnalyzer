class AppConstants {
  // App Information
  static const String appName = 'Monitor Río Acarí';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'water_quality_acari.db';
  static const int databaseVersion = 1;
  
  // Water Quality Parameters - LMP para Río Acarí (DIGESA standards)
  static const Map<String, Map<String, double>> waterQualityStandards = {
    'pH': {
      'min': 6.5,
      'max': 8.5,
      'optimal_min': 7.0,
      'optimal_max': 7.5,
    },
    'tds': { // Total Dissolved Solids (ppm = mg/L)
      'min': 0.0,
      'max': 1000.0, // LMP
      'optimal_min': 0.0,
      'optimal_max': 500.0,
    },
    'turbidity': { // UNT
      'min': 0.0,
      'max': 5.0, // LMP
      'optimal_min': 0.0,
      'optimal_max': 1.0,
    },
    'chlorine_residual': { // Cloro residual mg/L
      'min': 0.5, // LMP mínimo
      'max': 5.0, // LMP máximo
      'optimal_min': 0.5,
      'optimal_max': 1.5,
    },
    'temperature': {
      'min': 10.0,
      'max': 35.0,
      'optimal_min': 18.0,
      'optimal_max': 26.0,
    },
    'conductivity': { // µS/cm
      'min': 50.0,
      'max': 4000.0, // Ajustado para datos de Acarí
      'optimal_min': 100.0,
      'optimal_max': 500.0,
    },
  };
  
  // Simulation Settings - Cuenca Río Acarí
  static const int dataUpdateIntervalSeconds = 30;
  static const int historicalDataDays = 30;
  static const int maxStationsSimulated = 3; // CA-08, CA-09, CA-10
  
  // Geographic bounds for Acarí, Caravelí - Arequipa, Peru
  static const double acariLatMin = -15.45;
  static const double acariLatMax = -15.40;
  static const double acariLngMin = -74.65;
  static const double acariLngMax = -74.55;
  
  // Estaciones de monitoreo en cuenca del Río Acarí
  // Datos basados en tesis: Parámetros fisicoquímicos cuenca río Acarí, 2008
  static const List<Map<String, dynamic>> defaultStations = [
    {
      'id': 'CA-08',
      'name': 'CA-08 - Zona Media Alta',
      'latitude': -15.42650995824915,
      'longitude': -74.61396546303129,
      'elevation': 1200.0,
      'description': 'Estación aguas arriba - Control de calidad zona alta',
    },
    {
      'id': 'CA-09',
      'name': 'CA-09 - Pueblo Acarí',
      'latitude': -15.432483077524447,
      'longitude': -74.61690904237376,
      'elevation': 430.0,
      'description': 'Estación principal cercana al pueblo de Acarí',
    },
    {
      'id': 'CA-10',
      'name': 'CA-10 - Zona Baja',
      'latitude': -15.43953712726241, 
      'longitude': -74.61395127652342,
      'elevation': 420.0,
      'description': 'Estación aguas abajo - Monitoreo impacto urbano',
    },
  ];
  
  // Alert Types - Cuenca Río Acarí
  static const Map<String, String> alertTypes = {
    'critical': 'Crítico - Supera LMP',
    'warning': 'Advertencia - Cerca de LMP',
    'info': 'Información - Dentro de LMP',
  };
  
  // Notification Settings
  static const String notificationChannelId = 'acari_water_alerts';
  static const String notificationChannelName = 'Alertas Río Acarí';
  static const String notificationChannelDescription = 
      'Notificaciones sobre calidad del agua en cuenca del río Acarí, Caravelí';
}