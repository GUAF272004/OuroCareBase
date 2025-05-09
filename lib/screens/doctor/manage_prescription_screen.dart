// lib/screens/doctor/manage_prescription_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/medicine_item_model.dart'; // Asegúrate que la ruta sea correcta
import '../../services/auth_service.dart';
import '../../services/api_service.dart'; // Para guardar la receta final

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
  _ManagePrescriptionScreenState createState() =>
      _ManagePrescriptionScreenState();
}

class _ManagePrescriptionScreenState extends State<ManagePrescriptionScreen> {
  List<MedicineItem> _addedMedicines = [];
  bool _isSaving = false;

  User? _currentDoctor;
  // ApiService? _apiService; // Descomentar si se usa

  @override
  void initState() {
    super.initState();
    _currentDoctor = Provider.of<AuthService>(context, listen: false).currentUser;
    // _apiService = Provider.of<ApiService>(context, listen: false); // Descomentar si se usa
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
      MaterialPageRoute(
          builder: (context) =>
              DeleteMedicineScreen(currentMedicines: _addedMedicines)),
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
        SnackBar(
            content: Text('Añada al menos un medicamento antes de guardar.'),
            backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    if (_currentDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No se pudo identificar al doctor. Intente de nuevo.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Datos de la receta completa
    final prescriptionData = {
      'patientId': widget.patientId,
      'patientName': widget.patientName, // El backend podría buscarlo con patientId
      'doctorId': _currentDoctor!.id,
      'doctorName': _currentDoctor!.name, // El backend podría buscarlo con doctorId
      'issueDate': DateTime.now().toIso8601String(),
      // Usar toJson() de cada MedicineItem si la API espera esa estructura
      'medicines': _addedMedicines.map((med) => med.toJson()).toList(), // <<--- CAMBIO AQUÍ
      'status': 'PENDIENTE', // Estado inicial de la receta
    };

    // TODO: Llamar al ApiService para guardar `prescriptionData` en el backend
    // Descomentar y usar cuando ApiService y su método estén listos
    final apiService = Provider.of<ApiService>(context, listen: false);
    bool success = false;
    try {
      // Asumiendo que tienes un método en ApiService como `createPrescription`
      // que toma un Map<String, dynamic> similar a `prescriptionData`.
      // success = await apiService.createFullPrescription(prescriptionData);
      print('Guardando Receta (simulación):');
      print(prescriptionData);
      await Future.delayed(Duration(seconds: 1));
      success = true; // Simular éxito

    } catch (e) {
      print("Error al guardar receta: $e");
      success = false;
    }


    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Receta guardada exitosamente para ${widget.patientName}.'),
              backgroundColor: Colors.green),
        );
        setState(() {
          _addedMedicines.clear();
        });
        Navigator.of(context).pop(true); // Devuelve true para indicar éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar la receta.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed, {Color? color}) {
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
        title: Text('Receta para ${widget.patientName}'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Usar color de tarjeta del tema
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildActionButton(context, 'Añadir', Icons.add_box_outlined, // Icono más adecuado
                        () => _navigateAndAddMedicine(context)),
                _buildActionButton(context, 'Eliminar', Icons.indeterminate_check_box_outlined, // Icono más adecuado
                        () => _navigateAndDeleteMedicine(context),
                    color: Colors.orange[700]),
                _buildActionButton(context, 'Guardar', Icons.save_alt_outlined,
                    _savePrescription,
                    color: Colors.green[700]),
              ],
            ),
          ),
          Expanded(
            child: _isSaving
                ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Guardando receta...')
                  ],
                ))
                : _buildPrescriptionPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionPreview() {
    final doctorName = _currentDoctor?.name ?? "Dr. Desconocido";
    final doctorSpecialty = _currentDoctor?.specialty ?? "Especialidad Desconocida"; // Asumiendo que User tiene specialty
    final patientName = widget.patientName;

    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');


    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Previsualización de Receta Médica',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorDark)),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreviewHeader('Paciente:', patientName),
                    _buildPreviewHeader('Atendido por:', doctorName),
                    _buildPreviewHeader('Especialidad:', doctorSpecialty),
                    _buildPreviewHeader('Fecha y Hora:', dateFormat.format(DateTime.now())),
                    Divider(height: 30, thickness: 1),
                    Text('Rp/', // Indicador de receta
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ListView.separated( // Usar separated para dividers más consistentes
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _addedMedicines.length,
                      itemBuilder: (context, index) {
                        final med = _addedMedicines[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. ${med.name}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0, top: 4.0),
                                // Usar fullDosageDescription para mostrar los detalles
                                child: Text(
                                  med.fullDosageDescription, // <<--- CAMBIO AQUÍ
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(indent: 18, endIndent: 18, height: 16, thickness: 0.5),
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
      padding: const EdgeInsets.symmetric(vertical: 3.0), // Reducir padding vertical
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)), // Estilo de label
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: Colors.black87))),
        ],
      ),
    );
  }
}