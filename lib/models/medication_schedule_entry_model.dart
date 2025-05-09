import 'package:intl/intl.dart';

class MedicationScheduleEntry {
  final String scheduleId;
  final String prescriptionItemId; // ID del item de la receta
  final String patientId;
  final String medicationName;
  final String dosage;
  final DateTime dueTime; // Fecha y hora programada
  DateTime? takenAt; // Fecha y hora en que se tomó, null si no se ha tomado
  String status; // 'PENDIENTE', 'TOMADO', 'OMITIDO'

  MedicationScheduleEntry({
    required this.scheduleId,
    required this.prescriptionItemId,
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
      prescriptionItemId: json['prescription_item_id'] as String,
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
      'prescription_item_id': prescriptionItemId,
      'patient_id': patientId,
      'medication_name': medicationName,
      'dosage': dosage,
      'due_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(dueTime),
      'taken_at': takenAt != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(takenAt!) : null,
      'status': status,
    };
  }
}