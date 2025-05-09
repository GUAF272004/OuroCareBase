// lib/services/api_service.dart

// import 'package:http/http.dart' as http; // Se mantiene por si se usa para otras cosas
// import 'dart:convert'; // Se mantiene por si se usa para otras cosas

// Modelos que este servicio podría necesitar
// import '../models/prescription_model.dart';
// import '../models/lab_result_model.dart';
// import '../models/user_model.dart';

// Servicio de autenticación, si ApiService necesita el token de usuario
// import './auth_service.dart'; // Podrías necesitar descomentar esto

// Definición de la URL base de la API (puede quedar comentado si todas las llamadas se deshabilitan)
// const String RASPBERRY_PI_IP = "192.168.17.143";
// const String API_BASE_URL = "http://$RASPBERRY_PI_IP/api";

class ApiService {
  // final String _baseUrl = API_BASE_URL; // Comentado si no se usa

  // final AuthService? authService; // Si se inyecta para obtener el token
  // ApiService({this.authService});

  // String? get _token => authService?.currentUser?.token; // Obtendría el token falso de AuthService

  // Tus métodos de API (ejemplos) pueden permanecer como están o ser adaptados
  // para devolver datos de prueba locales si también quieres simular respuestas de API.
  // Por ahora, se dejan como estaban, ya que la petición se enfocó en la autenticación.

  // Ejemplo: Obtener recetas (debería adaptarse para local o no llamarse)
  // Future<List<Prescription>> getPatientPrescriptions(String patientId) async {
  //   // Si es local, podrías devolver una lista hardcodeada de recetas
  //   print("ApiService: Solicitando recetas para $patientId (modo local - no implementado)");
  //   return []; // Devolver datos mock si es necesario
  // }

  // ... otros métodos ...
}