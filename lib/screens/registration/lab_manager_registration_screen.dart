// lib/screens/registration/lab_manager_registration_screen.dart
import 'package:flutter/material.dart';
import 'components/registration_form_field.dart';
import 'components/file_picker_placeholder.dart';

class LabManagerRegistrationScreen extends StatefulWidget {
  @override
  _LabManagerRegistrationScreenState createState() => _LabManagerRegistrationScreenState();
}

class _LabManagerRegistrationScreenState extends State<LabManagerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Campos específicos para Encargado de Laboratorio
  String _nombreCompleto = '';
  String _email = '';
  String _telefono = '';
  String _idEmpleado = '';
  String _establecimiento = '';
  // String _inePath; // Para el placeholder del archivo INE

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _trySubmitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); // Ocultar teclado

    if (isValid) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);

      // Simulación de registro
      print('--- Registro de Encargado de Laboratorio ---');
      print('Nombre: $_nombreCompleto');
      print('Email: $_email');
      print('Teléfono: $_telefono');
      print('ID Empleado: $_idEmpleado');
      print('Establecimiento: $_establecimiento');
      print('Contraseña: ${_passwordController.text}');
      // print('INE: (path simulado)');


      // TODO: Llamar al servicio de autenticación/registro con los datos
      // Ejemplo: await AuthService.registerLabManager(...);

      Future.delayed(Duration(seconds: 1)).then((_) {
        if (mounted) { // Verificar que el widget sigue montado antes de llamar a setState
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro de Enc. de Laboratorio exitoso (simulación).'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(); // Volver a la pantalla anterior (Login o Diálogo de Roles)
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Para acceder al tema fácilmente
    return Scaffold(
      appBar: AppBar(title: Text('Registro Enc. Laboratorio')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Información Personal y Laboral", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              RegistrationFormField(
                labelText: 'Nombre Completo',
                prefixIcon: Icons.person_outline,
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese su nombre completo' : null,
                onSaved: (value) => _nombreCompleto = value!,
              ),
              RegistrationFormField(
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Ingrese un email válido.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              RegistrationFormField(
                labelText: 'Teléfono de Contacto',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese su número de teléfono' : null,
                onSaved: (value) => _telefono = value!,
              ),
              RegistrationFormField(
                labelText: 'ID de Empleado',
                prefixIcon: Icons.badge_outlined,
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese su ID de empleado' : null,
                onSaved: (value) => _idEmpleado = value!,
              ),
              RegistrationFormField(
                labelText: 'Establecimiento (Laboratorio)',
                prefixIcon: Icons.science_outlined, // Icono relevante para laboratorio
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese el nombre del establecimiento' : null,
                onSaved: (value) => _establecimiento = value!,
              ),
              FilePickerPlaceholder(label: 'INE (Identificación Oficial)'),
              SizedBox(height: 20),
              Text("Seguridad de la Cuenta", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              RegistrationFormField(
                labelText: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              RegistrationFormField(
                labelText: 'Confirmar Contraseña',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: true,
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _trySubmitForm,
                child: Text('Registrar Enc. Laboratorio'),
                style: theme.elevatedButtonTheme.style?.copyWith(
                  minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}