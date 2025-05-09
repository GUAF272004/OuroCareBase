import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/lab_order_model.dart';
import '../../models/lab_result_model.dart'; // Asegúrate que este modelo esté bien definido
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // Para el ID del técnico

class LabOrderDetailScreen extends StatefulWidget {
  final LabOrderModel labOrder;

  const LabOrderDetailScreen({Key? key, required this.labOrder}) : super(key: key);

  @override
  _LabOrderDetailScreenState createState() => _LabOrderDetailScreenState();
}

class _LabOrderDetailScreenState extends State<LabOrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late ApiService _apiService;
  String? _labTechnicianId;

  // Lista para manejar múltiples items de resultado
  List<LabResultItem> _resultItems = [];
  TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    _labTechnicianId = currentUser?.id;

    // Inicializar con un item de resultado vacío si no hay ninguno
    // o cargar items predefinidos si la orden los sugiere
    if (_resultItems.isEmpty) {
      _addResultItem();
    }
  }

  void _addResultItem() {
    setState(() {
      _resultItems.add(LabResultItem(name: '', value: '', units: '', referenceRange: ''));
    });
  }

  void _removeResultItem(int index) {
    setState(() {
      _resultItems.removeAt(index);
    });
  }

  Future<void> _submitResults() async {
    if (_labTechnicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ID de técnico no disponible.'), backgroundColor: Colors.red));
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Para guardar los valores de los TextFormField en los LabResultItem

      // Filtrar items vacíos (si el usuario añade más de los que llena)
      List<LabResultItem> validItems = _resultItems.where((item) => item.name.isNotEmpty && item.value.isNotEmpty).toList();

      if (validItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe ingresar al menos un resultado válido.'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      LabResult newLabResult = LabResult(
        resultId: '', // El backend debería generar esto
        orderId: widget.labOrder.orderId,
        patientId: widget.labOrder.patientId,
        labTechnicianId: _labTechnicianId!,
        items: validItems,
        resultDate: DateTime.now(),
        notes: _notesController.text,
        // filePath: null, // Manejar subida de archivos si es necesario
      );

      try {
        bool success = await _apiService.submitLabResult(newLabResult);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resultados enviados con éxito.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Devuelve true para indicar que se enviaron resultados
        } else {
          throw Exception('Fallo al enviar los resultados.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar resultados: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados para Orden ${widget.labOrder.orderId.substring(0,6)}...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Paciente: ${widget.labOrder.patientName}', style: Theme.of(context).textTheme.titleMedium),
              Text('Prueba Solicitada: ${widget.labOrder.testName}', style: Theme.of(context).textTheme.titleSmall),
              SizedBox(height: 20),
              Text('Resultados:', style: Theme.of(context).textTheme.titleMedium),
              ..._buildResultItemFields(),
              TextButton.icon(
                icon: Icon(Icons.add_circle_outline),
                label: Text("Añadir Otro Resultado"),
                onPressed: _addResultItem,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notas Adicionales',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: Icon(Icons.send),
                label: Text('Enviar Resultados'),
                onPressed: _submitResults,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResultItemFields() {
    List<Widget> fields = [];
    for (int i = 0; i < _resultItems.length; i++) {
      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Resultado #${i + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                      if (_resultItems.length > 1)
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeResultItem(i),
                        ),
                    ],
                  ),
                  TextFormField(
                    initialValue: _resultItems[i].name,
                    decoration: InputDecoration(labelText: 'Nombre de Prueba/Componente'),
                    validator: (value) => (value == null || value.isEmpty) && _resultItems[i].value.isNotEmpty ? 'Requerido si hay valor' : null,
                    onChanged: (value) => _resultItems[i].name = value,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: _resultItems[i].value,
                          decoration: InputDecoration(labelText: 'Valor'),
                          validator: (value) => (value == null || value.isEmpty) && _resultItems[i].name.isNotEmpty ? 'Requerido si hay nombre' : null,
                          onChanged: (value) => _resultItems[i].value = value,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: _resultItems[i].units,
                          decoration: InputDecoration(labelText: 'Unidades'),
                          onChanged: (value) => _resultItems[i].units = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    initialValue: _resultItems[i].referenceRange,
                    decoration: InputDecoration(labelText: 'Rango de Referencia (Opcional)'),
                    onChanged: (value) => _resultItems[i].referenceRange = value,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return fields;
  }
}