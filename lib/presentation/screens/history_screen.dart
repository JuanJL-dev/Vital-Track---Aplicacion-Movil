// lib/presentation/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../../data/models/vital_sign_model.dart';
import '../../../core/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Detallado'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: FutureBuilder<List<VitalSign>>(
        future: context.read<AuthProvider>().getPatientHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay registros disponibles.'));
          }

          final history = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index];
              final dateStr = DateFormat(
                'dd/MM HH:mm',
              ).format(record.timestamp);

              Color iconColor;
              IconData iconData;

              switch (record.type) {
                case VitalType.heartRate:
                  iconColor = Colors.red;
                  iconData = Icons.favorite;
                  break;
                case VitalType.spo2:
                  iconColor = Colors.blue;
                  iconData = Icons.opacity;
                  break;
                case VitalType.temperature:
                  iconColor = Colors.orange;
                  iconData = Icons.thermostat;
                  break;
                case VitalType.steps:
                  iconColor = Colors.green;
                  iconData = Icons.directions_walk;
                  break;
                default:
                  iconColor = Colors.grey;
                  iconData = Icons.device_thermostat;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(iconData, color: iconColor),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- CAMBIO AQUÍ: Usamos typeName en lugar del enum raw ---
                      Text(
                        record.typeName.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Aquí record.status ya debería salir en español por el modelo anterior
                  subtitle: Text('Estado: ${record.status}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${record.displayValue} ${record.unit}',
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
