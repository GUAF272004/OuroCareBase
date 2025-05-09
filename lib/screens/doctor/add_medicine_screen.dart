// lib/screens/doctor/add_medicine_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; // Para generar un ID simple
import '../../models/medicine_item_model.dart';

class AddMedicineScreen extends StatefulWidget {
  AddMedicineScreen(); // No necesita patientId/Name aquí si solo devuelve el item

  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _dosage = '';
  String _instructions = '';
  bool _isLoading = false; // Podrías usarlo si hay validación asíncrona

  String _generateRandomId() {
    // Generador de ID simple para el ejemplo
    return Random().nextInt(100000).toString();
  }

  void _submitMedicineItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final newMedicineItem = MedicineItem(
      id: _generateRandomId(), // Generar un ID único
      name: _name,
      dosage: _dosage,
      instructions: _instructions,
    );

    // Simulación de proceso
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() => _isLoading = false);
      Navigator.of(context).pop(newMedicineItem); // Devuelve el item de medicina
    });
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Dosis (ej. 1 comprimido cada 8 horas)', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese la dosis' : null,
                onSaved: (value) => _dosage = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Instrucciones Adicionales (ej. durante 7 días, con comidas)', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (value) => _instructions = value ?? '',
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline),
                onPressed: _submitMedicineItem,
                label: Text('Añadir a Receta'),
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