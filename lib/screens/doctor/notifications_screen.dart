import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart'; // Para obtener el ID del doctor

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;
  late ApiService _apiService;
  String? _doctorId;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    _doctorId = currentUser?.id;

    if (_doctorId != null) {
      _notificationsFuture = _apiService.getDoctorNotifications(_doctorId!);
    } else {
      // Manejar caso donde doctorId es null, quizá mostrar error o lista vacía
      _notificationsFuture = Future.value([]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ID de doctor no encontrado.')),
        );
      });
    }
  }

  void _refreshNotifications() {
    if (_doctorId != null) {
      setState(() {
        _notificationsFuture = _apiService.getDoctorNotifications(_doctorId!);
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    try {
      bool success = await _apiService.markNotificationAsRead(notification.id);
      if (success) {
        _refreshNotifications(); // Recargar para actualizar el estado visual
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo marcar como leída.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alertas y Notificaciones'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (_doctorId == null) {
            return Center(child: Text('No se pudo cargar el ID del doctor.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar notificaciones: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay notificaciones.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                color: notification.isRead ? Colors.white : Colors.lightBlue[50],
                margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  leading: Icon(
                    notification.isRead ? Icons.notifications_none_outlined : Icons.notifications_active,
                    color: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
                  ),
                  title: Text(notification.message, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text('${notification.type} - ${DateFormat.yMd().add_jm().format(notification.createdAt)}'),
                  onTap: () {
                    // Acción al tocar la notificación, ej. navegar a la entidad relacionada
                    print('Notificación ${notification.id} tocada.');
                    if (!notification.isRead) {
                      _markAsRead(notification);
                    }
                    // Ejemplo: if (notification.type == 'LAB_RESULT_READY' && notification.relatedEntityId != null) {
                    //   Navigator.push(context, MaterialPageRoute(builder: (_) => LabResultDetailScreen(resultId: notification.relatedEntityId!)));
                    // }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}