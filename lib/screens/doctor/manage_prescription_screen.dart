// lib/screens/doctor/manage_prescription_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/medicine_item_model.dart';
import '../../services/auth_service.dart';
// import '../../services/api_service.dart'; // Para guardar la receta final

import 'add_medicine_screen.dart';
import 'delete_medicine_screen.dart';

class ManagePrescriptionScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  // Podrías pasar más datos del paciente si los tienes (ej. PatientForDoctorView)
  // final PatientForDoctorView patientDetails;

  ManagePrescriptionScreen({
    required this.patientId,
    required this.patientName,
    // required this.patientDetails,
  });

  @override
  _ManagePrescriptionScreenState createState() => _ManagePrescriptionScreenState();
}

class _ManagePrescriptionScreenState extends State<ManagePrescriptionScreen> {
  List<MedicineItem> _addedMedicines = [];
  bool _isSaving = false;

  User? _currentDoctor; // Para mostrar info del doctor

  @override
  void initState() {
    super.initState();
    _currentDoctor = Provider.of<AuthService>(context, listen: false).currentUser;
  }

  void _navigateAndAddMedicine(BuildContext context) async {
    final result = await Navigator.push<MedicineItem>(
      context,
      MaterialPageRoute(builder: (context) => AddMedicineScreen()),
    );

    if (result != null) {
      setState(() {
        _addedMedicines.add(result);
      });
    }
  }

  void _navigateAndDeleteMedicine(BuildContext context) async {
    if (_addedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay medicamentos añadidos para eliminar.')),
      );
      return;
    }
    final result = await Navigator.push<List<MedicineItem>>(
      context,
      MaterialPageRoute(builder: (context) => DeleteMedicineScreen(currentMedicines: _addedMedicines)),
    );

    if (result != null) {
      setState(() {
        _addedMedicines = result;
      });
    }
  }

  Future<void> _savePrescription() async {
    if (_addedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Añada al menos un medicamento antes de guardar.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Datos de la receta completa
    final prescriptionData = {
      'patientId': widget.patientId,
      'patientName': widget.patientName,
      'doctorId': _currentDoctor?.id ?? 'N/A',
      'doctorName': _currentDoctor?.name ?? 'N/A',
      'issueDate': DateTime.now().toIso8601String(),
      'medicines': _addedMedicines.map((med) => {
        'name': med.name,
        'dosage': med.dosage,
        'instructions': med.instructions,
      }).toList(),
      'status': 'PENDIENTE', // Estado inicial de la receta
    };

    // TODO: Llamar al ApiService para guardar `prescriptionData` en el backend/blockchain
    // final apiService = Provider.of<ApiService>(context, listen: false);
    // bool success = await apiService.saveCompletePrescription(prescriptionData);

    // Simulación
    print('Guardando Receta (simulación):');
    print(prescriptionData);
    await Future.delayed(Duration(seconds: 1));
    bool success = true; // Simular éxito

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receta guardada exitosamente para ${widget.patientName}.'), backgroundColor: Colors.green),
      );
      // Limpiar lista y/o navegar fuera
      setState(() {
        _addedMedicines.clear();
      });
      Navigator.of(context).pop(); // Volver a la pantalla anterior (ej. PatientOverviewScreen)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la receta.'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, VoidCallback onPressed, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 18),
          label: Text(label, textAlign: TextAlign.center),
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Receta para ${widget.patientName}'),
      ),
      body: Column(
        children: <Widget>[
          // Mitad Superior: Botones de Acción
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3, offset: Offset(0, 2)),
              ],
              // border: Border(bottom: BorderSide(color: Colors.grey.shade300))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildActionButton(context, 'Añadir Medicina', Icons.add_circle_outline, () => _navigateAndAddMedicine(context)),
                _buildActionButton(context, 'Eliminar Medicina', Icons.remove_circle_outline, () => _navigateAndDeleteMedicine(context), color: Colors.orange[700]),
                _buildActionButton(context, 'Guardar Receta', Icons.save_alt_outlined, _savePrescription, color: Colors.green[700]),
              ],
            ),
          ),

          // Mitad Inferior: Previsualización de la Receta
          Expanded(
            child: _isSaving
                ? Center(child: CircularProgressIndicator(semanticsLabel: 'Guardando receta...'))
                : _buildPrescriptionPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionPreview() {
    final doctorName = _currentDoctor?.name ?? "Dr. Desconocido";
    final doctorId = _currentDoctor?.id ?? "N/A";
    // Idealmente tendrías más datos del paciente si pasas el objeto PatientForDoctorView
    final patientName = widget.patientName;
    final patientId = widget.patientId;

    return Container(
      color: Colors.grey[100], // Fondo ligeramente diferente para la previsualización
      padding: EdgeInsets.all(16.0),
      child: _addedMedicines.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Añada medicamentos a la receta.',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : SingleChildScrollView( // Para permitir scroll si la info es mucha
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Previsualización de Receta Médica', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewHeader('Paciente:', '$patientName (ID: $patientId)'),
                    _buildPreviewHeader('Doctor:', '$doctorName (ID: $doctorId)'),
                    _buildPreviewHeader('Fecha de Emisión:', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                    Divider(height: 30, thickness: 1),
                    Text('Medicamentos:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // No necesita scroll propio
                      itemCount: _addedMedicines.length,
                      itemBuilder: (context, index) {
                        final med = _addedMedicines[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. ${med.name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0, top: 4.0),
                                child: Text('Dosis: ${med.dosage}', style: TextStyle(fontSize: 14)),
                              ),
                              if (med.instructions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 18.0, top: 2.0),
                                  child: Text('Instrucciones: ${med.instructions}', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[700])),
                                ),
                              if (index < _addedMedicines.length - 1)
                                Divider(indent: 18, endIndent: 18, height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewHeader(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}