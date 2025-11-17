import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthRepository {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  // Register a new user
  static Future<void> register({
    required String name,
    required String email,
    required String dni,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing users
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    
    // Check if email already exists
    final emailExists = users.any((user) => user['email'] == email);
    if (emailExists) {
      throw Exception('Este correo electrónico ya está registrado');
    }
    
    // Check if DNI already exists
    final dniExists = users.any((user) => user['dni'] == dni);
    if (dniExists) {
      throw Exception('Este DNI ya está registrado');
    }
    
    // Add new user
    final newUser = {
      'name': name,
      'email': email,
      'dni': dni,
      'password': password, // En producción, esto debería estar hasheado
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    users.add(newUser);
    
    // Save users
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing users
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    
    // Find user
    final user = users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => null,
    );
    
    if (user == null) {
      throw Exception('Correo electrónico o contraseña incorrectos');
    }
    
    // Save current user (without password)
    final currentUser = Map<String, dynamic>.from(user);
    currentUser.remove('password');
    await prefs.setString(_currentUserKey, jsonEncode(currentUser));
    
    return currentUser;
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) return null;
    
    return jsonDecode(userJson);
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}
