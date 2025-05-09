import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/lab_result_model.dart'; // Usaremos LabResult
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // Para obtener el ID del técnico

class LabTestHistoryScreen extends StatefulWidget {
  const LabTestHistoryScreen({super.key});

  @override
  State<LabTestHistoryScreen> createState() => _LabTestHistoryScreenState();
}

class _LabTestHistoryScreenState extends State<LabTestHistoryScreen> {
  late Future<List<LabResult>> _labHistoryFuture;
  late ApiService _apiService;
  String? _labTechnicianId;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    _labTechnicianId = currentUser?.id;

    _loadHistory();
  }

  void _loadHistory() {
    if (_labTechnicianId != null) {
      setState(() {
        _labHistoryFuture = _apiService.getLabTestHistory(_labTechnicianId!, _startDate, _endDate);
      });
    } else {
      _labHistoryFuture = Future.value([]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ID de técnico no encontrado.')),
        );
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days:1)),
    );
    if (picked != null && (picked.start != _startDate || picked.end != _endDate)) {
      setState(() {
        _startDate = picked.start;
        _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
      _loadHistory();
    }
  }


  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat.yMd();
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Pruebas Enviadas'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Mostrando historial de: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LabResult>>(
              future: _labHistoryFuture,
              builder: (context, snapshot) {
                if (_labTechnicianId == null) {
                  return Center(child: Text('No se pudo cargar el ID del técnico.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar historial: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay pruebas registradas en este período.'));
                }

                final results = snapshot.data!;
                final filteredResults = results.where((result) {
                  return !result.resultDate.isBefore(_startDate) &&
                      !result.resultDate.isAfter(_endDate);
                }).toList();

                if (filteredResults.isEmpty) {
                  return Center(child: Text('No hay pruebas registradas en este período.'));
                }

                return ListView.builder(
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final result = filteredResults[index];
                    // Aquí necesitarías obtener el nombre de la prueba, paciente, etc.
                    // Esto podría requerir que LabResult contenga más información denormalizada
                    // o que hagas otra llamada para obtener detalles de la LabOrder si es necesario.
                    // Por ahora, mostramos el ID de la orden.
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: Icon(Icons.history_toggle_off_outlined, color: Theme.of(context).primaryColor),
                        title: Text('Resultados para Orden ID: ${result.orderId}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Paciente ID: ${result.patientId}'),
                            Text('Fecha Resultado: ${DateFormat.yMd().add_jm().format(result.resultDate)}'),
                            if (result.items.isNotEmpty)
                              Text('Primer resultado: ${result.items.first.name} ${result.items.first.value} ${result.items.first.units}'),
                            if (result.notes.isNotEmpty)
                              Text('Notas: ${result.notes}', style: TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        onTap: () {
                          // Opcional: Navegar a una vista detallada del resultado si la tienes
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => LabResultDetailViewScreen(result: result)));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}