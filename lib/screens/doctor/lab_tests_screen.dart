import 'package:flutter/material.dart';

class LabTestsScreen extends StatelessWidget {
  final String patientId;
  LabTestsScreen({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pruebas de Laboratorio')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Resultados de Pruebas de Laboratorio para el paciente ID: $patientId (PENDIENTE).\nSe listarían las pruebas con sus resultados, fechas y PDFs adjuntos si los hubiera.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}