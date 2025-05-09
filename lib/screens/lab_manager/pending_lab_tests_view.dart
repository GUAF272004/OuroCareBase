import 'package:flutter/material.dart';
// import '../../models/prescription_model.dart'; // O un modelo 'LabOrderModel'
// import '../../services/api_service.dart';

class PendingLabTestsView extends StatefulWidget {
  @override
  _PendingLabTestsViewState createState() => _PendingLabTestsViewState();
}

class _PendingLabTestsViewState extends State<PendingLabTestsView> {
  // late Future<List<LabOrderModel>> _pendingTestsFuture; // Asumiendo LabOrderModel

  @override
  void initState() {
    super.initState();
    // _pendingTestsFuture = _fetchPendingTests();
  }

  // Future<List<LabOrderModel>> _fetchPendingTests() async {
  //   // TODO: Llamar al ApiService
  //   await Future.delayed(Duration(milliseconds: 300));
  //   return []; // Simulación
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pruebas de Laboratorio Pendientes'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.science_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 20),
              Text(
                'Vista de Pruebas Pendientes (PENDIENTE)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Aquí se listarían las órdenes de laboratorio o recetas que requieren resultados. Cada una permitiría navegar a una pantalla para ingresar dichos resultados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
      // body: FutureBuilder<List<LabOrderModel>>(
      //   future: _pendingTestsFuture,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     } else if (snapshot.hasError) {
      //       return Center(child: Text('Error: ${snapshot.error}'));
      //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //       return Center(child: Text('No hay pruebas pendientes.'));
      //     }
      //     final tests = snapshot.data!;
      //     return ListView.builder(
      //       itemCount: tests.length,
      //       itemBuilder: (context, index) {
      //         final testOrder = tests[index];
      //         return Card(
      //           child: ListTile(
      //             title: Text(testOrder.testName), // Asumiendo campos en LabOrderModel
      //             subtitle: Text('Paciente: ${testOrder.patientName}\nDoctor: ${testOrder.doctorName}'),
      //             trailing: ElevatedButton(
      //               child: Text('Ingresar Resultados'),
      //               onPressed: () {
      //                 // Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateLabResultsScreen(order: testOrder)));
      //               },
      //             ),
      //           ),
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }
}