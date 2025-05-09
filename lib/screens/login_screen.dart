// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart'; // Importar UserRole

// Importar las nuevas pantallas de registro
import 'registration/doctor_registration_screen.dart';
import 'registration/sales_manager_registration_screen.dart';
import 'registration/lab_manager_registration_screen.dart';
import 'registration/patient_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    // ... (tu código de _submit existente sin cambios)
    setState(() {
      _errorMessage = null; // Limpiar errores previos
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = await authService.login(_email, _password);

      if (!success && mounted) {
        setState(() {
          _errorMessage = 'Credenciales incorrectas o error de conexión.';
        });
      }
      // La navegación al HomeScreen es manejada por el Consumer en main.dart
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Ocurrió un error inesperado: ${error.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegistrationScreen(UserRole role) {
    Widget screen;
    switch (role) {
      case UserRole.doctor:
        screen = DoctorRegistrationScreen();
        break;
      case UserRole.salesManager:
        screen = SalesManagerRegistrationScreen();
        break;
      case UserRole.labManager:
        screen = LabManagerRegistrationScreen();
        break;
      case UserRole.patient:
        screen = PatientRegistrationScreen();
        break;
      default:
        return; // No hacer nada si el rol es desconocido o no manejado
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registrarse como'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // Consistente con el tema
          content: Column(
            mainAxisSize: MainAxisSize.min, // Para que el diálogo no sea demasiado grande
            children: <Widget>[
              _buildRoleOption(context, 'Doctor', UserRole.doctor),
              _buildRoleOption(context, 'Encargado de Ventas', UserRole.salesManager),
              _buildRoleOption(context, 'Encargado de Laboratorio', UserRole.labManager),
              _buildRoleOption(context, 'Paciente', UserRole.patient),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleOption(BuildContext context, String title, UserRole role) {
    return ListTile(
      leading: Icon(Icons.person_add_alt_1_outlined, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // Cierra el diálogo
        _navigateToRegistrationScreen(role); // Navega a la pantalla de registro correspondiente
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Para acceder al tema fácilmente

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Placeholder para tu logo, considera usar una imagen real
              Icon(Icons.medical_services_outlined, size: 80, color: theme.colorScheme.primary),
              SizedBox(height: 20),
              Text(
                'Bienvenido a SaludChain', // Nombre actualizado si es necesario
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Por favor ingrese un email válido.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    SizedBox(height: 12),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 12),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _submit,
                      child: Text('Iniciar Sesión'),
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton( // <<--- NUEVO BOTÓN DE REGISTRO
                onPressed: _showRoleSelectionDialog,
                child: Text('¿No tienes una cuenta? Registrarse'),
                style: theme.textButtonTheme.style,
              ),
              SizedBox(height: 30),
              Text(
                'Usuarios de prueba:\npaciente@test.com\ndoctor@test.com\nventas@test.com\nlab@test.com\n(Pass: password)',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}