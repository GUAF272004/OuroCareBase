import 'package:intl/intl.dart';

class LabOrderModel {
  final String orderId;
  final String? prescriptionId;
  final String patientId;
  final String patientName; // Denormalizado para fácil visualización
  final String doctorId;
  final String doctorName; // Denormalizado
  final String? testTypeId;
  final String testName; // Puede ser un nombre genérico o del TestType
  final DateTime orderDate;
  String status; // 'PENDIENTE', 'MUESTRA_RECIBIDA', 'EN_PROCESO', 'RESULTADO_LISTO', 'CANCELADO'

  LabOrderModel({
    required this.orderId,
    this.prescriptionId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    this.testTypeId,
    required this.testName,
    required this.orderDate,
    required this.status,
  });

  factory LabOrderModel.fromJson(Map<String, dynamic> json) {
    return LabOrderModel(
      orderId: json['order_id'] as String,
      prescriptionId: json['prescription_id'] as String?,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? 'N/A',
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String? ?? 'N/A',
      testTypeId: json['test_type_id'] as String?,
      testName: json['test_name'] as String? ?? 'Prueba sin especificar',
      orderDate: DateTime.parse(json['order_date'] as String),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'prescription_id': prescriptionId,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'test_type_id': testTypeId,
      'test_name': testName,
      'order_date': DateFormat('yyyy-MM-dd').format(orderDate),
      'status': status,
    };
  }
}