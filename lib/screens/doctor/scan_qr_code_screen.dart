// lib/screens/doctor/scan_qr_code_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Asegúrate de que esta importación esté
import 'patient_overview_screen.dart';
import '../../models/user_model.dart'; // Para buscar en samplePatients

class ScanQrCodeScreen extends StatefulWidget {
  @override
  _ScanQrCodeScreenState createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends State<ScanQrCodeScreen> {
  MobileScannerController cameraController = MobileScannerController(
    // Puedes configurar aquí opciones iniciales si es necesario,
    // por ejemplo, la cámara por defecto (trasera).
    // facing: CameraFacing.back,
    // detectionSpeed: DetectionSpeed.normal,
  );
  bool _isProcessing = false;

  // Función para buscar paciente (simulada, usa tus datos reales o ApiService)
  PatientForDoctorView? _findPatientById(String patientId) {
    try {
      // En una app real, esto sería una llamada a tu ApiService o base de datos.
      return samplePatients.firstWhere((patient) => patient.id == patientId);
    } catch (e) {
      return null; // Paciente no encontrado
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear QR del Paciente'),
        // La sección 'actions' ha sido eliminada según tu solicitud.
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return; // Si ya está procesando, ignora
              setState(() {
                _isProcessing = true;
              });

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                final String scannedPatientId = barcodes.first.rawValue!;
                debugPrint('Código QR detectado: $scannedPatientId');

                PatientForDoctorView? patient = _findPatientById(scannedPatientId);

                if (patient != null) {
                  // No es estrictamente necesario detener la cámara antes de navegar
                  // si usas pushReplacement y el widget se desmonta,
                  // pero puede ser una buena práctica en algunos casos.
                  // cameraController.stop();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientOverviewScreen(patient: patient),
                    ),
                  ).then((_) {
                    // Se ejecuta cuando se vuelve de PatientOverviewScreen
                    if (mounted) { // Asegurar que el widget sigue montado
                      setState(() { _isProcessing = false; });
                      // Opcional: reiniciar cámara si es necesario y no lo hace automáticamente
                      // if (!cameraController.isStarting) {
                      //   cameraController.start();
                      // }
                    }
                  });
                } else {
                  // Solo muestra el SnackBar y resetea _isProcessing si el widget sigue montado
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Paciente no encontrado con ID: $scannedPatientId')),
                    );
                    // Pequeña pausa antes de permitir otro escaneo para evitar spam de SnackBar
                    Future.delayed(Duration(seconds: 2), () {
                      if (mounted) setState(() { _isProcessing = false; });
                    });
                  }
                }
              } else {
                // Si no se detecta un barcode válido, resetea _isProcessing después de un breve delay
                Future.delayed(Duration(milliseconds: 500), () {
                  if (mounted) setState(() { _isProcessing = false; });
                });
              }
            },
          ),
          // Overlay de escaneo (opcional, para guiar al usuario)
          Center(
            child: Container(
              width: 250, // Ancho del recuadro de guía
              height: 250, // Alto del recuadro de guía
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.7), // Color del borde
                  width: 3, // Grosor del borde
                ),
                borderRadius: BorderRadius.circular(12), // Bordes redondeados
              ),
            ),
          ),
          if (_isProcessing) // Mostrar un indicador de carga si se está procesando un QR
            Container(
              color: Colors.black.withOpacity(0.3), // Fondo semitransparente
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}