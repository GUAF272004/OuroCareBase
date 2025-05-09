// lib/models/prescription_model.dart

import 'package:intl/intl.dart'; // Para formatear fechas

class PrescriptionItem {
  final String id;
  final String medicationName;
  final String dosage;
  final String instructions;

  PrescriptionItem({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.instructions,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      id: json['item_id'] as String,
      medicationName: json['medication_name'] as String,
      dosage: json['dosage'] as String,
      instructions: json['instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': id,
      'medication_name': medicationName,
      'dosage': dosage,
      'instructions': instructions,
    };
  }
}

class Prescription {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final List<PrescriptionItem> items;
  final DateTime issueDate;
  String status; // Correcto, es modificable
  DateTime? saleTimestamp; // <<<<<< CORREGIDO: No es final
  String? soldByUserId;  // <<<<<< CORREGIDO: No es final

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.items,
    required this.issueDate,
    required this.status,
    this.saleTimestamp, // Se puede inicializar como null
    this.soldByUserId,  // Se puede inicializar como null
  });

  String get medicationsSummary {
    if (items.isEmpty) return 'N/A';
    return items.map((item) => item.medicationName).join(', ');
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<PrescriptionItem> parsedItems = itemsList
        .map((itemJson) => PrescriptionItem.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    return Prescription(
      id: json['prescription_id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String? ?? 'N/A',
      doctorId: json['doctor_id'] as String,
      doctorName: json['doctor_name'] as String? ?? 'N/A',
      items: parsedItems,
      issueDate: json['issue_date'] != null
          ? DateTime.parse(json['issue_date'] as String)
          : DateTime.now(),
      status: json['status'] as String,
      saleTimestamp: json['sale_timestamp'] != null
          ? DateTime.parse(json['sale_timestamp'] as String)
          : null,
      soldByUserId: json['sold_by_user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'items': items.map((item) => item.toJson()).toList(),
      'issue_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(issueDate),
      'status': status,
      'sale_timestamp': saleTimestamp != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(saleTimestamp!) : null,
      'sold_by_user_id': soldByUserId,
    };
  }
}

// Lista de ejemplo (asegúrate de que esté actualizada si la usas para mocks)
List<Prescription> samplePrescriptions = [
  Prescription(
    id: 'rx001',
    patientId: 'p001',
    patientName: 'Ana Torres',
    doctorId: 'd001',
    doctorName: 'Dr. Carlos López',
    items: [
      PrescriptionItem(id: 'item001', medicationName: 'Amoxicilina 500mg', dosage: '1 cada 8 horas', instructions: 'Por 7 días'),
      PrescriptionItem(id: 'item002', medicationName: 'Ibuprofeno 400mg', dosage: '1 cada 6 horas', instructions: 'Si hay dolor'),
    ],
    issueDate: DateTime.now().subtract(Duration(days: 2)),
    status: 'PENDIENTE',
  ),
  Prescription(
      id: 'rx002',
      patientId: 'p001',
      patientName: 'Ana Torres',
      doctorId: 'd001',
      doctorName: 'Dr. Carlos López',
      items: [
        PrescriptionItem(id: 'item003', medicationName: 'Paracetamol 1g', dosage: '1 cada 6 horas', instructions: 'Si hay dolor o fiebre'),
      ],
      issueDate: DateTime.now().subtract(Duration(days: 5)),
      status: 'VENDIDO', // Ejemplo de un item ya vendido
      saleTimestamp: DateTime.now().subtract(Duration(days: 4)),
      soldByUserId: 'sales_user_01'
  ),
  Prescription(
    id: 'rx003',
    patientId: 'p002', // Otro paciente
    patientName: 'Luis Gómez',
    doctorId: 'd002',
    doctorName: 'Dra. Elena Solís',
    items: [
      PrescriptionItem(id: 'item004', medicationName: 'Loratadina 10mg', dosage: '1 al día', instructions: 'Por 5 días'),
    ],
    issueDate: DateTime.now().subtract(Duration(days: 1)),
    status: 'PENDIENTE',
  ),
];