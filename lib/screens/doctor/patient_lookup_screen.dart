// lib/screens/doctor/patient_lookup_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'patient_detail_view.dart';

class PatientLookupScreen extends StatefulWidget {
  final bool autoFocusSearch; // <<--- NUEVO PARÁMETRO

  PatientLookupScreen({this.autoFocusSearch = false}); // <<--- CONSTRUCTOR ACTUALIZADO

  @override
  _PatientLookupScreenState createState() => _PatientLookupScreenState();
}

class _PatientLookupScreenState extends State<PatientLookupScreen> {
  List<PatientForDoctorView> _patients = [];
  List<PatientForDoctorView> _filteredPatients = [];
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode(); // <<--- NUEVO FOCUSNODE

  @override
  void initState() {
    super.initState();
    _patients = List.from(samplePatients);
    _filteredPatients = List.from(_patients);
    _searchController.addListener(_filterPatients);

    if (widget.autoFocusSearch) { // <<--- USAR EL PARÁMETRO
      // Pequeño delay para asegurar que el widget está construido antes de enfocar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Verificar que el widget sigue montado
          FocusScope.of(context).requestFocus(_searchFocusNode);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPatients);
    _searchController.dispose();
    _searchFocusNode.dispose(); // <<--- DISPOSE DEL FOCUSNODE
    super.dispose();
  }

  void _filterPatients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
            patient.email.toLowerCase().contains(query) ||
            patient.id.toLowerCase().contains(query);
      }).toList();
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Paciente'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode, // <<--- ASIGNAR EL FOCUSNODE
              // autofocus: widget.autoFocusSearch, // Alternativamente, podrías usar autofocus directamente aquí, pero el requestFocus en initState es a veces más fiable post-build.
              decoration: InputDecoration(
                labelText: 'Buscar por nombre, email o ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredPatients.isEmpty
                ? Center(child: Text('No se encontraron pacientes.'))
                : ListView.builder(
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: Text(patient.name.isNotEmpty ? patient.name.substring(0,1).toUpperCase() : 'P', style: TextStyle(color: Theme.of(context).primaryColorDark)),
                    ),
                    title: Text(patient.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${patient.id}\nÚltima visita: ${_formatDate(patient.lastVisit)}'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PatientDetailView(patient: patient)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}