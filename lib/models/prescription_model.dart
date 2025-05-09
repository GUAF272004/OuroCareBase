class Prescription {
  final String id;
  final String patientId;
  final String patientName; // Podrías querer esto para mostrar en listas
  final String doctorId;
  final String doctorName; // Podrías querer esto
  final String medication;
  final String dosage;
  final DateTime issueDate;
  String status; // 'PENDIENTE', 'VENDIDO', 'COMPLETADO_LAB', 'CANCELADO'

  Prescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.medication,
    required this.dosage,
    required this.issueDate,
    required this.status,
  });

// TODO: Añadir factory constructor User.fromJson(Map<String, dynamic> json)
// TODO: Añadir toJson()
}

// Lista de ejemplo para simulación
List<Prescription> samplePrescriptions = [
  Prescription(id: 'rx001', patientId: 'p001', patientName: 'Ana Torres', doctorId: 'd001', doctorName: 'Dr. Carlos López', medication: 'Amoxicilina 500mg', dosage: '1 cada 8 horas por 7 días', issueDate: DateTime.now().subtract(Duration(days: 2)), status: 'PENDIENTE'),
  Prescription(id: 'rx002', patientId: 'p001', patientName: 'Ana Torres', doctorId: 'd001', doctorName: 'Dr. Carlos López', medication: 'Paracetamol 1g', dosage: '1 cada 6 horas si hay dolor', issueDate: DateTime.now().subtract(Duration(days: 5)), status: 'VENDIDO'),
];