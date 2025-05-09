import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:provider/provider.dart';
import '../../models/prescription_model.dart';
// import '../../models/user_model.dart'; // No parece usarse directamente aquí
import '../../services/auth_service.dart';
import '../../services/api_service.dart'; // Asumiendo que tienes ApiService

class PrescriptionListScreen extends StatefulWidget {
  @override
  _PrescriptionListScreenState createState() => _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  late Future<List<Prescription>> _prescriptionsFuture;
  late ApiService _apiService;
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    _patientId = currentUser?.id;

    _loadPrescriptions();
  }

  void _loadPrescriptions(){
    if (_patientId != null) {
      setState(() {
        // Descomentar y usar cuando ApiService esté listo
        // _prescriptionsFuture = _apiService.getPatientPrescriptions(_patientId!);
        _prescriptionsFuture = _fetchPrescriptionsMock(_patientId!); // Usar mock mientras tanto
      });
    } else {
      // Manejar caso donde patientId es null
      _prescriptionsFuture = Future.value([]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: No se pudo identificar al paciente.')),
          );
        }
      });
    }
  }

  // Función Mock mientras se implementa ApiService
  Future<List<Prescription>> _fetchPrescriptionsMock(String patientId) async {
    await Future.delayed(Duration(milliseconds: 500));
    // Asegúrate que samplePrescriptions en prescription_model.dart esté actualizada
    return samplePrescriptions.where((p) => p.patientId == patientId).toList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date); // Usando intl para formatear
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPrescriptions,
          )
        ],
      ),
      body: FutureBuilder<List<Prescription>>(
        future: _prescriptionsFuture,
        builder: (context, snapshot) {
          if (_patientId == null) {
            return Center(child: Text('ID de paciente no disponible.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar recetas: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tienes recetas registradas.'));
          }

          final prescriptions = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              String subtitleDetails = 'Doctor: ${prescription.doctorName}\nFecha: ${_formatDate(prescription.issueDate)}';
              if (prescription.items.isNotEmpty) {
                final firstItem = prescription.items.first;
                subtitleDetails += '\n${firstItem.medicationName}: ${firstItem.dosage} - ${firstItem.instructions}';
                if (prescription.items.length > 1) {
                  subtitleDetails += '\n(... y ${prescription.items.length -1} más)';
                }
              } else {
                subtitleDetails += '\n(Sin medicamentos detallados)';
              }


              return Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.receipt_long_outlined,
                      color: Theme.of(context).primaryColor, size: 40),
                  title: Text(prescription.medicationsSummary, // Usar el getter del modelo
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Doctor: ${prescription.doctorName}'),
                      Text('Fecha: ${_formatDate(prescription.issueDate)}'),
                      if (prescription.items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: prescription.items.map((item) => Text(
                              '  • ${item.medicationName} (${item.dosage})',
                              style: TextStyle(fontSize: 13),
                            )).toList(),
                          ),
                        ),
                      if (prescription.items.isEmpty)
                        Text('(Sin medicamentos detallados)', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(prescription.status,
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: _getStatusColor(prescription.status),
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  ),
                  onTap: () {
                    // TODO: Implementar vista de detalle de receta si es necesario
                    // Por ejemplo, navegar a una pantalla que muestre todos los PrescriptionItems
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text("Detalle de Receta ID: ${prescription.id}"),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text("Paciente: ${prescription.patientName}"),
                                Text("Doctor: ${prescription.doctorName}"),
                                Text("Fecha: ${_formatDate(prescription.issueDate)}"),
                                Text("Estado: ${prescription.status}"),
                                SizedBox(height: 10),
                                Text("Medicamentos:", style: TextStyle(fontWeight: FontWeight.bold)),
                                if (prescription.items.isNotEmpty)
                                  ...prescription.items.map((item) => Text(
                                      "  • ${item.medicationName}\n     Dosis: ${item.dosage}\n     Instrucciones: ${item.instructions}"
                                  )).toList(),
                                if (prescription.items.isEmpty)
                                  Text(" (No hay medicamentos detallados)"),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cerrar'),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                            )
                          ],
                        ));
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