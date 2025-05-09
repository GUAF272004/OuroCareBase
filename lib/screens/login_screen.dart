// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart'; // Tu AuthService actualizado
import '../models/user_model.dart';

// Importar las pantallas de registro
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
  // Los controllers son útiles para poder acceder/limpiar los campos si es necesario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // bool _isLoading = false; // <<--- ELIMINADO (AuthService._isAttemptingLogin maneja la carga global)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // AuthService se encargará de limpiar su propio authErrorMessage al inicio de login()
    // Provider.of<AuthService>(context, listen: false).clearAuthError(); // Si tuvieras un método público para esto

    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save(); // Esto no es estrictamente necesario si usas controllers

    final email = _emailController.text;
    final password = _passwordController.text;

    // setState(() { _isLoading = true; }); // <<--- ELIMINADO

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.login(email, password);

    // No necesitamos verificar 'success' aquí para el mensaje de error.
    // AuthService actualiza 'authErrorMessage' y notifica.
    // Si el login es exitoso, el Consumer en main.dart navegará a HomeScreen.
    // Si falla, main.dart mantendrá LoginScreen, y el authErrorMessage se mostrará.

    // setState(() { _isLoading = false; }); // <<--- ELIMINADO
    // El estado de carga es manejado ahora por AuthService.isAttemptingLogin
    // y el Consumer en main.dart que muestra LoadingScreen.
  }

  void _navigateToRegistrationScreen(UserRole role) {
    Widget screen;
    switch (role) {
      case UserRole.doctor: screen = DoctorRegistrationScreen(); break;
      case UserRole.salesManager: screen = SalesManagerRegistrationScreen(); break;
      case UserRole.labManager: screen = LabManagerRegistrationScreen(); break;
      case UserRole.patient: screen = PatientRegistrationScreen(); break;
      default: debugPrint("Rol de registro no reconocido: $role"); return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showRoleSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Registrarse como'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildRoleOption(dialogContext, 'Doctor', UserRole.doctor),
              _buildRoleOption(dialogContext, 'Encargado de Ventas', UserRole.salesManager),
              _buildRoleOption(dialogContext, 'Encargado de Laboratorio', UserRole.labManager),
              _buildRoleOption(dialogContext, 'Paciente', UserRole.patient),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoleOption(BuildContext dialogContext, String title, UserRole role) {
    return ListTile(
      leading: Icon(Icons.person_add_alt_1_outlined, color: Theme.of(dialogContext).colorScheme.primary),
      title: Text(title),
      onTap: () {
        Navigator.of(dialogContext).pop();
        _navigateToRegistrationScreen(role);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Escuchar AuthService para el mensaje de error y el estado de carga
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.medical_services_outlined, size: 80, color: theme.colorScheme.primary),
              SizedBox(height: 20),
              Text(
                'Bienvenido a SaludChain', // O el nombre de tu app
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
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Por favor ingrese un email válido.';
                        }
                        return null;
                      },
                      // onSaved no es necesario si lees de _emailController.text
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña.';
                        }
                        return null;
                      },
                      // onSaved no es necesario si lees de _passwordController.text
                    ),
                    SizedBox(height: 12),
                    // Mostrar el mensaje de error directamente desde AuthService
                    if (authService.authErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0, top: 5.0),
                        child: Text(
                          authService.authErrorMessage!,
                          style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: authService.authErrorMessage != null ? 12 : 24),
                    // El botón de Iniciar Sesión. El indicador de carga global
                    // (LoadingScreen desde main.dart) se mostrará si authService.isAttemptingLogin es true.
                    // Si quieres un spinner local *además* del global, podrías usar authService.isAttemptingLogin aquí.
                    // Pero si el global ya reemplaza esta pantalla, no se verá.
                    // Por simplicidad, quitamos el spinner local:
                    ElevatedButton(
                      onPressed: authService.isAttemptingLogin ? null : _submit, // Deshabilitar si ya se está intentando
                      child: authService.isAttemptingLogin
                          ? SizedBox( // Mostrar un pequeño spinner en el botón si se desea
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                          : Text('Iniciar Sesión'),
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextButton(
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