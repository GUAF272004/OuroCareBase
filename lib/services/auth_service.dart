// Archivo: lib/services/auth_service.dart

import 'dart:convert'; // Para json.decode/encode (aunque no se use directamente en local)
import 'dart:async'; // Para TimeoutException (aunque no se use directamente en local)
import 'package:flutter/foundation.dart'; // Para ChangeNotifier
// import 'package:http/http.dart' as http; // Paquete para peticiones HTTP - Comentado
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para almacenar token de forma segura

import '../models/user_model.dart'; // Asegúrate que la ruta sea correcta

// Definición de la URL base de la API (Comentado, no necesario para local)
// const String RASPBERRY_PI_IP = "192.168.17.143";
// const String API_BASE_URL = "http://$RASPBERRY_PI_IP/api";

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isAttemptingLogin = false;
  String? _authErrorMessage;

  // Datos de prueba locales
  final List<Map<String, dynamic>> _testUsers = [
    {
      'id': '1',
      'name': 'Sarahi',
      'email': 'paciente@test.com',
      'password': 'password',
      'role': 'patient', // Asegúrate que coincida con tus UserRole en user_model.dart
      'token': 'fake_patient_token_local_123'
    },
    {
      'id': '2',
      'name': 'Dr Perez',
      'email': 'doctor@test.com',
      'password': 'password',
      'role': 'doctor', // Asegúrate que coincida con tus UserRole en user_model.dart
      'token': 'fake_doctor_token_local_456'
    },
    {
      'id': '3',
      'name': 'Juanito',
      'email': 'ventas@test.com',
      'password': 'password',
      'role': 'salesManager', // o 'sales_manager', ajusta según tu UserRole
      'token': 'fake_sales_token_local_789'
    },
    {
      'id': '4',
      'name': 'Karla',
      'email': 'lab@test.com',
      'password': 'password',
      'role': 'labManager', // o 'lab_manager', ajusta según tu UserRole
      'token': 'fake_lab_token_local_000'
    }
  ];

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAttemptingLogin => _isAttemptingLogin;
  String? get authErrorMessage => _authErrorMessage;

  AuthService() {
    // _tryAutoLogin(); // Podrías implementar un autologin local si guardas la sesión
  }

  Future<void> _tryAutoLogin() async {
    _isAttemptingLogin = true;
    _authErrorMessage = null;
    notifyListeners();

    // Lógica de autologin local (ejemplo, si guardaras algo en SharedPreferences o similar)
    // Por ahora, simplemente simulamos que no hay sesión previa.
    await Future.delayed(const Duration(milliseconds: 100));

    _isAttemptingLogin = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isAttemptingLogin = true;
    _authErrorMessage = null;
    notifyListeners();

    print("Intentando login local con email: $email");

    // Simula una pequeña demora de red
    await Future.delayed(const Duration(seconds: 1));

    try {
      final userIndex = _testUsers.indexWhere(
              (user) => user['email'] == email && user['password'] == password);

      if (userIndex != -1) {
        final userData = _testUsers[userIndex];
        _currentUser = User.fromJson({
          'id': userData['id'],
          'name': userData['name'],
          'email': userData['email'],
          'role': userData['role'], // El User.fromJson debe manejar esto
          'token': userData['token'],
        });

        print("Login local exitoso para: ${_currentUser?.email}, Rol: ${_currentUser?.role.toString()}");
        _isAttemptingLogin = false;
        notifyListeners();
        return true;
      } else {
        _authErrorMessage = 'Credenciales locales incorrectas.';
        _currentUser = null;
        print("Error de login local: $_authErrorMessage");
        _isAttemptingLogin = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _authErrorMessage = 'Ocurrió un error durante el login local: $error';
      _currentUser = null;
      print("Error de login local (Excepción): $error");
      _isAttemptingLogin = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authErrorMessage = null;
    // Aquí podrías limpiar cualquier dato de sesión guardado localmente
    print("Usuario deslogueado (local).");
    notifyListeners();
  }
}

// El UserRoleHelper o la lógica dentro de User.fromJson sigue siendo importante
// para convertir el string 'role' a tu enum UserRole.
// class UserRoleHelper {
//   static UserRole parseRole(String? roleString) {
//     if (roleString ==