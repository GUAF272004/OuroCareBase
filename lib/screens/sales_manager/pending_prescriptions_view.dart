import 'package:flutter/material.dart';
import '../../models/prescription_model.dart';
// import '../../services/api_service.dart'; // Para cargar y actualizar

class PendingPrescriptionsView extends StatefulWidget {
  @override
  _PendingPrescriptionsViewState createState() => _PendingPrescriptionsViewState();
}

class _PendingPrescriptionsViewState extends State<PendingPrescriptionsView> {
  late Future<List<Prescription>> _pendingPrescriptionsFuture;

  @override
  void initState() {
    super.initState();
    _pendingPrescriptionsFuture = _fetchPendingPrescriptions();
  }

  Future<List<Prescription>> _fetchPendingPrescriptions() async {
    // TODO: Reemplazar con llamada real al ApiService para obtener recetas con estado 'PENDIENTE'
    // final apiService = Provider.of<ApiService>(context, listen: false);
    // return await apiService.getPrescriptionsByStatus('PENDIENTE');
    await Future.delayed(Duration(milliseconds: 400));
    return samplePrescriptions.where((p) => p.status.toUpperCase() == 'PENDIENTE').toList();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _markAsSold(BuildContext context, Prescription prescription) async {
    // Muestra un dialogo de confirmación
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar Venta'),
          content: Text('¿Está seguro de que desea marcar la receta de "${prescription.medication}" para ${prescription.patientName} como VENDIDA?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Devuelve false
              },
            ),
            ElevatedButton(
              child: Text('Confirmar Venta'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Devuelve true
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // TODO: Llamar al ApiService para actualizar el estado en el backend/blockchain
      // final apiService = Provider.of<ApiService>(context, listen: false);
      // bool success = await apiService.updatePrescriptionStatus(prescription.id, 'VENDIDO');
      print('Simulando: Marcando receta ${prescription.id} como VENDIDA.');
      await Future.delayed(Duration(seconds: 1));
      bool success = true; // Simular éxito

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receta ${prescription.id} marcada como VENDIDA.'), backgroundColor: Colors.green),
        );
        // Recargar la lista para reflejar el cambio
        setState(() {
          _pendingPrescriptionsFuture = _fetchPendingPrescriptions();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el estado de la receta.'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recetas Pendientes de Venta'),
      ),
      body: FutureBuilder<List<Prescription>>(
        future: _pendingPrescriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar recetas: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay recetas pendientes de venta.'));
          }

          final prescriptions = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Card(
                elevation: 3.0,
                child: ListTile(
                  leading: Icon(Icons.medication_outlined, color: Colors.blueAccent, size: 36),
                  title: Text(prescription.medication, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Paciente: ${prescription.patientName}\nDoctor: ${prescription.doctorName}\nFecha: ${_formatDate(prescription.issueDate)}'),
                  trailing: ElevatedButton(
                    child: Text('Vender'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _markAsSold(context, prescription),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}