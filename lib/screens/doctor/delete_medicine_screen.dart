// lib/screens/doctor/delete_medicine_screen.dart
import 'package:flutter/material.dart';
import '../../models/medicine_item_model.dart';

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
    _medicinesToDelete = List.from(widget.currentMedicines); // Copia para trabajar
    _selectedStates = List<bool>.filled(_medicinesToDelete.length, false);
  }

  void _confirmAndDelete() {
    List<MedicineItem> remainingMedicines = [];
    for (int i = 0; i < _medicinesToDelete.length; i++) {
      if (!_selectedStates[i]) {
        remainingMedicines.add(_medicinesToDelete[i]);
      }
    }
    Navigator.of(context).pop(remainingMedicines); // Devuelve la lista actualizada
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
              tooltip: 'Eliminar Seleccionados',
              onPressed: _confirmAndDelete,
            ),
        ],
      ),
      body: _medicinesToDelete.isEmpty
          ? Center(
        child: Text(
          'No hay medicamentos para eliminar.',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
              style: Theme.of(context).textTheme.titleMedium,
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
                    subtitle: Text('Dosis: ${medicine.dosage}\nInst.: ${medicine.instructions}'),
                    value: _selectedStates[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedStates[index] = value ?? false;
                      });
                    },
                    secondary: Icon(Icons.medication_outlined, color: Theme.of(context).primaryColor),
                  ),
                );
              },
            ),
          ),
          if (_selectedCount > 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete_forever_outlined),
                label: Text('Eliminar ($_selectedCount) Medicamento(s)'),
                onPressed: _confirmAndDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: Size(double.infinity, 50), // Botón ancho
                ),
              ),
            ),
        ],
      ),
    );
  }
}