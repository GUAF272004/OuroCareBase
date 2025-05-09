import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Importar paquete QR
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class DisplayQrCodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = Provider.of<AuthService>(context).currentUser;

    if (currentUser == null) {
      // Esto no debería pasar si el usuario está logueado para llegar aquí
      return Scaffold(
        appBar: AppBar(title: Text('Mi Código QR')),
        body: Center(child: Text('Error: Usuario no encontrado.')),
      );
    }

    // El dato a codificar en el QR. Usualmente un ID único del paciente.
    final String qrData = currentUser.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Código QR'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${currentUser.name}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Presenta este código al personal médico para identificarte.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView( // Widget del paquete qr_flutter
                  data: qrData,
                  version: QrVersions.auto,
                  size: 250.0,
                  gapless: false, // Para que no haya espacios en blanco en el QR
                  embeddedImage: AssetImage('assets/icon/app_icon_placeholder.png'), // Opcional: tu logo en el centro
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(50, 50), // Tamaño del logo
                  ),
                  errorStateBuilder: (cxt, err) {
                    return Container(
                      child: Center(
                        child: Text(
                          'Uh oh! Algo salió mal...',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                'ID: $qrData', // Mostrar el ID para referencia
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 30),
              Icon(Icons.medical_information_outlined, size: 40, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}