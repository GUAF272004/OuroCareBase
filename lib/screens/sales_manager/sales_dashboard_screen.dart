// lib/screens/sales_manager/sales_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'pending_prescriptions_view.dart'; // Importar
import 'sales_history_screen.dart';

class SalesManagerDashboardScreen extends StatelessWidget {
  final User user;
  SalesManagerDashboardScreen({required this.user});

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
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text('Bienvenido, ${user.name}!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColorDark)),
        ),
        _buildDashboardCard(
          context,
          icon: Icons.pending_actions_outlined,
          title: 'Recetas Pendientes',
          subtitle: 'Ver y procesar recetas por vender',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PendingPrescriptionsView()));
          },
        ),
        _buildDashboardCard(
          context,
          icon: Icons.history_edu_outlined,
          title: 'Historial de Ventas',
          subtitle: 'Consultar transacciones realizadas', // Actualizar subtítulo
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SalesHistoryScreen())); // <<<<<<<<<<<<<< CAMBIAR
          },
        ),
      ],
    );
  }
}