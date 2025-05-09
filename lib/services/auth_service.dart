// Archivo: lib/services/auth_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para guardar token

import '../models/user_model.dart';

// Actualiza esta IP a la de tu Raspberry Pi
const String RASPBERRY_PI_IP = "192.168.17.143"; // Asegúrate que esta sea la IP correcta
const String API_AUTH_BASE_URL = "http://$RASPBERRY_PI_IP/api/auth"; // Ruta a tus scripts de auth

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isAttemptingLogin = false;
  bool _isRegistering = false; // Nuevo estado para el registro
  String? _authErrorMessage;
  // final _secureStorage = const FlutterSecureStorage(); // Para guardar el token

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAttemptingLogin => _isAttemptingLogin;
  bool get isRegistering => _isRegistering; // Getter para el nuevo estado
  String? get authErrorMessage => _authErrorMessage;

  AuthService() {
    // _tryAutoLogin(); // Implementa si guardas el token
  }

  Future<bool> login(String email, String password) async {
    _isAttemptingLogin = true;
    _authErrorMessage = null;
    notifyListeners();

    final String loginUrl = "$API_AUTH_BASE_URL/login.php";
    print("Intentando login a: $loginUrl con email: $email");

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      print("Respuesta del login: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          Map<String, dynamic> userData = responseData['data'];
          // El id de la BD es INT, el modelo User espera String.
          if (userData['id'] != null) {
            userData['id'] = userData['id'].toString();
          }
          _currentUser = User.fromJson(userData);

          // if (_currentUser?.token != null) {
          //   await _secureStorage.write(key: 'userToken', value: _currentUser!.token);
          // }

          print("Login exitoso para: ${_currentUser?.email}, Rol: ${_currentUser?.role.toString()}");
          _isAttemptingLogin = false;
          notifyListeners();
          return true;
        } else {
          _authErrorMessage = responseData['message'] ?? 'Error de autenticación del servidor.';
        }
      } else {
        String serverMessage = 'Error del servidor (${response.statusCode}).';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            serverMessage = errorData['message'];
          }
        } catch (e) {
          // No hacer nada, usar el mensaje por defecto
        }
        _authErrorMessage = serverMessage;
      }
    } catch (error) {
      _authErrorMessage = 'Error de conexión o al procesar la solicitud de login: $error';
      print("Error en login (excepción): $_authErrorMessage");
    }

    _currentUser = null;
    _isAttemptingLogin = false;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    DateTime? birthDate,
    String? bloodType,
  }) async {
    _isRegistering = true;
    _authErrorMessage = null;
    notifyListeners();

    final String registerUrl = "$API_AUTH_BASE_URL/register_patient.php"; // O el nombre de tu script de registro
    print("Intentando registro en: $registerUrl");

    Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password, // La contraseña se envía en texto plano, el backend la hashea
      'phone': phone,
    };

    if (birthDate != null) {
      // Formato YYYY-MM-DD para la base de datos
      requestBody['birth_date'] = "${birthDate.year.toString().padLeft(4, '0')}-"
          "${birthDate.month.toString().padLeft(2, '0')}-"
          "${birthDate.day.toString().padLeft(2, '0')}";
    }
    if (bloodType != null) {
      requestBody['blood_type'] = bloodType;
    }

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 20)); // Ajusta el timeout según sea necesario

      print("Respuesta del registro: ${response.statusCode}");
      print("Cuerpo de la respuesta del registro: ${response.body}");

      final responseData = json.decode(response.body);

      // Un código 201 (Created) es ideal para un registro exitoso
      if (response.statusCode == 201 && responseData['status'] == 'success') {
        _isRegistering = false;
        notifyListeners();
        // Devuelve un mapa con el estado, mensaje y datos (como el user_id)
        return {'success': true, 'message': responseData['message'], 'data': responseData['data']};
      } else {
        _authErrorMessage = responseData['message'] ?? 'Error desconocido del servidor durante el registro.';
        _isRegistering = false;
        notifyListeners();
        return {'success': false, 'message': _authErrorMessage};
      }
    } catch (error) {
      print("Error en registro (excepción Flutter): $error");
      _authErrorMessage = 'Error de conexión o al procesar la solicitud de registro: $error';
      _isRegistering = false;
      notifyListeners();
      return {'success': false, 'message': _authErrorMessage};
    }
  }

  Future<void> logout() async {
    // Opcional: llamar a un endpoint de logout en tu API PHP si invalida tokens
    _currentUser = null;
    _authErrorMessage = null;
    // await _secureStorage.delete(key: 'userToken');
    print("Usuario deslogueado.");
    notifyListeners();
  }
}