import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/prescription_model.dart'; // Usaremos Prescription si tiene datos de venta
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // Para obtener el ID del vendedor

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late Future<List<Prescription>> _salesHistoryFuture;
  late ApiService _apiService;
  String? _salesPersonId;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    _salesPersonId = currentUser?.id;

    _loadHistory();
  }

  void _loadHistory() {
    if (_salesPersonId != null) {
      setState(() {
        _salesHistoryFuture = _apiService.getSalesHistory(_salesPersonId!, _startDate, _endDate);
      });
    } else {
      _salesHistoryFuture = Future.value([]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ID de vendedor no encontrado.')),
        );
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)), // Un día en el futuro para incluir hoy
    );
    if (picked != null && (picked.start != _startDate || picked.end != _endDate)) {
      setState(() {
        _startDate = picked.start;
        // Asegurarse de que la hora de endDate sea el final del día para incluir todas las ventas de ese día
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
        title: Text('Historial de Ventas'),
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
              'Mostrando ventas de: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Prescription>>(
              future: _salesHistoryFuture,
              builder: (context, snapshot) {
                if (_salesPersonId == null) {
                  return Center(child: Text('No se pudo cargar el ID del vendedor.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar historial: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay ventas registradas en este período.'));
                }

                final sales = snapshot.data!;
                // Filtrar localmente por si acaso la API no lo hizo (o para mayor precisión con la hora)
                final filteredSales = sales.where((sale) {
                  return sale.saleTimestamp != null &&
                      !sale.saleTimestamp!.isBefore(_startDate) &&
                      !sale.saleTimestamp!.isAfter(_endDate) &&
                      sale.status.toUpperCase() == 'VENDIDO';
                }).toList();

                if (filteredSales.isEmpty) {
                  return Center(child: Text('No hay ventas registradas en este período.'));
                }

                return ListView.builder(
                  itemCount: filteredSales.length,
                  itemBuilder: (context, index) {
                    final sale = filteredSales[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ListTile(
                        leading: Icon(Icons.receipt_long_outlined, color: Colors.green),
                        title: Text('Receta ID: ${sale.id} - Paciente: ${sale.patientName}'),
                        subtitle: Text(
                            'Medicamentos: ${sale.medicationsSummary}\nVendida el: ${sale.saleTimestamp != null ? DateFormat.yMd().add_jm().format(sale.saleTimestamp!) : 'N/A'}'
                        ),
                        // Podrías añadir un trailing para el monto si lo tienes
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