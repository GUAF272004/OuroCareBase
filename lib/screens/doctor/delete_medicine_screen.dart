// lib/screens/doctor/delete_medicine_screen.dart
import 'package:flutter/material.dart';
import '../../models/medicine_item_model.dart'; // Asegúrate que la ruta sea correcta

class DeleteMedicineScreen extends StatefulWidget {
  final List<MedicineItem> currentMedicines;

  DeleteMedicineScreen({required this.currentMedicines});

  @override
  _DeleteMedicineScreenState createState() => _DeleteMedicineScreenState();
}

class _DeleteMedicineScreenState extends State<DeleteMedicineScreen> {
  late List<MedicineItem> _medicinesToDelete;
  late List<bool> _selectedStates;

  @override
  void initState() {
    super.initState();
    // Crear una nueva lista para evitar modificar la original directamente hasta confirmar
    _medicinesToDelete = List.from(widget.currentMedicines);
    _selectedStates = List<bool>.filled(_medicinesToDelete.length, false);
  }

  void _confirmAndDelete() {
    List<MedicineItem> remainingMedicines = [];
    for (int i = 0; i < _medicinesToDelete.length; i++) {
      if (!_selectedStates[i]) {
        remainingMedicines.add(_medicinesToDelete[i]);
      }
    }
    // Devuelve la lista de medicamentos que NO fueron eliminados
    Navigator.of(context).pop(remainingMedicines);
  }

  int get _selectedCount => _selectedStates.where((isSelected) => isSelected).length;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eliminar Medicamentos'),
        actions: [
          if (_selectedCount > 0)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined),
              tooltip: 'Eliminar Seleccionados ($_selectedCount)',
              onPressed: _confirmAndDelete,
            ),
        ],
      ),
      body: _medicinesToDelete.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No hay medicamentos para eliminar.',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _selectedCount > 0
                  ? '$_selectedCount medicamento(s) seleccionado(s) para eliminar.'
                  : 'Seleccione los medicamentos a eliminar:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _selectedCount > 0 ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _medicinesToDelete.length,
              itemBuilder: (context, index) {
                final medicine = _medicinesToDelete[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: CheckboxListTile(
                    title: Text(medicine.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    // Usar fullDosageDescription para mostrar los detalles
                    subtitle: Text(
                      medicine.fullDosageDescription, // <<--- CAMBIO AQUÍ
                      maxLines: 3, // Permitir varias líneas para la descripción
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: medicine.fullDosageDescription.length > 60, // Ajustar según necesidad
                    value: _selectedStates[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedStates[index] = value ?? false;
                      });
                    },
                    secondary: Icon(Icons.medication_liquid_outlined, color: _selectedStates[index] ? Theme.of(context).primaryColor : Colors.grey),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
          if (_selectedCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0,8.0,16.0,16.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete_forever_outlined),
                label: Text('Confirmar Eliminación ($_selectedCount)'),
                onPressed: _confirmAndDelete,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50), // Botón ancho
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
        ],
      ),
    );
  }
}