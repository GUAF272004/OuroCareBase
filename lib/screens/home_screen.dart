import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

// Importar los dashboards de cada rol
import 'patient/patient_dashboard_screen.dart';
import 'doctor/doctor_dashboard_screen.dart';
import 'sales_manager/sales_dashboard_screen.dart';
import 'lab_manager/lab_dashboard_screen.dart';
// import 'login_screen.dart'; // No es necesario para logout aquí si main.dart lo maneja

class HomeScreen extends StatelessWidget {
  // static const routeName = '/home'; // Ya no se necesita si no se navega por nombre aquí
  final User user;

  HomeScreen({required this.user});

  Widget _buildBodyForRole(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return PatientDashboardScreen(user: user);
      case UserRole.doctor:
        return DoctorDashboardScreen(user: user);
      case UserRole.salesManager:
        return SalesManagerDashboardScreen(user: user);
      case UserRole.labManager:
        return LabManagerDashboardScreen(user: user);
      default:
        return Center(child: Text('Rol de usuario no configurado para mostrar dashboard.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.getRoleName()} Portal'),
        actions: [
          Tooltip(
            message: 'Cerrar Sesión',
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await authService.logout();
                // El Consumer en main.dart se encargará de navegar a LoginScreen
              },
            ),
          ),
        ],
      ),
      // drawer: AppDrawer(userRole: user.role), // Podrías tener un Drawer común o específico
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Un padding general para el cuerpo
        child: _buildBodyForRole(user.role),
      ),
    );
  }
}