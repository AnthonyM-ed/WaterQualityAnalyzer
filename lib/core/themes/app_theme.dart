import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales de la aplicación
  static const Color primaryColor = Color(0xFF2196F3); // Azul agua
  static const Color secondaryColor = Color(0xFF4CAF50); // Verde naturaleza
  static const Color accentColor = Color(0xFF009688); // Turquesa
  static const Color errorColor = Color(0xFFE57373); // Rojo suave
  static const Color warningColor = Color(0xFFFFB74D); // Naranja
  static const Color successColor = Color(0xFF81C784); // Verde claro
  
  // Colores de calidad del agua
  static const Color excellentColor = Color(0xFF4CAF50); // Verde
  static const Color goodColor = Color(0xFF8BC34A); // Verde claro
  static const Color moderateColor = Color(0xFFFFC107); // Amarillo
  static const Color poorColor = Color(0xFFFF9800); // Naranja
  static const Color veryPoorColor = Color(0xFFF44336); // Rojo
  
  // Tema claro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
  
  // Tema oscuro
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: Colors.grey[800],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
  
  // Colores según el estado de calidad del agua
  static Color getQualityColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return excellentColor;
      case 'good':
        return goodColor;
      case 'moderate':
        return moderateColor;
      case 'poor':
        return poorColor;
      case 'very_poor':
        return veryPoorColor;
      default:
        return Colors.grey;
    }
  }
  
  // Colores según la severidad de alertas
  static Color getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return successColor;
      case 'medium':
        return warningColor;
      case 'high':
        return Colors.orange;
      case 'critical':
        return errorColor;
      default:
        return Colors.grey;
    }
  }
  
  // Estilos de texto personalizados
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
  
  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}