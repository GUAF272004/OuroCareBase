// lib/screens/registration/components/file_picker_placeholder.dart
import 'package:flutter/material.dart';

class FilePickerPlaceholder extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Opcional, por si quieres simular algo al presionar

  const FilePickerPlaceholder({Key? key, required this.label, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall?.copyWith(color: theme.inputDecorationTheme.labelStyle?.color ?? theme.colorScheme.primary)),
          SizedBox(height: 8),
          OutlinedButton.icon(
            icon: Icon(Icons.attach_file_outlined),
            label: Text('Seleccionar Archivo (PENDIENTE)'),
            onPressed: onPressed ?? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Funcionalidad de carga de archivos no implementada en esta plantilla.')),
              );
            },
            style: theme.outlinedButtonTheme.style?.copyWith(
              minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              side: MaterialStateProperty.all(BorderSide(color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}