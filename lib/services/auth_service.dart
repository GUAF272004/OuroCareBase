import 'dart:convert'; // Para json.decode/encode (si usas http)
import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http; // Descomentar para llamadas HTTP reales
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para almacenar token

import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isAttemptingLogin = false; // Para el estado de carga inicial
  // final _storage = FlutterSecureStorage(); // Para persistencia del token

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAttemptingLogin => _isAttemptingLogin;

  AuthService() {
    _tryAutoLogin(); // Intenta loguear automáticamente al iniciar el servicio
  }

  Future<void> _tryAutoLogin() async {
    _isAttemptingLogin = true;
    notifyListeners();

    // TODO: Implementar lógica para leer token de flutter_secure_storage
    // final String? token = await _storage.read(key: 'authToken');
    // final String? userDataString = await _storage.read(key: 'userData');

    // if (token != null && userDataString != null) {
    //   try {
    //     final Map<String, dynamic> userData = json.decode(userDataString);
    //     _currentUser = User.fromJson(userData);
    //     // Podrías querer validar el token con el backend aquí
    //   } catch (e) {
    //     // Error al decodificar datos, limpiar
    //     await logout();
    //   }
    // }
    await Future.delayed(Duration(milliseconds: 500)); // Simula una pequeña espera

    _isAttemptingLogin = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // --- SIMULACIÓN DE LLAMADA A API ---
    // En una aplicación real, harías una petición HTTP a tu backend
    // final url = Uri.parse('TU_API_ENDPOINT/login');
    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode({'email': email, 'password': password}),
    //   );
    //   if (response.statusCode == 200) {
    //     final responseData = json.decode(response.body);
    //     _currentUser = User.fromJson(responseData['user']); // Asume que el backend devuelve 'user' y 'token'
    //     // String token = responseData['token'];
    //     // await _storage.write(key: 'authToken', value: token);
    //     // await _storage.write(key: 'userData', value: json.encode(_currentUser!.toJson()));
    //     notifyListeners();
    //     return true;
    //   } else {
    //     // Manejar errores del servidor (ej. credenciales incorrectas)
    //     print('Error de login: ${response.body}');
    //     return false;
    //   }
    // } catch (error) {
    //   // Manejar errores de red u otros
    //   print('Excepción de login: $error');
    //   return false;
    // }

    // --- INICIO DE SIMULACIÓN ---
    await Future.delayed(Duration(seconds: 1)); // Simular llamada de red
    if (email.toLowerCase() == 'paciente@test.com' && password == 'password') {
      _currentUser = User(id: 'p001', name: 'Ana Torres', email: email, role: UserRole.patient, token: 'fakePatientToken123');
    } else if (email.toLowerCase() == 'doctor@test.com' && password == 'password') {
      _currentUser = User(id: 'd001', name: 'Dr. Carlos López', email: email, role: UserRole.doctor, token: 'fakeDoctorToken123');
    } else if (email.toLowerCase() == 'ventas@test.com' && password == 'password') {
      _currentUser = User(id: 's001', name: 'Sofía Méndez', email: email, role: UserRole.salesManager, token: 'fakeSalesToken123');
    } else if (email.toLowerCase() == 'lab@test.com' && password == 'password') {
      _currentUser = User(id: 'l001', name: 'Luis Gómez', email: email, role: UserRole.labManager, token: 'fakeLabToken123');
    } else {
      _currentUser = null;
      notifyListeners();
      return false;
    }
    // --- FIN DE SIMULACIÓN ---

    // Si el login simulado es exitoso, "guardamos" los datos (simulado)
    // if (_currentUser != null) {
    //   await _storage.write(key: 'authToken', value: _currentUser!.token);
    //   await _storage.write(key: 'userData', value: json.encode(_currentUser!.toJson()));
    // }

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    // await _storage.delete(key: 'authToken');
    // await _storage.delete(key: 'userData');
    notifyListeners();
  }
}