import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Si usas Provider para AuthService
import '../models/prescription_model.dart';
import '../models/medication_schedule_entry_model.dart';
import '../models/notification_model.dart';
import '../models/lab_order_model.dart';
import '../models/lab_result_model.dart';
import './auth_service.dart'; // Asumiendo que tienes esto para el token

const String RASPBERRY_PI_IP = "192.168.17.143"; // Reemplaza con la IP de TU RASPBERRY PI
const String API_BASE_URL = "http://$RASPBERRY_PI_IP/api"; // o tu URL de API

class ApiService {
  final String _baseUrl = API_BASE_URL;
  final AuthService? authService; // Opcional, si necesitas token

  ApiService({this.authService});

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (requiresAuth && authService != null && authService!.currentUser != null) {
      // Asumiendo que tu currentUser tiene un token
      // final token = authService!.currentUser!.token;
      // headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- Paciente ---
  Future<List<Prescription>> getPatientPrescriptions(String patientId) async {
    final String url = '$_baseUrl/patients/$patientId/prescriptions'; // Endpoint de ejemplo
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          List<dynamic> prescriptionsJson = responseData['data'];
          return prescriptionsJson.map((data) => Prescription.fromJson(data)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener recetas del servidor.');
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al obtener recetas.');
      }
    } catch (e) {
      print('Error en getPatientPrescriptions: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  Future<List<MedicationScheduleEntry>> getMedicationSchedule(String patientId, DateTime startDate, DateTime endDate) async {
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    final String url = '$_baseUrl/patients/$patientId/medication_schedule?start_date=$formattedStartDate&end_date=$formattedEndDate';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          List<dynamic> scheduleJson = responseData['data'];
          return scheduleJson.map((data) => MedicationScheduleEntry.fromJson(data)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener horario de medicamentos.');
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al obtener horario.');
      }
    } catch (e) {
      print('Error en getMedicationSchedule: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  Future<bool> updateMedicationStatus(String scheduleId, String status, {DateTime? takenAt}) async {
    final String url = '$_baseUrl/medication_schedule/$scheduleId/status';
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'status': status,
        'taken_at': takenAt != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(takenAt) : null,
      });
      final response = await http.post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        // Considerar leer responseData['message'] si está disponible
        throw Exception('Error del servidor (${response.statusCode}) al actualizar estado de medicación.');
      }
    } catch (e) {
      print('Error en updateMedicationStatus: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }


  // --- Doctor ---
  Future<List<NotificationModel>> getDoctorNotifications(String doctorId, {bool unreadOnly = false}) async {
    final String url = '$_baseUrl/doctors/$doctorId/notifications?unread_only=${unreadOnly.toString()}';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          List<dynamic> notificationsJson = responseData['data'];
          return notificationsJson.map((data) => NotificationModel.fromJson(data)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener notificaciones.');
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al obtener notificaciones.');
      }
    } catch (e) {
      print('Error en getDoctorNotifications: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    final url = '$_baseUrl/notifications/$notificationId/mark_read';
    try {
      final headers = await _getHeaders();
      final response = await http.post(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        throw Exception('Error (${response.statusCode}) al marcar notificación como leída');
      }
    } catch (e) {
      print('Error en markNotificationAsRead: $e');
      return false;
    }
  }


  // --- Ventas ---
  Future<List<Prescription>> getPendingPrescriptionsForSales() async {
    // Reutiliza el modelo Prescription, asumiendo que la API devuelve la misma estructura
    final String url = '$_baseUrl/prescriptions?status=PENDIENTE';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          List<dynamic> prescriptionsJson = responseData['data'];
          return prescriptionsJson.map((data) => Prescription.fromJson(data)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener recetas pendientes para venta.');
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al obtener recetas pendientes.');
      }
    } catch (e) {
      print('Error en getPendingPrescriptionsForSales: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  Future<bool> markPrescriptionAsSold(String prescriptionId, String salesPersonId) async {
    final String url = '$_baseUrl/prescriptions/$prescriptionId/sell';
    try {
      final headers = await _getHeaders();
      final body = json.encode({'sales_person_id': salesPersonId, 'sale_timestamp': DateTime.now().toIso8601String()});
      final response = await http.post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al marcar receta como vendida.');
      }
    } catch (e) {
      print('Error en markPrescriptionAsSold: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  Future<List<Prescription>> getSalesHistory(String salesPersonId, DateTime startDate, DateTime endDate) async {
    // Reutiliza el modelo Prescription si contiene saleTimestamp y soldByUserId
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    final String url = '$_baseUrl/sales_history?sales_person_id=$salesPersonId&start_date=$formattedStartDate&end_date=$formattedEndDate';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          List<dynamic> salesJson = responseData['data'];
          // Asumiendo que la API devuelve objetos Prescription con estado 'VENDIDO' y datos de venta
          return salesJson.map((data) => Prescription.fromJson(data)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener historial de ventas.');
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al obtener historial de ventas.');
      }
    } catch (e) {
      print('Error en getSalesHistory: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  // --- Laboratorio ---
  Future<List<LabOrderModel>> getPendingLabOrders() async {
    final String url = '$_baseUrl/lab/orders?status=PENDIENTE,MUESTRA_RECIBIDA,EN_PROCESO'; // O como definas los estados
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          List<dynamic> ordersJson = responseData['data'];
          return ordersJson.map((data) => LabOrderModel.fromJson(data)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener órdenes de laboratorio pendientes.');
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al obtener órdenes pendientes.');
      }
    } catch (e) {
      print('Error en getPendingLabOrders: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  Future<bool> submitLabResult(LabResult labResult) async {
    final String url = '$_baseUrl/lab/orders/${labResult.orderId}/results';
    try {
      final headers = await _getHeaders();
      final body = json.encode(labResult.toJson()); // El modelo LabResult debe tener toJson()
      final response = await http.post(Uri.parse(url), headers: headers, body: body)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al enviar resultado de laboratorio.');
      }
    } catch (e) {
      print('Error en submitLabResult: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }

  Future<List<LabResult>> getLabTestHistory(String labTechnicianId, DateTime startDate, DateTime endDate) async {
    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
    final String url = '$_baseUrl/lab/history?technician_id=$labTechnicianId&start_date=$formattedStartDate&end_date=$formattedEndDate';
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          List<dynamic> historyJson = responseData['data'];
          return historyJson.map((data) => LabResult.fromJson(data)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Error al obtener historial de pruebas de laboratorio.');
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode}) al obtener historial de pruebas.');
      }
    } catch (e) {
      print('Error en getLabTestHistory: $e');
      throw Exception('Error de conexión o al procesar la solicitud: $e');
    }
  }
}