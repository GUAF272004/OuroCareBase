import 'package:intl/intl.dart';

class LabResultItem { // Para múltiples resultados dentro de una orden
  String? id;
  String name; // Ej: Glucosa, Colesterol HDL
  String value;
  String units;
  String? referenceRange; // Ej: 70-100 mg/dL

  LabResultItem({
    this.id,
    required this.name,
    required this.value,
    required this.units,
    this.referenceRange,
  });

  factory LabResultItem.fromJson(Map<String, dynamic> json) {
    return LabResultItem(
      id: json['lab_result_item_id'] as String?,
      name: json['name'] as String,
      value: json['value'] as String,
      units: json['units'] as String,
      referenceRange: json['reference_range'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lab_result_item_id': id,
      'name': name,
      'value': value,
      'units': units,
      'reference_range': referenceRange,
    };
  }
}


class LabResult { // Representa el conjunto de resultados para una LabOrder
  final String resultId; // ID del registro de resultado general
  final String orderId; // FK a LabOrders
  final String patientId;
  final String labTechnicianId; // Quién registró
  final List<LabResultItem> items; // Lista de resultados específicos
  final DateTime resultDate; // Fecha en que se emite el resultado
  String notes; // Notas adicionales del laboratorio
  final String? filePath; // Para un PDF adjunto, por ejemplo

  LabResult({
    required this.resultId,
    required this.orderId,
    required this.patientId,
    required this.labTechnicianId,
    required this.items,
    required this.resultDate,
    required this.notes,
    this.filePath,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List? ?? [];
    List<LabResultItem> parsedItems = itemsJson
        .map((item) => LabResultItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return LabResult(
      resultId: json['result_id'] as String,
      orderId: json['order_id'] as String,
      patientId: json['patient_id'] as String,
      labTechnicianId: json['lab_technician_id'] as String,
      items: parsedItems,
      resultDate: DateTime.parse(json['result_date'] as String),
      notes: json['notes'] as String? ?? '',
      filePath: json['file_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result_id': resultId,
      'order_id': orderId,
      'patient_id': patientId,
      'lab_technician_id': labTechnicianId,
      'items': items.map((item) => item.toJson()).toList(),
      'result_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(resultDate),
      'notes': notes,
      'file_path': filePath,
    };
  }
}