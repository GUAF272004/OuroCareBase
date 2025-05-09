// lib/screens/registration/patient_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Asegúrate de tener esta importación y el paquete provider
import '../../services/auth_service.dart'; // Ajusta la ruta si es diferente
import 'components/registration_form_field.dart';
import 'components/file_picker_placeholder.dart'; // Placeholder para archivos

class PatientRegistrationScreen extends StatefulWidget {
  @override
  _PatientRegistrationScreenState createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  // bool _isLoading = false; // Se manejará con el AuthService.isRegistering

  // Controladores para campos de contraseña
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variables para guardar los datos del formulario
  String _nombreCompleto = '';
  String _email = '';
  String _telefono = '';
  DateTime? _fechaNacimiento;
  String? _tipoDeSangre;

  final List<String> _tiposDeSangre = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Desconocido'];

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
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

  Future<void> _trySubmitForm() async { // Convertida a async
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();

    // Validaciones adicionales explícitas si no están cubiertas por validadores de FormField
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione su fecha de nacimiento.'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (_tipoDeSangre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione su tipo de sangre.'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState?.save();
      // setState(() => _isLoading = true); // AuthService manejará el estado de carga

      // Usar Provider para obtener la instancia de AuthService
      final authService = Provider.of<AuthService>(context, listen: false);

      print('--- Enviando Datos de Registro de Paciente ---');
      print('Nombre: $_nombreCompleto');
      print('Email: $_email');
      print('Teléfono: $_telefono');
      print('Fecha de Nacimiento (ISO): ${_fechaNacimiento?.toIso8601String()}'); // El servicio lo formatea a YYYY-MM-DD
      print('Tipo de Sangre: $_tipoDeSangre');
      print('Contraseña: ${_passwordController.text}');

      try {
        final result = await authService.registerPatient(
          name: _nombreCompleto,
          email: _email,
          password: _passwordController.text,
          phone: _telefono,
          birthDate: _fechaNacimiento,
          bloodType: _tipoDeSangre,
        );

        if (!mounted) return; // Verificar si el widget sigue montado

        // setState(() => _isLoading = false); // AuthService notifica a los listeners

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registro de paciente exitoso.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar a la pantalla de login o directamente al dashboard si se hace auto-login
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error durante el registro.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (error) {
        // setState(() => _isLoading = false); // AuthService notifica
        if (!mounted) return;
        print("Error capturado en _trySubmitForm: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocurrió un error inesperado durante el registro.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor corrija los errores en el formulario.'), backgroundColor: Colors.orangeAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Escuchar el estado de carga del AuthService
    final authService = Provider.of<AuthService>(context);
    final bool isLoading = authService.isRegistering; // Usar el estado de AuthService

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Paciente'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
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
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese su nombre completo' : null,
                onSaved: (value) => _nombreCompleto = value!.trim(),
              ),
              RegistrationFormField(
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty || !value.contains('@')) {
                    return 'Ingrese un email válido.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!.trim(),
              ),
              RegistrationFormField(
                labelText: 'Teléfono',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese su número de teléfono' : null,
                onSaved: (value) => _telefono = value!.trim(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    prefixIcon: Icon(Icons.calendar_today_outlined, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  ),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Text(
                      _fechaNacimiento == null
                          ? 'No seleccionada'
                          : "${_fechaNacimiento!.day.toString().padLeft(2, '0')}/${_fechaNacimiento!.month.toString().padLeft(2, '0')}/${_fechaNacimiento!.year}",
                      style: TextStyle(fontSize: 16, color: _fechaNacimiento == null ? theme.hintColor : theme.textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
              ),
              // No se necesita la validación explícita aquí si se valida en _trySubmitForm antes de la llamada
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tipo de Sangre',
                    prefixIcon: Icon(Icons.bloodtype_outlined, color: theme.colorScheme.primary),
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
                  // onSaved: (value) => _tipoDeSangre = value, // ya se actualiza con onChanged
                ),
              ),
              FilePickerPlaceholder(label: 'Identificación Oficial (INE, Pasaporte)'), // Funcionalidad no implementada en backend
              FilePickerPlaceholder(label: 'Fotografía Reciente'), // Funcionalidad no implementada en backend
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
              isLoading // Usar la variable isLoading del AuthService
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _trySubmitForm,
                child: Text('Registrarse'),
                style: theme.elevatedButtonTheme.style?.copyWith(
                  minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
                  // Puedes añadir más estilos si lo deseas
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}