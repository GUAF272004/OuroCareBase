import 'package:flutter/material.dart';

class PastConsultationsScreen extends StatelessWidget {
  final String patientId;
  PastConsultationsScreen({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Consultas Anteriores')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Lista de Consultas Anteriores para el paciente ID: $patientId (PENDIENTE).\nCada consulta podría ser expandible para ver detalles, notas y recetas emitidas durante esa consulta.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}