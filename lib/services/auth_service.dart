// Archivo: lib/services/auth_service.dart

import 'dart:convert'; // Para json.decode/encode
import 'dart:async'; // Para TimeoutException
import 'package:flutter/foundation.dart'; // Para ChangeNotifier
import 'package:http/http.dart' as http; // Paquete para peticiones HTTP
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Para almacenar token de forma segura

import '../models/user_model.dart'; // Asegúrate que la ruta sea correcta

// Definición de la URL base de la API
// ¡¡¡IMPORTANTE!!! Reemplaza "192.168.17.143" con la IP real y actual de tu Raspberry Pi.
const String RASPBERRY_PI_IP = "192.168.17.143";
const String API_BASE_URL = "http://$RASPBERRY_PI_IP/api";

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isAttemptingLogin = false; // Para el estado de carga durante el login
  String? _authErrorMessage; // Para mostrar mensajes de error específicos de autenticación en la UI

  // final _storage = FlutterSecureStorage(); // Para persistencia del token y datos del usuario

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAttemptingLogin => _isAttemptingLogin;
  String? get authErrorMessage => _authErrorMessage;

  AuthService() {
    // _tryAutoLogin(); // Intenta loguear automáticamente al iniciar el servicio si tienes persistencia
  }

  Future<void> _tryAutoLogin() async {
    _isAttemptingLogin = true;
    _authErrorMessage = null;
    notifyListeners();

    // --- Lógica de Autologin (Ejemplo con flutter_secure_storage) ---
    // final String? token = await _storage.read(key: 'authToken');
    // final String? userDataString = await _storage.read(key: 'userData');

    // if (token != null && userDataString != null) {
    //   try {
    //     final Map<String, dynamic> userData = json.decode(userDataString);
    //     // Aquí podrías querer validar el token con el backend antes de confiar en los datos locales.
    //     // Por ejemplo, haciendo una petición a un endpoint /verifyToken o /getProfile.
    //     // Si el token es válido, entonces:
    //     _currentUser = User.fromJson(userData); // Asegúrate que User.fromJson maneje todos los campos necesarios
    //     _currentUser = _currentUser?.copyWith(token: token); // Si el token no está en userData

    //     print("Autologin exitoso para: ${_currentUser?.email}");
    //   } catch (e) {
    //     print("Error al decodificar datos de usuario para autologin: $e");
    //     // Error al decodificar datos o token inválido, limpiar y tratar como no logueado
    //     await logout(); // Limpia _currentUser y el storage
    //   }
    // } else {
    //   print("No hay datos para autologin.");
    // }
    // --- Fin Lógica de Autologin ---

    // Simulación si no hay persistencia real:
    await Future.delayed(Duration(milliseconds: 300)); // Simula una pequeña espera

    _isAttemptingLogin = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final String loginUrl = "$API_BASE_URL/login_user.php";

    _isAttemptingLogin = true;
    _authErrorMessage = null; // Limpiar errores previos antes de un nuevo intento
    notifyListeners();

    try {
      print("Intentando login a: $loginUrl con email: $email");
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15)); // Timeout para la petición

      print("Respuesta del servidor (login): ${response.statusCode}");
      print("Cuerpo de la respuesta (login): ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['user'] != null) {

          // Usar el método estático de User para parsear el rol, o el UserRoleHelper
          // Asegúrate que User.fromJson o un helper maneje la conversión del string del rol al enum UserRole.
          // El User.fromJson en tu user_model.dart ya tiene _parseRole.
          _currentUser = User.fromJson({
            'id': responseData['user']['id'].toString(), // El ID de la BD es INT, el modelo User espera String
            'name': responseData['user']['name'],
            'email': responseData['user']['email'],
            'role': responseData['user']['role'], // Pasar el string del rol
            'token': responseData['token'], // El token generado por PHP
          });

          // Opcional: Guardar el token y los datos del usuario de forma segura
          // await _storage.write(key: 'authToken', value: _currentUser!.token);
          // await _storage.write(key: 'userData', value: json.encode(_currentUser!.toJson()));

          print("Login exitoso para: ${_currentUser?.email}, Rol: ${_currentUser?.role.toString()}");
          notifyListeners();
          return true;
        } else {
          _authErrorMessage = responseData['message'] ?? 'Credenciales incorrectas o error del servidor.';
          _currentUser = null;
          print("Error de login (lógica app): $_authErrorMessage");
          notifyListeners();
          return false;
        }
      } else {
        String serverMessage = response.body;
        try {
          final decodedBody = json.decode(response.body);
          serverMessage = decodedBody['message'] ?? response.body;
        } catch (e) { /* El cuerpo no era JSON o no tenía 'message' */ }
        _authErrorMessage = 'Error del servidor (${response.statusCode}): $serverMessage';
        _currentUser = null;
        print("Error de login (HTTP ${response.statusCode}): $_authErrorMessage");
        notifyListeners();
        return false;
      }
    } on TimeoutException catch (e) {
      _authErrorMessage = 'Tiempo de espera agotado al conectar con el servidor. Verifica la IP y la red.';
      _currentUser = null;
      print("Error de login (Timeout): $e");
      notifyListeners();
      return false;
    } catch (error) {
      _authErrorMessage = 'No se pudo conectar al servidor o ocurrió un error de red. Verifica tu conexión y la IP del servidor. Detalles: $error';
      _currentUser = null;
      print("Error de login (Excepción general): $error");
      notifyListeners();
      return false;
    } finally {
      _isAttemptingLogin = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _authErrorMessage = null;
    // await _storage.delete(key: 'authToken');
    // await _storage.delete(key: 'userData');
    print("Usuario deslogueado.");
    notifyListeners();
  }
}

// Si User.fromJson no maneja el parseo del string del rol a UserRole directamente,
// o si prefieres un helper separado, puedes usar algo como esto:
// class UserRoleHelper {
//   static UserRole parseRole(String? roleString) {
//     if (roleString == null) return UserRole.unknown;
//     switch (roleString.toLowerCase()) {
//       case 'patient':
//         return UserRole.patient;
//       case 'doctor':
//         return UserRole.doctor;
//       case 'salesmanager':
//       case 'sales_manager':
//         return UserRole.salesManager;
//       case 'labmanager':
//       case 'lab_manager':
//         return UserRole.labManager;
//       default:
//         print("Advertencia: Rol desconocido recibido del backend: '$roleString'");
//         return UserRole.unknown;
//     }
//   }
// }