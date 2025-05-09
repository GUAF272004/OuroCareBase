// lib/screens/doctor/add_medicine_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para TextInputFormatter
import 'dart:math'; // Para generar un ID simple
import '../../models/medicine_item_model.dart'; // Asegúrate que la ruta sea correcta

class AddMedicineScreen extends StatefulWidget {
  AddMedicineScreen();

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // State variables for the form fields
  String _name = '';
  double? _doseQuantity;
  String? _selectedDoseUnit; // Unidad de dosis seleccionada
  FrequencyType _selectedFrequencyType = FrequencyType.dailyXTimes; // Valor inicial
  int? _frequencyValue;
  int? _durationValue;
  String? _selectedDurationUnit; // "días", "semanas", "meses"
  String _additionalInstructions = '';

  final List<String> _durationUnits = ['días', 'semanas', 'meses'];

  String _generateRandomId() {
    return 'med_${Random().nextInt(100000)}';
  }

  void _submitMedicineItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save(); // Llama a onSaved de cada TextFormField

    // Validaciones adicionales que no cubre el validator de cada campo
    if (_selectedDoseUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, seleccione una unidad de dosis.')),
      );
      return;
    }
    if ((_selectedFrequencyType == FrequencyType.hours ||
        _selectedFrequencyType == FrequencyType.days ||
        _selectedFrequencyType == FrequencyType.dailyXTimes) &&
        _frequencyValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingrese un valor para la frecuencia.')),
      );
      return;
    }
    if (_durationValue != null && _selectedDurationUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, seleccione una unidad para la duración.')),
      );
      return;
    }


    setState(() => _isLoading = true);

    final newMedicineItem = MedicineItem(
      id: _generateRandomId(),
      name: _name,
      doseQuantity: _doseQuantity!,
      doseUnit: _selectedDoseUnit!,
      frequencyType: _selectedFrequencyType,
      frequencyValue: _frequencyValue,
      durationValue: _durationValue,
      durationUnit: _selectedDurationUnit,
      additionalInstructions: _additionalInstructions,
    );

    // Simulación de proceso
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(newMedicineItem);
      }
    });
  }

  Widget _buildFrequencyValueField() {
    bool needsValue = _selectedFrequencyType == FrequencyType.hours ||
        _selectedFrequencyType == FrequencyType.days ||
        _selectedFrequencyType == FrequencyType.dailyXTimes;

    if (!needsValue) return SizedBox.shrink();

    String label = '';
    if (_selectedFrequencyType == FrequencyType.hours) label = 'Cada (Horas)';
    if (_selectedFrequencyType == FrequencyType.days) label = 'Cada (Días)';
    if (_selectedFrequencyType == FrequencyType.dailyXTimes) label = 'Número de veces al día';

    return TextFormField(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (needsValue && (value == null || value.isEmpty)) {
          return 'Ingrese el valor de frecuencia';
        }
        if (value != null && int.tryParse(value) == null) {
          return 'Ingrese un número válido';
        }
        return null;
      },
      onSaved: (value) => _frequencyValue = (value != null && value.isNotEmpty) ? int.parse(value) : null,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Medicamento'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Detalles del Medicamento',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre del Medicamento', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese el nombre del medicamento' : null,
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 16),

              // Dosis
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Cantidad Dosis', border: OutlineInputBorder()),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Cantidad?';
                        if (double.tryParse(value) == null) return 'Número?';
                        return null;
                      },
                      onSaved: (value) => _doseQuantity = double.parse(value!),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Unidad Dosis', border: OutlineInputBorder()),
                      value: _selectedDoseUnit,
                      hint: Text('Seleccione'),
                      items: kDoseUnits.map((String unit) {
                        return DropdownMenuItem<String>(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedDoseUnit = value),
                      validator: (value) => value == null ? 'Unidad?' : null,
                      // onSaved no es necesario para DropdownButtonFormField si se usa onChanged y un state var
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Frecuencia
              DropdownButtonFormField<FrequencyType>(
                decoration: InputDecoration(labelText: 'Frecuencia', border: OutlineInputBorder()),
                value: _selectedFrequencyType,
                items: FrequencyType.values.map((FrequencyType type) {
                  return DropdownMenuItem<FrequencyType>(
                    value: type,
                    child: Text(frequencyTypeToString(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequencyType = value!;
                    // Resetear _frequencyValue si el nuevo tipo no lo necesita
                    if (_selectedFrequencyType == FrequencyType.asNeeded ||
                        _selectedFrequencyType == FrequencyType.once ||
                        _selectedFrequencyType == FrequencyType.other) {
                      _frequencyValue = null;
                    }
                  });
                },
                // No necesita validator si siempre hay un valor seleccionado por defecto
              ),
              SizedBox(height: 10),
              _buildFrequencyValueField(), // Campo dinámico para el valor de la frecuencia
              SizedBox(height: 16),

              // Duración
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Duración (Valor)', hintText: "Ej: 7", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return 'Número?';
                        }
                        // Es válido si está vacío, pero si hay unidad, se requiere valor
                        if (value != null && value.isNotEmpty && _selectedDurationUnit != null && (value.isEmpty )) {
                          return 'Valor?';
                        }
                        if (value != null && value.isEmpty && _selectedDurationUnit != null) {
                          return 'Valor?';
                        }
                        return null;
                      },
                      onSaved: (value) => _durationValue = (value != null && value.isNotEmpty) ? int.parse(value) : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Unidad Duración', border: OutlineInputBorder()),
                      value: _selectedDurationUnit,
                      hint: Text('Opcional'),
                      items: _durationUnits.map((String unit) {
                        return DropdownMenuItem<String>(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedDurationUnit = value),
                      validator: (value) {
                        // Si hay valor de duración, se requiere unidad
                        if (_durationValue != null && value == null) {
                          return 'Unidad?';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Instrucciones Adicionales
              TextFormField(
                decoration: InputDecoration(labelText: 'Instrucciones Adicionales', hintText: "Ej: con comida, agitar antes de usar", border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (value) => _additionalInstructions = value ?? '',
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline),
                onPressed: _submitMedicineItem,
                label: Text('Añadir Medicamento'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}