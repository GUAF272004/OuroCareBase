class LabResult {
  final String id;
  final String prescriptionId; // O un ID de orden de laboratorio
  final String patientId;
  final String testName;
  final String resultValue;
  final String units;
  final DateTime resultDate;
  final String notes;

  LabResult({
    required this.id,
    required this.prescriptionId,
    required this.patientId,
    required this.testName,
    required this.resultValue,
    required this.units,
    required this.resultDate,
    required this.notes,
  });
// TODO: Añadir factory constructor User.fromJson(Map<String, dynamic> json)
// TODO: Añadir toJson()
}