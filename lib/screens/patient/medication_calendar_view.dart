import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart'; // Descomentar cuando instales

class MedicationCalendarScreen extends StatefulWidget {
  @override
  _MedicationCalendarScreenState createState() => _MedicationCalendarScreenState();
}

class _MedicationCalendarScreenState extends State<MedicationCalendarScreen> {
  // CalendarController _calendarController; // Para table_calendar < 3.0.0
  // DateTime _selectedDay = DateTime.now(); // Para table_calendar >= 3.0.0
  // Map<DateTime, List<dynamic>> _events = {}; // Para eventos en el calendario

  @override
  void initState() {
    super.initState();
    // _calendarController = CalendarController();
    // TODO: Cargar eventos/horarios de medicación desde el servicio
  }

  // @override
  // void dispose() {
  //   _calendarController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horario de Medicamentos'),
      ),
      body: Column(
        children: [
          // Descomentar y configurar TableCalendar cuando lo instales
          // TableCalendar(
          //   firstDay: DateTime.utc(2020, 1, 1),
          //   lastDay: DateTime.utc(2030, 12, 31),
          //   focusedDay: _selectedDay,
          //   selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          //   onDaySelected: (selectedDay, focusedDay) {
          //     setState(() {
          //       _selectedDay = selectedDay;
          //       // _focusedDay = focusedDay; // update `_focusedDay` here as well
          //     });
          //   },
          //   // eventLoader: (day) {
          //   //   return _events[day] ?? [];
          //   // },
          //   calendarStyle: CalendarStyle(
          //     todayDecoration: BoxDecoration(
          //       color: Colors.orangeAccent,
          //       shape: BoxShape.circle,
          //     ),
          //     selectedDecoration: BoxDecoration(
          //       color: Theme.of(context).primaryColor,
          //       shape: BoxShape.circle,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Integración de Calendario (table_calendar) PENDIENTE.\nAquí se mostrarían tus horarios de medicación.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          ),
          // Expanded(
          //   child: _buildEventList(), // Lista de medicamentos para el día seleccionado
          // ),
        ],
      ),
    );
  }

// Widget _buildEventList() {
//   final selectedEvents = _events[_selectedDay] ?? [];
//   if (selectedEvents.isEmpty) {
//     return Center(child: Text("No hay medicamentos para este día."));
//   }
//   return ListView.builder(
//     itemCount: selectedEvents.length,
//     itemBuilder: (context, index) {
//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
//         decoration: BoxDecoration(
//           border: Border.all(),
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//         child: ListTile(
//           onTap: () => print('${selectedEvents[index]} tapped!'),
//           title: Text(selectedEvents[index].toString()),
//         ),
//       );
//     },
//   );
// }
}