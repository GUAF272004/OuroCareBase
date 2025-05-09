// lib/models/medication_schedule_entry_model.dart
import 'package:intl/intl.dart';

class MedicationScheduleEntry {
  final String scheduleId; // Unique ID for this specific scheduled instance
  final String prescriptionId;
  final String medicineItemId;
  final String patientId;
  final String medicationName;
  final String dosage; // Ej: "1 comprimido", "500 mg" (poblado por el backend desde MedicineItem)
  final DateTime dueTime; // Hora programada
  DateTime? takenAt; // Hora real de toma
  String status; // 'PENDIENTE', 'TOMADO', 'OMITIDO'

  MedicationScheduleEntry({
    required this.scheduleId,
    required this.prescriptionId,
    required this.medicineItemId,
    required this.patientId,
    required this.medicationName,
    required this.dosage,
    required this.dueTime,
    this.takenAt,
    required this.status,
  });

  factory MedicationScheduleEntry.fromJson(Map<String, dynamic> json) {
    return MedicationScheduleEntry(
      scheduleId: json['schedule_id'] as String,
      prescriptionId: json['prescription_id'] as String,
      medicineItemId: json['medicine_item_id'] as String,
      patientId: json['patient_id'] as String,
      medicationName: json['medication_name'] as String,
      dosage: json['dosage'] as String,
      dueTime: DateTime.parse(json['due_time'] as String),
      takenAt: json['taken_at'] != null ? DateTime.parse(json['taken_at'] as String) : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'prescription_id': prescriptionId,
      'medicine_item_id': medicineItemId,
      'patient_id': patientId,
      'medication_name': medicationName,
      'dosage': dosage,
      'due_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(dueTime),
      'taken_at': takenAt != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(takenAt!) : null,
      'status': status,
    };
  }
}