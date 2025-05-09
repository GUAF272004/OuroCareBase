// lib/screens/registration/patient_registration_screen.dart
import 'package:flutter/material.dart';
import 'components/registration_form_field.dart';
import 'components/file_picker_placeholder.dart'; // Placeholder para archivos

class PatientRegistrationScreen extends StatefulWidget {
  @override
  _PatientRegistrationScreenState createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para campos de contraseña
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variables para guardar los datos del formulario
  String _nombreCompleto = '';
  String _email = '';
  String _telefono = '';
  DateTime? _fechaNacimiento; // Para el DatePicker
  String? _tipoDeSangre;
  // Para los placeholders de archivos, solo necesitas saber si se "adjuntó" algo (simulado)
  // String _identificacionOficialPath;
  // String _fotografiaPath;

  final List<String> _tiposDeSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];


  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Seleccione su fecha de nacimiento',
      builder: (context, child) { // Para aplicar el tema al DatePicker
        return Theme(
          data: Theme.of(context), // Usa el tema de la app
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  void _trySubmitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus(); // Ocultar teclado

    if (isValid) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);

      // Simulación de registro
      print('--- Registro de Paciente ---');
      print('Nombre: $_nombreCompleto');
      print('Email: $_email');
      print('Teléfono: $_telefono');
      print('Fecha de Nacimiento: ${_fechaNacimiento?.toIso8601String()}');
      print('Tipo de Sangre: $_tipoDeSangre');
      print('Contraseña: ${_passwordController.text}');
      // print('ID Oficial: (path simulado)');
      // print('Fotografía: (path simulado)');

      // TODO: Llamar al servicio de autenticación/registro con los datos
      // Ejemplo: await AuthService.registerPatient(...);

      Future.delayed(Duration(seconds: 1)).then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registro de paciente exitoso (simulación).'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(); // Volver a la pantalla anterior (Login o Diálogo)
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Paciente')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
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
                labelText: 'Teléfono',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese su número de teléfono' : null,
                onSaved: (value) => _telefono = value!,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  ),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Text(
                      _fechaNacimiento == null
                          ? 'No seleccionada'
                          : "${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}",
                      style: TextStyle(fontSize: 16, color: _fechaNacimiento == null ? theme.hintColor : theme.textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
              ),
              if (_fechaNacimiento == null && _formKey.currentState?.validate() == false && _formKey.currentState?.widget == this) // Muestra error si no se selecciona fecha y el form ha sido validado
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top:0, bottom: 8.0),
                  child: Text('Por favor seleccione su fecha de nacimiento.', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tipo de Sangre',
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                  value: _tipoDeSangre,
                  hint: Text('Seleccione...'),
                  items: _tiposDeSangre.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoDeSangre = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Seleccione su tipo de sangre' : null,
                  onSaved: (value) => _tipoDeSangre = value,
                ),
              ),
              FilePickerPlaceholder(label: 'Identificación Oficial (INE, Pasaporte)'),
              FilePickerPlaceholder(label: 'Fotografía Reciente'),
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
                child: Text('Registrarse'),
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