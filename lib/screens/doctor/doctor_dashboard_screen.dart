// lib/screens/doctor/doctor_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // Para el tipo User
import 'patient_lookup_screen.dart';   // Para la búsqueda manual de pacientes
import 'scan_qr_code_screen.dart';     // Para escanear el QR del paciente
import 'notifications_screen.dart'; // <<<<<<<<<<<<<< IMPORTAR


class DoctorDashboardScreen extends StatelessWidget {
  final User user; // El usuario doctor logueado

  DoctorDashboardScreen({required this.user});

  // Widget reutilizable para crear las tarjetas del dashboard
  Widget _buildDashboardCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3.0, // Una ligera elevación para destacar las tarjetas
      margin: EdgeInsets.symmetric(vertical: 8.0), // Espacio vertical entre tarjetas
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0), // Bordes redondeados consistentes con CardTheme
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
              SizedBox(width: 20.0), // Espacio entre el icono y el texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.0), // Pequeño espacio entre título y subtítulo
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18), // Icono indicador de acción
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView( // Usamos ListView para permitir scroll si hay muchas opciones
      padding: EdgeInsets.all(16.0), // Padding general para el contenido del dashboard
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0), // Espacio después del saludo
          child: Text(
            'Bienvenido, Dr. ${user.name}!', // Saludo personalizado
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).primaryColorDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Nueva Tarjeta: Escanear QR del Paciente
        _buildDashboardCard(
          context,
          icon: Icons.qr_code_scanner_outlined,
          title: 'Escanear QR de Paciente',
          subtitle: 'Acceder rápidamente al perfil del paciente',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ScanQrCodeScreen()),
            );
          },
        ),

        // Tarjeta Existente: Buscar Pacientes Manualmente
        _buildDashboardCard(
          context,
          icon: Icons.search_outlined,
          title: 'Buscar Pacientes Manualmente',
          subtitle: 'Acceder al historial y gestionar pacientes',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PatientLookupScreen()),
            );
          },
        ),

        // Tarjeta Existente: Emitir Receta Rápida (conceptual)
        _buildDashboardCard(
          context,
          icon: Icons.edit_note_outlined,
          title: 'Emitir Receta Rápida',
          subtitle: 'Crear una receta (seleccionar paciente después)',
          onTap: () {
            // Esta funcionalidad podría llevar a PatientLookupScreen o a una pantalla
            // intermedia para seleccionar/buscar paciente antes de ir a CreatePrescriptionScreen.
            // Por ahora, un placeholder o una navegación directa a buscar paciente.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PatientLookupScreen(autoFocusSearch: true)),
              // Podrías pasar un parámetro a PatientLookupScreen para indicar que
              // el objetivo es seleccionar un paciente para una nueva receta.
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Seleccione un paciente para emitir una receta.')),
            );
          },
        ),

        // Tarjeta Existente: Alertas y Notificaciones (conceptual)
        _buildDashboardCard(
          context,
          icon: Icons.notifications_active_outlined,
          title: 'Alertas y Notificaciones',
          subtitle: 'Resultados de lab. listos, etc.', // Actualizar subtítulo
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen())); // <<<<<<<<<<<<<< CAMBIAR
          },
        ),

        // Puedes añadir más tarjetas aquí para otras funcionalidades del doctor
        // Ejemplo:
        // _buildDashboardCard(
        //   context,
        //   icon: Icons.calendar_month_outlined,
        //   title: 'Mi Agenda',
        //   subtitle: 'Ver citas programadas (PENDIENTE)',
        //   onTap: () {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content: Text('FUNCIONALIDAD PENDIENTE: Mi Agenda')),
        //     );
        //   },
        // ),
      ],
    );
  }
}