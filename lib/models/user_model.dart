// lib/models/user_model.dart

// El enum UserRole ya está definido como lo proporcionaste
enum UserRole { patient, doctor, salesManager, labManager, unknown }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? token; // Para la gestión de sesión
  final String? qrIdentifier; // Añadido de tu análisis anterior, hazlo opcional
  final String? specialty; // <<--- CAMPO AÑADIDO PARA LA ESPECIALIDAD DEL DOCTOR

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.qrIdentifier, // Añadido al constructor
    this.specialty,    // <<--- AÑADIDO AL CONSTRUCTOR
  });

  // Factory constructor para crear un User desde un JSON (ej. respuesta de API)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['user_id'] as String? ?? 'fallback_id', // Más robusto
      name: json['name'] as String? ?? 'Nombre no disponible',
      email: json['email'] as String? ?? 'email_no_disponible@example.com',
      role: _parseRole(json['role'] as String? ?? ''),
      token: json['token'] as String?,
      qrIdentifier: json['qrIdentifier'] as String?, // Mapear qrIdentifier
      specialty: json['specialty'] as String?,      // <<--- MAPEAR SPECIALTY DESDE JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last, // Convierte enum a string 'patient', 'doctor', etc.
      'token': token,
      'qrIdentifier': qrIdentifier, // Incluir qrIdentifier
      'specialty': specialty,       // <<--- INCLUIR SPECIALTY EN JSON
    };
  }

  static UserRole _parseRole(String roleString) {
    switch (roleString.toLowerCase().replaceAll('_', '')) { // Hacer más flexible el parseo
      case 'patient':
        return UserRole.patient;
      case 'doctor':
        return UserRole.doctor;
      case 'salesmanager': // Cubre 'salesmanager' y 'sales_manager'
        return UserRole.salesManager;
      case 'labmanager':   // Cubre 'labmanager' y 'lab_manager'
        return UserRole.labManager;
      default:
        print("Advertencia: Rol desconocido recibido desde la API: '$roleString'");
        return UserRole.unknown;
    }
  }

  // Helper para obtener el nombre del rol en español para la UI
  String getRoleName() {
    switch (role) {
      case UserRole.patient:
        return 'Paciente';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.salesManager:
        return 'Encargado de Ventas';
      case UserRole.labManager:
        return 'Encargado de Laboratorio';
      default:
        return 'Desconocido';
    }
  }
}

// La clase PatientForDoctorView y samplePatients permanecen igual que las proporcionaste.
// Solo nos enfocamos en la clase User para este error.
class PatientForDoctorView {
  final String id;
  final String name;
  final String email;
  final DateTime lastVisit;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? photoUrl;

  PatientForDoctorView({
    required this.id,
    required this.name,
    required this.email,
    required this.lastVisit,
    this.dateOfBirth,
    this.phoneNumber,
    this.photoUrl,
  });
}

List<PatientForDoctorView> samplePatients = [
  PatientForDoctorView(
      id: 'p001', name: 'Ana Torres', email: 'ana.torres@email.com',
      lastVisit: DateTime.now().subtract(Duration(days: 30)),
      dateOfBirth: DateTime(1985, 5, 15), phoneNumber: '555-0101',
      photoUrl: 'https://via.placeholder.com/150/FFA500/FFFFFF?Text=AT'
  ),
  PatientForDoctorView(
      id: 'p002', name: 'Luis Vera', email: 'luis.vera@email.com',
      lastVisit: DateTime.now().subtract(Duration(days: 90)),
      dateOfBirth: DateTime(1972, 11, 30), phoneNumber: '555-0102',
      photoUrl: 'https://via.placeholder.com/150/4682B4/FFFFFF?Text=LV'
  ),
  PatientForDoctorView(
      id: 'p003', name: 'Sofia Castro', email: 'sofia.castro@email.com',
      lastVisit: DateTime.now().subtract(Duration(days: 15)),
      dateOfBirth: DateTime(1990, 8, 22), phoneNumber: '555-0103',
      photoUrl: 'https://via.placeholder.com/150/32CD32/FFFFFF?Text=SC'
  ),
];