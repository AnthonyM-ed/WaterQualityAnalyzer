class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.waterquality.example.com';
  static const String mockApiUrl = 'https://mockapi.example.com';
  
  // Endpoints
  static const String authEndpoint = '/auth';
  static const String stationsEndpoint = '/stations';
  static const String sensorsEndpoint = '/sensors';
  static const String measurementsEndpoint = '/measurements';
  static const String alertsEndpoint = '/alerts';
  static const String usersEndpoint = '/users';
  
  // API Keys (Para servicios reales)
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
  static const String mapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Request timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}