// lib/models/medicine_item_model.dart
import 'package:flutter/material.dart'; // Necesario para TimeOfDay si se usa en el futuro

// Enumeración para los tipos de frecuencia
enum FrequencyType {
  hours,      // Cada X horas
  dailySpecificTimes, // X veces al día en horarios específicos (requeriría List<TimeOfDay>)
  dailyXTimes, // X veces al día (distribución general)
  days,       // Cada X días
  asNeeded,   // Según necesidad (PRN)
  once,       // Dosis única
  other,      // Otro tipo de frecuencia (descrito en instrucciones)
}

// Helper para convertir FrequencyType a String legible y viceversa si es necesario
String frequencyTypeToString(FrequencyType type) {
  switch (type) {
    case FrequencyType.hours: return 'Cada X horas';
    case FrequencyType.dailySpecificTimes: return 'Veces al día (horarios específicos)';
    case FrequencyType.dailyXTimes: return 'Veces al día (general)';
    case FrequencyType.days: return 'Cada X días';
    case FrequencyType.asNeeded: return 'Según necesidad';
    case FrequencyType.once: return 'Dosis única';
    case FrequencyType.other: return 'Otra frecuencia';
  }
}

// Lista de unidades de dosis comunes
const List<String> kDoseUnits = [
  'mg', 'g', 'mcg', // Microgramos
  'ml', 'L',
  'comprimido(s)', 'tableta(s)', 'cápsula(s)',
  'gota(s)',
  'cucharadita(s) (5ml)', 'cucharada(s) (15ml)',
  'unidad(es)', 'UI', // Unidades Internacionales
  'aplicación(es)',
  'inhalación(es)', 'puff(s)',
  'supositorio(s)',
  'parche(s)',
  '%', // Para cremas, etc.
  'Otro',
];

class MedicineItem {
  final String id;
  final String name;

  // Dosis
  final double doseQuantity;  // Cantidad numérica de la dosis
  final String doseUnit;      // Unidad de medida para la cantidad (ej. "mg", "comprimido")

  // Frecuencia
  final FrequencyType frequencyType;
  final int? frequencyValue;      // Valor numérico para la frecuencia (ej. 8 para "cada 8 horas", 2 para "2 veces al día")
  // Para FrequencyType.dailySpecificTimes, se necesitaría una lista de TimeOfDay.
  // final List<TimeOfDay>? specificTimes; (Para implementación futura si es necesario)

  // Duración del tratamiento
  final int? durationValue;     // Valor numérico para la duración (ej. 7)
  final String? durationUnit;   // Unidad para la duración (ej. "días", "semanas", "meses")

  // Instrucciones adicionales
  final String? additionalInstructions; // Ej. "con comida", "antes de dormir"

  MedicineItem({
    required this.id,
    required this.name,
    required this.doseQuantity,
    required this.doseUnit,
    required this.frequencyType,
    this.frequencyValue,
    this.durationValue,
    this.durationUnit,
    this.additionalInstructions,
  });

  // Constructor de fábrica para JSON (si se usa con API)
  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      id: json['id'] as String,
      name: json['name'] as String,
      doseQuantity: (json['doseQuantity'] as num).toDouble(),
      doseUnit: json['doseUnit'] as String,
      frequencyType: FrequencyType.values.firstWhere(
            (e) => e.toString() == json['frequencyType'],
        orElse: () => FrequencyType.other, // Default o manejar error
      ),
      frequencyValue: json['frequencyValue'] as int?,
      durationValue: json['durationValue'] as int?,
      durationUnit: json['durationUnit'] as String?,
      additionalInstructions: json['additionalInstructions'] as String?,
    );
  }

  // Método toJson (si se usa con API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'doseQuantity': doseQuantity,
      'doseUnit': doseUnit,
      'frequencyType': frequencyType.toString(),
      'frequencyValue': frequencyValue,
      'durationValue': durationValue,
      'durationUnit': durationUnit,
      'additionalInstructions': additionalInstructions,
    };
  }

  // Helper para obtener una descripción legible de la posología completa
  String get fullDosageDescription {
    String doseStr = "${doseQuantity.toStringAsFixed(doseQuantity.truncateToDouble() == doseQuantity ? 0 : 2)} $doseUnit";
    String freqStr = "";

    switch (frequencyType) {
      case FrequencyType.hours:
        freqStr = "cada ${frequencyValue ?? 'X'} horas";
        break;
      case FrequencyType.dailySpecificTimes:
      // Aquí se usaría specificTimes si estuviera implementado
        freqStr = "${frequencyValue ?? 'X'} veces al día (horarios específicos)";
        break;
      case FrequencyType.dailyXTimes:
        freqStr = "${frequencyValue ?? 'X'} veces al día";
        break;
      case FrequencyType.days:
        freqStr = "cada ${frequencyValue ?? 'X'} días";
        break;
      case FrequencyType.asNeeded:
        freqStr = "según necesidad";
        break;
      case FrequencyType.once:
        freqStr = "dosis única";
        break;
      case FrequencyType.other:
        freqStr = "según indicaciones especiales";
        break;
    }

    String durStr = "";
    if (durationValue != null && durationUnit != null && durationUnit!.isNotEmpty) {
      durStr = "durante $durationValue $durationUnit";
    }

    String finalDesc = "$doseStr $freqStr";
    if (durStr.isNotEmpty) {
      finalDesc += " $durStr";
    }
    if (additionalInstructions != null && additionalInstructions!.isNotEmpty) {
      finalDesc += ". ${additionalInstructions!}";
    }
    return finalDesc.trim();
  }
}