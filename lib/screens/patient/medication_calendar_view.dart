import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/medication_schedule_entry_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // Para obtener el ID del paciente

class MedicationCalendarScreen extends StatefulWidget {
  @override
  _MedicationCalendarScreenState createState() => _MedicationCalendarScreenState();
}

class _MedicationCalendarScreenState extends State<MedicationCalendarScreen> {
  late ApiService _apiService;
  late String _patientId;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<MedicationScheduleEntry>> _events = {};
  late Future<void> _loadEventsFuture;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    _patientId = currentUser?.id ?? ''; // Asegúrate de que el ID del paciente esté disponible

    _selectedDay = _focusedDay;
    _loadEventsFuture = _loadEventsForMonth(_focusedDay);
  }

  Future<void> _loadEventsForMonth(DateTime monthDate) async {
    // Cargar eventos para el mes visible
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final lastDayOfMonth = DateTime(monthDate.year, monthDate.month + 1, 0); // Día 0 del siguiente mes es el último del actual

    if (_patientId.isEmpty) {
      print("Patient ID no disponible.");
      if (mounted) setState(() => _events = {});
      return;
    }

    try {
      final scheduledEntries = await _apiService.getMedicationSchedule(_patientId, firstDayOfMonth, lastDayOfMonth);
      final Map<DateTime, List<MedicationScheduleEntry>> newEvents = {};
      for (var entry in scheduledEntries) {
        final day = DateTime.utc(entry.dueTime.year, entry.dueTime.month, entry.dueTime.day);
        if (newEvents[day] == null) {
          newEvents[day] = [];
        }
        newEvents[day]!.add(entry);
      }
      if (mounted) {
        setState(() {
          _events = newEvents;
        });
      }
    } catch (e) {
      print("Error cargando eventos: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar horario: ${e.toString()}')),
        );
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
    _focusedDay = focusedDay;
    _loadEventsFuture = _loadEventsForMonth(focusedDay); // Recargar eventos para el nuevo mes
  }

  Future<void> _updateMedicationStatus(MedicationScheduleEntry entry, String newStatus) async {
    try {
      bool success = await _apiService.updateMedicationStatus(
        entry.scheduleId,
        newStatus,
        takenAt: newStatus == 'TOMADO' ? DateTime.now() : null,
      );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${entry.medicationName} marcada como $newStatus.'), backgroundColor: Colors.green),
          );
          _loadEventsForMonth(_focusedDay); // Recargar eventos
        }
      } else {
        throw Exception('Fallo al actualizar');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar estado: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horario de Medicamentos'),
      ),
      body: Column(
        children: [
          TableCalendar<MedicationScheduleEntry>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle
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
            child: FutureBuilder(
                future: _loadEventsFuture, // Espera a que _loadEventsForMonth termine
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _events.isEmpty) {
                    // Muestra cargando solo si no hay eventos ya cargados (para evitar parpadeo en cambio de mes)
                    return Center(child: CircularProgressIndicator());
                  }
                  // Si hay un error en la carga inicial, puedes mostrarlo aquí.
                  // if (snapshot.hasError) {
                  //   return Center(child: Text("Error cargando eventos."));
                  // }

                  final selectedDayEvents = _getEventsForDay(_selectedDay!);
                  if (selectedDayEvents.isEmpty) {
                    return Center(
                      child: Text("No hay medicamentos para este día."),
                    );
                  }
                  return ListView.builder(
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedDayEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        child: ListTile(
                          title: Text('${event.medicationName} (${event.dosage})'),
                          subtitle: Text('Hora: ${DateFormat.jm().format(event.dueTime)} - Estado: ${event.status}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) {
                              _updateMedicationStatus(event, value);
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'TOMADO',
                                child: Text('Marcar como Tomado'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'OMITIDO',
                                child: Text('Marcar como Omitido'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'PENDIENTE',
                                child: Text('Marcar como Pendiente'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
}