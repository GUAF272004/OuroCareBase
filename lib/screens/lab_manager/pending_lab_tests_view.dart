import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/lab_order_model.dart';
import '../../services/api_service.dart';
import 'lab_order_detail_screen.dart'; // Nueva pantalla para ingresar resultados

class PendingLabTestsView extends StatefulWidget {
  @override
  _PendingLabTestsViewState createState() => _PendingLabTestsViewState();
}

class _PendingLabTestsViewState extends State<PendingLabTestsView> {
  late Future<List<LabOrderModel>> _pendingOrdersFuture;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    _loadPendingOrders();
  }

  void _loadPendingOrders() {
    setState(() {
      _pendingOrdersFuture = _apiService.getPendingLabOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pruebas de Laboratorio Pendientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPendingOrders,
          )
        ],
      ),
      body: FutureBuilder<List<LabOrderModel>>(
        future: _pendingOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar pruebas: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science_outlined, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 20),
                  Text(
                    'No hay pruebas pendientes.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                elevation: 2.0,
                child: ListTile(
                  leading: Icon(Icons.biotech_outlined, color: Theme.of(context).primaryColor),
                  title: Text(order.testName, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Paciente: ${order.patientName}\nDoctor: ${order.doctorName}\nFecha Orden: ${DateFormat.yMd().format(order.orderDate)}\nEstado: ${order.status}'),
                  trailing: ElevatedButton(
                    child: Text('Resultados'),
                    onPressed: () async {
                      final resultSubmitted = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => LabOrderDetailScreen(labOrder: order)),
                      );
                      // Si se subieron resultados, recargar la lista
                      if (resultSubmitted == true) {
                        _loadPendingOrders();
                      }
                    },
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