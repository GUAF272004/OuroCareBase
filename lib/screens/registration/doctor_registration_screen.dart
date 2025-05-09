// lib/screens/registration/doctor_registration_screen.dart
import 'package:flutter/material.dart';
import 'components/registration_form_field.dart';
import 'components/file_picker_placeholder.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  @override
  _DoctorRegistrationScreenState createState() => _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variables para datos del formulario
  String _nombreCompleto = '', _email = '', _telefono = '', _numeroLicencia = '', _establecimiento = '', _especializacion = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _trySubmitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);
      print('--- Registro de Doctor ---');
      print('Nombre: $_nombreCompleto, Email: $_email, Tel: $_telefono');
      print('Licencia: $_numeroLicencia, Establecimiento: $_establecimiento, Especialización: $_especializacion');
      print('Contraseña: ${_passwordController.text}');
      // TODO: Lógica de registro real
      Future.delayed(Duration(seconds: 1)).then((_) {
        if(mounted){
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro de doctor exitoso (simulación).'), backgroundColor: Colors.green));
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Doctor')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text("Información Profesional", style: theme.textTheme.titleLarge),
              SizedBox(height: 10),
              RegistrationFormField(labelText: 'Nombre Completo', prefixIcon: Icons.person_outline, onSaved: (val) => _nombreCompleto = val!, validator: (val) => (val==null || val.isEmpty) ? 'Campo requerido' : null),
              RegistrationFormField(labelText: 'Email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, onSaved: (val) => _email = val!, validator: (val) => (val==null || val.isEmpty || !val.contains('@')) ? 'Email inválido' : null),
              RegistrationFormField(labelText: 'Teléfono de Contacto', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, onSaved: (val) => _telefono = val!, validator: (val) => (val==null || val.isEmpty) ? 'Campo requerido' : null),
              RegistrationFormField(labelText: 'Número de Licencia Médica', prefixIcon: Icons.badge_outlined, onSaved: (val) => _numeroLicencia = val!, validator: (val) => (val==null || val.isEmpty) ? 'Campo requerido' : null),
              RegistrationFormField(labelText: 'Establecimiento (Hospital/Clínica)', prefixIcon: Icons.local_hospital_outlined, onSaved: (val) => _establecimiento = val!, validator: (val) => (val==null || val.isEmpty) ? 'Campo requerido' : null),
              RegistrationFormField(labelText: 'Especialización', prefixIcon: Icons.medical_information_outlined, onSaved: (val) => _especializacion = val!, validator: (val) => (val==null || val.isEmpty) ? 'Campo requerido' : null),
              FilePickerPlaceholder(label: 'Identificación Oficial (INE, Pasaporte)'),
              FilePickerPlaceholder(label: 'Comprobante de Licencia Médica (Cédula)'),
              SizedBox(height: 20),
              Text("Seguridad de la Cuenta", style: theme.textTheme.titleLarge),
              SizedBox(height: 10),
              RegistrationFormField(labelText: 'Contraseña', prefixIcon: Icons.lock_outline, obscureText: true, controller: _passwordController, validator: (val) => (val==null || val.isEmpty || val.length < 6) ? 'Mínimo 6 caracteres' : null),
              RegistrationFormField(labelText: 'Confirmar Contraseña', prefixIcon: Icons.lock_reset_outlined, obscureText: true, controller: _confirmPasswordController, validator: (val) => (val != _passwordController.text) ? 'Las contraseñas no coinciden' : null),
              SizedBox(height: 30),
              _isLoading ? Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _trySubmitForm, child: Text('Registrar Doctor'), style: theme.elevatedButtonTheme.style?.copyWith(minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)))),
            ],
          ),
        ),
      ),
    );
  }
}