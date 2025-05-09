import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/prescription_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
// Asumiendo que tienes ApiService y lo usarías en un futuro
// import '../../services/api_service.dart';

class PrescriptionListScreen extends StatefulWidget {
  @override
  _PrescriptionListScreenState createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  late Future<List<Prescription>> _prescriptionsFuture;

  @override
  void initState() {
    super.initState();
    // Obtener el ID del usuario actual para filtrar las recetas
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    _prescriptionsFuture = _fetchPrescriptions(currentUser?.id);
  }

  Future<List<Prescription>> _fetchPrescriptions(String? patientId) async {
    // TODO: Reemplazar con llamada real al ApiService
    // final apiService = Provider.of<ApiService>(context, listen: false);
    // return await apiService.getPatientPrescriptions(patientId);

    // Simulación con datos de muestra
    await Future.delayed(Duration(milliseconds: 500));
    if (patientId == null) return [];
    return samplePrescriptions.where((p) => p.patientId == patientId).toList();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDIENTE':
        return Colors.orangeAccent;
      case 'VENDIDO':
        return Colors.green;
      case 'CANCELADO':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Recetas'),
      ),
      body: FutureBuilder<List<Prescription>>(
        future: _prescriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar recetas: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tienes recetas registradas.'));
          }

          final prescriptions = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.receipt_long_outlined, color: Theme.of(context).primaryColor, size: 40),
                  title: Text(prescription.medication, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Doctor: ${prescription.doctorName}'),
                      Text('Fecha: ${_formatDate(prescription.issueDate)}'),
                      Text('Dosis: ${prescription.dosage}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(prescription.status, style: TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: _getStatusColor(prescription.status),
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  ),
                  onTap: () {
                    // TODO: Implementar vista de detalle de receta si es necesario
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Detalle de receta ${prescription.id} (PENDIENTE)')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}