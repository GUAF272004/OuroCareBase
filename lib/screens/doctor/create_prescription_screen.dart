import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart'; // Para User y UserRole
import '../../services/auth_service.dart'; // Para obtener datos del doctor
// import '../../services/api_service.dart'; // Para enviar la receta

class CreatePrescriptionScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  CreatePrescriptionScreen({required this.patientId, required this.patientName});

  @override
  _CreatePrescriptionScreenState createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _medication = '';
  String _dosage = '';
  String _instructions = '';
  bool _isLoading = false;

  Future<void> _submitPrescription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final doctor = Provider.of<AuthService>(context, listen: false).currentUser;
    if (doctor == null || doctor.role != UserRole.doctor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No se pudo identificar al doctor.'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
      return;
    }

    // TODO: Enviar datos al ApiService para registrar en backend/blockchain
    // final apiService = Provider.of<ApiService>(context, listen: false);
    // bool success = await apiService.issuePrescription({
    //   'patientId': widget.patientId,
    //   'doctorId': doctor.id,
    //   'doctorName': doctor.name, // El backend podría obtener esto del token
    //   'medication': _medication,
    //   'dosage': _dosage,
    //   'instructions': _instructions, // Podrías añadir más campos como 'duration'
    //   'status': 'PENDIENTE',
    // });

    // Simulación
    print('Receta emitida (simulación):');
    print('Paciente ID: ${widget.patientId}');
    print('Doctor ID: ${doctor.id}');
    print('Medicamento: $_medication');
    print('Dosis: $_dosage');
    print('Instrucciones: $_instructions');
    await Future.delayed(Duration(seconds: 1));
    bool success = true; // Simular éxito
    // Fin simulación

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receta emitida exitosamente para ${widget.patientName}.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // Volver a la pantalla anterior (detalle del paciente o lookup)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al emitir la receta.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emitir Receta para ${widget.patientName}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Paciente: ${widget.patientName} (ID: ${widget.patientId})', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Medicamento', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese el medicamento' : null,
                onSaved: (value) => _medication = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Dosis', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese la dosis' : null,
                onSaved: (value) => _dosage = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Instrucciones Adicionales', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (value) => _instructions = value ?? '',
              ),
              // Podrías añadir campo para duración, cantidad, etc.
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: Icon(Icons.send_outlined),
                onPressed: _submitPrescription,
                label: Text('Emitir Receta'),
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