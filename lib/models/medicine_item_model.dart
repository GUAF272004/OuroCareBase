class MedicineItem {
  final String id; // Podría ser un UUID generado al añadir
  final String name;
  final String dosage;
  final String instructions;

  MedicineItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
  });
}