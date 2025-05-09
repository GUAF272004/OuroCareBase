import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart'; // Asegúrate que Time también se importa si es necesario, o usa day_night_time_picker.Time
import '../../models/medication_schedule_entry_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';


class MedicationCalendarScreen extends StatefulWidget {
  @override
  _MedicationCalendarScreenState createState() =>
      _MedicationCalendarScreenState();
}

class _MedicationCalendarScreenState extends State<MedicationCalendarScreen> {
  ApiService? _apiService;
  String? _patientId;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<MedicationScheduleEntry>> _events = {};
  Future<void>? _loadEventsFuture;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      try {
        _apiService = Provider.of<ApiService>(context, listen: false);
        final authService = Provider.of<AuthService>(context, listen: false);
        _patientId = authService.currentUser?.id;

        if (_patientId != null && _patientId!.isNotEmpty) {
          _selectedDay = _focusedDay;
          _loadEventsFuture = _loadEventsForMonth(_focusedDay);
        } else {
          _handleMissingPatientId();
        }
      } catch (e) {
        print("Error al inicializar dependencias (Provider): $e");
        _handleMissingPatientId(error: e.toString());
      }
      _isInitialized = true;
    }
  }

  void _handleMissingPatientId({String? error}) {
    print("Patient ID no disponible o error en inicialización: $error");
    if (mounted) {
      setState(() {
        _loadEventsFuture = Future.value();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error != null
                  ? 'Error de inicialización: $error'
                  : 'No se pudo identificar al paciente.')),
        );
      }
    });
  }

  Future<void> _loadEventsForMonth(DateTime monthDate) async {
    if (_patientId == null || _patientId!.isEmpty || _apiService == null) {
      if (mounted && _events.isNotEmpty) setState(() => _events = {});
      return;
    }
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0);
    try {
      final scheduledEntries = await _apiService!.getMedicationSchedule(
          _patientId!, firstDayOfMonth, lastDayOfMonth);
      final Map<DateTime, List<MedicationScheduleEntry>> newEvents = {};
      for (var entry in scheduledEntries) {
        final day = DateTime.utc(
            entry.dueTime.year, entry.dueTime.month, entry.dueTime.day);
        newEvents.putIfAbsent(day, () => []).add(entry);
      }
      if (mounted) setState(() => _events = newEvents);
    } catch (e) {
      print("Error cargando eventos: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar horario: ${e.toString()}')),
        );
        setState(() => _events = {});
      }
    }
  }

  List<MedicationScheduleEntry> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      if (mounted) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      }
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    if (mounted) {
      setState(() { _focusedDay = focusedDay; });
      _loadEventsFuture = _loadEventsForMonth(focusedDay);
      // setState(() {}); // No es necesario llamar setState vacío aquí, _loadEventsForMonth lo hará si es necesario.
    }
  }

  Future<void> _refreshEvents() async {
    if (_patientId != null && _patientId!.isNotEmpty && _apiService != null) {
      // setState es llamado dentro de _loadEventsForMonth si es necesario,
      // pero envolver la asignación del futuro en setState asegura que
      // el FutureBuilder reaccione si _loadEventsFuture ya estaba completo.
      if (mounted) {
        setState(() {
          _loadEventsFuture = _loadEventsForMonth(_focusedDay);
        });
      }
    }
  }

  Future<void> _handleUpdateStatus( MedicationScheduleEntry entry, String newStatus) async {
    final apiService = _apiService;
    if (apiService == null) {
      print("ApiService no inicializado en _handleUpdateStatus");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de servicio. Intente de nuevo más tarde.')),
        );
      }
      return;
    }

    DateTime? finalTakenAt;

    if (newStatus == 'TOMADO') {
      final now = DateTime.now();
      final DateTime referenceDateForPicker = _selectedDay ?? entry.dueTime;
      TimeOfDay initialTimeOfDay = TimeOfDay.fromDateTime(entry.dueTime); // Sigue siendo TimeOfDay para la lógica
      final today = DateTime(now.year, now.month, now.day);

      if (isSameDay(referenceDateForPicker, today)) {
        initialTimeOfDay = now.isAfter(entry.dueTime)
            ? TimeOfDay.fromDateTime(now)
            : TimeOfDay.fromDateTime(entry.dueTime);
      }
      // else, initialTimeOfDay remains as TimeOfDay.fromDateTime(entry.dueTime)

      // Guardar el contexto antes del async gap
      final currentContext = context;

      Navigator.of(currentContext).push(
        showPicker(
          context: currentContext,
          // CORRECCIÓN: Convertir TimeOfDay a Time (del paquete day_night_time_picker)
          value: Time(hour: initialTimeOfDay.hour, minute: initialTimeOfDay.minute),
          onChange: (Time newTime) { // El tipo aquí es Time del paquete
            // Este callback se llama continuamente mientras el usuario cambia la hora.
            // No actualizaremos el estado aquí, solo cuando se confirme.
          },
          minuteInterval: TimePickerInterval.ONE,
          disableHour: false,
          disableMinute: false,
          okText: "CONFIRMAR",
          cancelText: "CANCELAR",
          accentColor: Theme.of(currentContext).primaryColor,
          unselectedColor: Colors.grey,
          iosStylePicker: false,
          // CORRECCIÓN: El parámetro isOnValueChange no existe, se elimina.
          // El comportamiento deseado (llamar solo al final) se maneja con onChangeDateTime.

          onChangeDateTime: (DateTime dateTime) {
            if (!mounted) return;

            final DateTime dateOfIntake = _selectedDay ?? entry.dueTime;
            finalTakenAt = DateTime(
              dateOfIntake.year,
              dateOfIntake.month,
              dateOfIntake.day,
              dateTime.hour,
              dateTime.minute,
            );

            _updateAndRefreshStatusInBackend(entry, newStatus, finalTakenAt)
                .catchError((error) {
              print("Error después de onChangeDateTime: $error");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al procesar la hora tomada: $error'), backgroundColor: Colors.red),
                );
              }
            });
          },
        ),
      );
      return;
    }

    await _updateAndRefreshStatusInBackend(entry, newStatus, null);
  }

  Future<void> _updateAndRefreshStatusInBackend(
      MedicationScheduleEntry entry, String newStatus, DateTime? takenAt) async {
    final apiService = _apiService;
    if (apiService == null) {
      print("ApiService no disponible en _updateAndRefreshStatusInBackend");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Servicio no disponible. Intente más tarde.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      // Optimistic UI update - puede ser antes o después de la llamada,
      // dependiendo de si quieres revertir en caso de error de backend.
      // Para una mejor experiencia, a menudo se hace antes.
      // Pero para consistencia, recargar después es más seguro.
      // Vamos a mantener la recarga después como estaba.

      bool success = await apiService.updateMedicationStatus(
        entry.scheduleId,
        newStatus,
        takenAt: takenAt,
      );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${entry.medicationName} marcada como $newStatus.'),
                backgroundColor: Colors.green),
          );
          // Actualizar localmente el evento específico para una UI más reactiva antes de la recarga completa
          // Esto es opcional si _refreshEvents es rápido y eficiente.
          // Si _refreshEvents es costoso, esta actualización local inmediata es buena.
          final dayKey = DateTime.utc(entry.dueTime.year, entry.dueTime.month, entry.dueTime.day);
          if (_events.containsKey(dayKey)) {
            final eventInList = _events[dayKey]?.firstWhere((e) => e.scheduleId == entry.scheduleId, orElse: () => entry); // orElse para evitar error si no está (aunque debería)
            if (eventInList != null) { // Dart 2.12+ null safety
              eventInList.status = newStatus;
              eventInList.takenAt = (newStatus == 'TOMADO') ? takenAt : null;
            }
          }
          setState(() {}); // Para reflejar el cambio en eventInList si no se usa _refreshEvents inmediatamente

          _refreshEvents(); // Recargar desde el servidor para asegurar consistencia total.
        }
      } else {
        // El API devolvió false pero no lanzó una excepción.
        throw Exception('Fallo al actualizar el estado del medicamento (API reportó no éxito).');
      }
    } catch (e) {
      print("Error en _updateAndRefreshStatusInBackend: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al actualizar estado: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
        // Podrías considerar revertir el cambio optimista si lo hiciste,
        // y luego refrescar para obtener el estado verdadero del servidor.
        _refreshEvents(); // Asegurar que la UI refleje el estado del servidor tras un error.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Horario de Medicamentos')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadEventsFuture == null && (_patientId == null || _patientId!.isEmpty)) {
      return Scaffold(
        appBar: AppBar(title: Text('Horario de Medicamentos')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "No se pudo identificar al paciente. Verifique su sesión e intente de nuevo.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Horario de Medicamentos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshEvents,
            tooltip: "Refrescar horario",
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar<MedicationScheduleEntry>(
            locale: 'es_ES',
            firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
            lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  bool hasPending = events.any((e) => e.status.toUpperCase() == 'PENDIENTE');
                  bool hasTaken = events.any((e) => e.status.toUpperCase() == 'TOMADO');
                  bool hasOmitted = events.any((e) => e.status.toUpperCase() == 'OMITIDO');

                  List<Widget> markers = [];
                  // Prioridad de marcadores: Omitido > Pendiente > Tomado
                  if (hasOmitted) {
                    markers.add(Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withOpacity(0.8)),
                      width: 7.0, height: 7.0, margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    ));
                  }
                  if (hasPending) {
                    markers.add(Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orangeAccent.withOpacity(0.8)),
                      width: 7.0, height: 7.0, margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    ));
                  }
                  // Solo mostrar verde si no hay pendientes ni omitidos, y sí hay tomados.
                  // O si quieres mostrar verde si *alguno* está tomado, independientemente de otros estados.
                  // La lógica actual era: si hay pendiente, muestra naranja. Sino, si hay tomado, muestra verde. Sino, si hay omitido, muestra rojo.
                  // Nueva lógica sugerida para múltiples marcadores o uno prioritario:
                  if (hasTaken && !hasPending && !hasOmitted) { // Si todos están tomados (o los que quedan están tomados)
                    markers.add(Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(0.8)),
                      width: 7.0, height: 7.0, margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    ));
                  }
                  // Limitar el número de marcadores para no saturar visualmente
                  if (markers.length > 2) markers = markers.sublist(0,2);


                  if (markers.isNotEmpty) {
                    return Positioned(
                      bottom: 1,
                      child: Row(mainAxisSize: MainAxisSize.min, children: markers),
                    );
                  }
                }
                return null;
              },
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1.5)
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              // markerSize: 5.0, // markerBuilder lo controla ahora
              markersAlignment: Alignment.bottomCenter, // Ajustar según el Positioned del markerBuilder
              markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              formatButtonShowsNext: false,
              formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 12),
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            onDaySelected: _onDaySelected,
            onPageChanged: _onPageChanged,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                if (mounted) setState(() => _calendarFormat = format);
              }
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: FutureBuilder<void>(
                future: _loadEventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _events.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }
                  // Considerar mostrar un indicador de carga incluso si hay eventos antiguos,
                  // si la recarga está en progreso.
                  if (snapshot.connectionState == ConnectionState.waiting && _events.isNotEmpty) {
                    // Podrías mostrar los eventos antiguos con un indicador sutil de recarga
                  }

                  if (snapshot.hasError && _events.isEmpty) { // Si no hay eventos y hubo error cargando
                    return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Error al cargar el horario. Revise su conexión o intente refrescar.", textAlign: TextAlign.center),
                        ));
                  }
                  // Si hay error pero _events no está vacío, se muestran los datos antiguos (stale),
                  // lo cual puede ser preferible a no mostrar nada. Se puede añadir un indicador de error.

                  final currentSelectedDay = _selectedDay ?? _focusedDay;
                  final selectedDayEvents = _getEventsForDay(currentSelectedDay);

                  if (selectedDayEvents.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                    return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("No hay medicamentos programados para este día.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                        )
                    );
                  }
                  if (selectedDayEvents.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Aún cargando para este día
                  }


                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedDayEvents[index];
                      Color statusColor = Colors.grey;
                      IconData statusIcon = Icons.schedule_outlined;
                      String statusText = event.status; // Usar el status tal cual viene del modelo inicialmente

                      switch (event.status.toUpperCase()) {
                        case 'PENDIENTE':
                          statusColor = Colors.orangeAccent;
                          statusIcon = Icons.hourglass_empty_outlined;
                          statusText = 'Pendiente';
                          break;
                        case 'TOMADO':
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle_outline;
                          statusText = 'Tomado';
                          break;
                        case 'OMITIDO':
                          statusColor = Colors.redAccent;
                          statusIcon = Icons.highlight_off_outlined;
                          statusText = 'Omitido';
                          break;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(statusIcon, color: statusColor, size: 30),
                          title: Text('${event.medicationName} - ${event.dosage}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          subtitle: Text(
                            'Programado: ${DateFormat.jm('es_ES').format(event.dueTime)}\n' +
                                (event.status.toUpperCase() == 'TOMADO' && event.takenAt != null
                                    ? 'Confirmado: ${DateFormat.jm('es_ES').format(event.takenAt!)}' // Cambiado "Tomado" por "Confirmado" para diferenciar
                                    : 'Estado: $statusText'),
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          isThreeLine: event.status.toUpperCase() == 'TOMADO' && event.takenAt != null,
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded),
                            tooltip: "Cambiar estado",
                            onSelected: (String value) {
                              _handleUpdateStatus(event, value);
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              if (event.status.toUpperCase() != 'TOMADO')
                                const PopupMenuItem<String>(
                                  value: 'TOMADO',
                                  child: ListTile(leading: Icon(Icons.check_circle_outline, color: Colors.green), title: Text('Marcar Tomado')),
                                ),
                              if (event.status.toUpperCase() != 'OMITIDO')
                                const PopupMenuItem<String>(
                                  value: 'OMITIDO',
                                  child: ListTile(leading: Icon(Icons.cancel_outlined, color: Colors.redAccent), title: Text('Marcar Omitido')),
                                ),
                              // Permitir cambiar a PENDIENTE si no lo está ya
                              if (event.status.toUpperCase() != 'PENDIENTE')
                                const PopupMenuItem<String>(
                                  value: 'PENDIENTE',
                                  child: ListTile(leading: Icon(Icons.hourglass_empty_outlined, color: Colors.orangeAccent), title: Text('Marcar Pendiente')),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}