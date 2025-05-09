import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // Para PatientForDoctorView
import 'manage_prescription_screen.dart'; // Para navegar a crear receta

class PatientDetailView extends StatelessWidget {
  final PatientForDoctorView patient;

  PatientDetailView({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Usamos ListView para posible contenido extenso
          children: [
            ListTile(
              leading: Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
              title: Text('Nombre Completo'),
              subtitle: Text(patient.name, style: Theme.of(context).textTheme.titleLarge),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.badge_outlined, color: Theme.of(context).primaryColor),
              title: Text('ID de Paciente'),
              subtitle: Text(patient.id, style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: Icon(Icons.email_outlined, color: Theme.of(context).primaryColor),
              title: Text('Email'),
              subtitle: Text(patient.email, style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: Theme.of(context).primaryColor),
              title: Text('Última Visita'),
              subtitle: Text("${patient.lastVisit.day}/${patient.lastVisit.month}/${patient.lastVisit.year}", style: Theme.of(context).textTheme.titleMedium),
            ),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Historial Médico Completo (PENDIENTE)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Text(
                'Aquí se mostraría el historial médico completo del paciente, cargado desde la blockchain (a través del backend).\n- Consultas Anteriores\n- Resultados de Laboratorio\n- Recetas Previas',
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ManagePrescriptionScreen(patientId: patient.id, patientName: patient.name)),
          );
        },
        label: Text('Emitir Receta'),
        icon: Icon(Icons.edit_note_outlined),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}