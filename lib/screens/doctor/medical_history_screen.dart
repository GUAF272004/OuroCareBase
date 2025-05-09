import 'package:flutter/material.dart';

class MedicalHistoryScreen extends StatelessWidget {
  final String patientId;
  MedicalHistoryScreen({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial Médico Completo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Historial Médico para el paciente ID: $patientId (PENDIENTE).\nAquí se mostraría una vista detallada y cronológica de todos los eventos médicos relevantes obtenidos de la blockchain.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}