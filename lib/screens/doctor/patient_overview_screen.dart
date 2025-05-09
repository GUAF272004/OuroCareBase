import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // Para PatientForDoctorView
import 'manage_prescription_screen.dart';
// Importa las nuevas pantallas placeholder
import 'medical_history_screen.dart';
import 'past_consultations_screen.dart';
import 'lab_tests_screen.dart';

class PatientOverviewScreen extends StatelessWidget {
  final PatientForDoctorView patient;

  PatientOverviewScreen({required this.patient});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          SizedBox(width: 12),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label, style: TextStyle(fontSize: 15)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColorLight,
        foregroundColor: Theme.of(context).primaryColorDark,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen del Paciente'),
        backgroundColor: Theme.of(context).primaryColorDark, // Un color distintivo
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Sección de Información del Paciente
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: patient.photoUrl != null ? NetworkImage(patient.photoUrl!) : null,
                          child: patient.photoUrl == null
                              ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                              : null,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text('ID: ${patient.id}', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildInfoRow(context, Icons.cake_outlined, 'Nacimiento', _formatDate(patient.dateOfBirth)),
                    _buildInfoRow(context, Icons.email_outlined, 'Email', patient.email),
                    _buildInfoRow(context, Icons.phone_outlined, 'Teléfono', patient.phoneNumber ?? 'N/A'),
                    _buildInfoRow(context, Icons.calendar_today_outlined, 'Última Visita', _formatDate(patient.lastVisit)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Sección de Acciones
            Text('Acciones Rápidas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true, // Importante para GridView dentro de SingleChildScrollView
              physics: NeverScrollableScrollPhysics(), // También importante
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5, // Ajusta para el tamaño de los botones
              children: <Widget>[
                _buildActionButton(context, Icons.history_edu_outlined, 'Historial Médico', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MedicalHistoryScreen(patientId: patient.id)));
                }),
                _buildActionButton(context, Icons.folder_shared_outlined, 'Consultas Previas', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PastConsultationsScreen(patientId: patient.id)));
                }),
                _buildActionButton(context, Icons.science_outlined, 'Pruebas Lab.', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LabTestsScreen(patientId: patient.id)));
                }),
                _buildActionButton(context, Icons.edit_note_outlined, 'Crear Receta', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManagePrescriptionScreen(
                        patientId: patient.id,
                        patientName: patient.name,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}