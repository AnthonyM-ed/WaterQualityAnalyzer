import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/data/services/firebase_data_service.dart';

class AuthRepository {
  static final _auth = FirebaseAuth.instance;
  static final _firebaseData = FirebaseDataService();

  // NOTA: Si el registro falla con error "CONFIGURATION_NOT_FOUND",
  // es necesario desactivar reCAPTCHA en Firebase Console > Authentication > Settings
  // Ver docs/FIREBASE_AUTH_FIX.md para más detalles
  
  // Register a new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String dni,
    required String password,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error al crear usuario');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Save additional user data to Realtime Database
      await _firebaseData.saveUser(
        uid: user.uid,
        name: name,
        email: email,
        dni: dni,
      );

      return {
        'uid': user.uid,
        'name': name,
        'email': email,
        'dni': dni,
        'createdAt': DateTime.now().toIso8601String(),
      };
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('La contraseña es muy débil');
        case 'email-already-in-use':
          throw Exception('Este correo electrónico ya está registrado');
        case 'invalid-email':
          throw Exception('Correo electrónico inválido');
        default:
          throw Exception('Error al registrar: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error al iniciar sesión');
      }

      // Update last login in Realtime Database
      await _firebaseData.updateUserLastLogin(user.uid);

      // Get user data from Realtime Database
      final userData = await _firebaseData.getUser(user.uid);

      return {
        'uid': user.uid,
        'name': userData?['name'] ?? user.displayName ?? 'Usuario',
        'email': user.email ?? email,
        'dni': userData?['dni'] ?? '',
        'lastLogin': DateTime.now().toIso8601String(),
      };
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No existe una cuenta con este correo electrónico');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta');
        case 'invalid-email':
          throw Exception('Correo electrónico inválido');
        case 'user-disabled':
          throw Exception('Esta cuenta ha sido deshabilitada');
        default:
          throw Exception('Error al iniciar sesión: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Get additional user data from Realtime Database
      final userData = await _firebaseData.getUser(user.uid);

      return {
        'uid': user.uid,
        'name': userData?['name'] ?? user.displayName ?? 'Usuario',
        'email': user.email ?? '',
        'dni': userData?['dni'] ?? '',
        'createdAt': userData?['createdAt'] ?? '',
      };
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // Get current Firebase User
  static User? get currentFirebaseUser => _auth.currentUser;

  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
