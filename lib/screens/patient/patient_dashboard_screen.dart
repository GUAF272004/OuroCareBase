// lib/screens/patient/patient_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'qr_scanner_screen.dart'; // Este es para escanear, quizás no lo necesite el paciente aquí
import 'prescription_list_view.dart';
import 'medication_calendar_view.dart';
import 'display_qr_code_screen.dart'; // <<<<<<<<<<<<<< IMPORTAR

class PatientDashboardScreen extends StatelessWidget {
  // ... (código existente de user y _buildDashboardCard) ...
  final User user;
  PatientDashboardScreen({required this.user});

  // Reutilizamos el widget de tarjeta
  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
              SizedBox(width: 20.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.0),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text('Bienvenido, ${user.name}!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColorDark)),
        ),
        _buildDashboardCard( // <<<<<<<<<<<<<< NUEVA TARJETA
          context,
          icon: Icons.qr_code_2_outlined, // Nuevo icono para mostrar QR
          title: 'Mi Código de Identificación',
          subtitle: 'Muestra tu QR para el registro',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DisplayQrCodeScreen()));
          },
        ),
        _buildDashboardCard(
          context,
          icon: Icons.medical_services_outlined,
          title: 'Mis Recetas',
          subtitle: 'Ver recetas pendientes y activas',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PrescriptionListScreen()));
          },
        ),
        _buildDashboardCard(
          context,
          icon: Icons.calendar_month_outlined,
          title: 'Horario de Medicamentos',
          subtitle: 'Consulte su calendario de medicación',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationCalendarScreen()));
          },
        ),
        // El paciente usualmente no escanea, sino que muestra.
        // Si necesitara escanear (ej. QR de un medicamento), esta tarjeta sería:
        // _buildDashboardCard(
        //   context,
        //   icon: Icons.qr_code_scanner_sharp,
        //   title: 'Escanear Código',
        //   subtitle: 'Escanear QR de medicamento o clínica',
        //   onTap: () {
        //     Navigator.push(context, MaterialPageRoute(builder: (_) => QrScannerScreen()));
        //   },
        // ),
      ],
    );
  }
}