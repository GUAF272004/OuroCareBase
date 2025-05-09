import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:provider/provider.dart'; // Para ApiService y AuthService
import '../../models/prescription_model.dart';
import '../../services/api_service.dart'; // Para cargar y actualizar
import '../../services/auth_service.dart'; // Para obtener el ID del vendedor

class PendingPrescriptionsView extends StatefulWidget {
  @override
  _PendingPrescriptionsViewState createState() =>
      _PendingPrescriptionsViewState();
}

class _PendingPrescriptionsViewState extends State<PendingPrescriptionsView> {
  late Future<List<Prescription>> _pendingPrescriptionsFuture;
  late ApiService _apiService;
  String? _salesPersonId; // Para identificar quién realiza la venta

  @override
  void initState() {
    super.initState();
    // Es importante obtener el ApiService y AuthService aquí si se usan en initState o build
    // pero para _fetchPendingPrescriptions y _markAsSold que pueden ser llamados después,
    // es mejor obtenerlos dentro de esas funciones o pasarlos como parámetros si es necesario,
    // o asegurarse que el context esté disponible.
    // Por simplicidad, lo obtendremos en initState para _salesPersonId y _apiService.
    _apiService = Provider.of<ApiService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    _salesPersonId = authService.currentUser?.id;

    _loadPrescriptions();
  }

  void _loadPrescriptions() {
    setState(() {
      // Descomentar cuando ApiService esté listo
      // _pendingPrescriptionsFuture = _apiService.getPendingPrescriptionsForSales();
      _pendingPrescriptionsFuture = _fetchPendingPrescriptionsMock(); // Usar mock mientras tanto
    });
  }


  // Función Mock mientras se implementa ApiService
  Future<List<Prescription>> _fetchPendingPrescriptionsMock() async {
    await Future.delayed(Duration(milliseconds: 400));
    // Asegúrate que samplePrescriptions en prescription_model.dart esté actualizada
    return samplePrescriptions
        .where((p) => p.status.toUpperCase() == 'PENDIENTE')
        .toList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date); // Usando intl para formatear
  }

  Future<void> _markAsSold(BuildContext context, Prescription prescription) async {
    if (_salesPersonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: No se pudo identificar al vendedor.'), backgroundColor: Colors.red),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmar Venta'),
          content: Text(
              '¿Está seguro de que desea marcar la receta de "${prescription.medicationsSummary}" para ${prescription.patientName} como VENDIDA?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Confirmar Venta'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // TODO: Reemplazar con llamada real al ApiService
        // final success = await _apiService.markPrescriptionAsSold(prescription.id, _salesPersonId!);

        // Simulación de éxito/fallo con el mock
        print('Simulando: Marcando receta ${prescription.id} como VENDIDA por $_salesPersonId.');
        await Future.delayed(Duration(seconds: 1));
        bool success = true; // Simular éxito
        // bool success = false; // Para probar el fallo


        if (success) {
          // Actualizar localmente el estado si es un mock, o confiar en la recarga de la API
          final itemInSample = samplePrescriptions.firstWhere((p) => p.id == prescription.id, orElse: () => prescription);
          if (itemInSample != prescription || samplePrescriptions.contains(itemInSample)) { // Asegura que existe y es modificable si es de la lista global
            itemInSample.status = 'VENDIDO';
            itemInSample.saleTimestamp = DateTime.now();
            itemInSample.soldByUserId = _salesPersonId;
          }


          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Receta ${prescription.id} marcada como VENDIDA.'),
                  backgroundColor: Colors.green),
            );
            // Recargar la lista para reflejar el cambio
            _loadPrescriptions();
          }
        } else {
          // Esto no se alcanzará con el mock actual si success es true
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error al actualizar el estado de la receta.'),
                  backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        print('Error en _markAsSold: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al procesar la venta: ${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recetas Pendientes de Venta'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPrescriptions,
          )
        ],
      ),
      body: FutureBuilder<List<Prescription>>(
        future: _pendingPrescriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar recetas: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay recetas pendientes de venta.'));
          }

          final prescriptions = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              // Construir un resumen de los items de la receta
              String itemsSummary = prescription.items.map((item) {
                return '${item.medicationName} (${item.dosage}) - ${item.instructions}';
              }).join('\n');

              return Card(
                elevation: 3.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                child: ListTile(
                  leading: Icon(Icons.medication_liquid_outlined, // Icono alternativo
                      color: Theme.of(context).colorScheme.secondary, size: 40),
                  title: Text(prescription.medicationsSummary, // Usar el getter del modelo
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Paciente: ${prescription.patientName}\nDoctor: ${prescription.doctorName}\nFecha: ${_formatDate(prescription.issueDate)}\n\nDetalle:\n$itemsSummary'),
                  isThreeLine: prescription.items.length > 1, // Ajustar si el subtítulo es largo
                  trailing: ElevatedButton.icon(
                    icon: Icon(Icons.point_of_sale_outlined),
                    label: Text('Vender'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: TextStyle(fontSize: 14)
                    ),
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