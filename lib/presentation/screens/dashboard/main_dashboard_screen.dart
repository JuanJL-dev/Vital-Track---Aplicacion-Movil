import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/vital_sign_model.dart';
import '../../providers/vitals_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vital_card.dart';
import '../vitals/vital_detail_screen.dart';
import '../iot/device_screen.dart';
import '../profile/profile_screen.dart';
import '../education/education_screen.dart';
import '../history_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  // --- NUEVAS VARIABLES PARA CONTROLAR LOS POP-UPS ---
  String _lastAlertType = '';
  bool _isPopupShowing = false;

  @override
  void initState() {
    super.initState();
    // Agregamos 'async' aquí para poder esperar la sincronización
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final vitalsProvider = context.read<VitalsProvider>();

      // 🔥 1. SINCRONIZAMOS LOS RANGOS APENAS ABRE EL DASHBOARD
      await authProvider.syncRangosMedicos();

      // 2. Ahora sí, configuramos el VitalsProvider con los datos actualizados
      vitalsProvider.setAuthProvider(authProvider);

      if (authProvider.currentUser != null) {
        vitalsProvider.setPatientId(authProvider.currentUser!.id);
      }
      vitalsProvider.loadInitialData();

      // --- ESCUCHADOR DE EMERGENCIAS EN TIEMPO REAL ---
      vitalsProvider.addListener(() {
        if (mounted) _checkForPopups(vitalsProvider);
      });
    });
  }

  void _checkForPopups(VitalsProvider provider) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    List<String> alertasActivas = [];

    // --- DEBUG: Esto te dirá en la consola qué está leyendo la App ---
    // print("Comparando BPM: ${provider.heartRate?.value} contra Min: ${user.bpmMin} y Max: ${user.bpmMax}");

    // 1. Validar Ritmo Cardíaco (BPM)
    if (provider.heartRate != null) {
      if (provider.heartRate!.value > user.bpmMax) {
        alertasActivas.add(
          'Ritmo Cardíaco Alto: ${provider.heartRate!.value} bpm (Máx: ${user.bpmMax})',
        );
      } else if (provider.heartRate!.value < user.bpmMin) {
        alertasActivas.add(
          'Ritmo Cardíaco Bajo: ${provider.heartRate!.value} bpm (Mín: ${user.bpmMin})',
        );
      }
    }

    // 2. Validar Oxígeno (SpO2)
    if (provider.spo2 != null) {
      if (provider.spo2!.value < user.spo2Min) {
        alertasActivas.add(
          'SpO₂ Bajo: ${provider.spo2!.value}% (Mín: ${user.spo2Min}%)',
        );
      }
    }

    // 3. Validar Temperatura
    if (provider.temperature != null) {
      if (provider.temperature!.value > user.tempMax) {
        alertasActivas.add(
          'Temperatura Alta: ${provider.temperature!.value}°C (Máx: ${user.tempMax}°C)',
        );
      } else if (provider.temperature!.value < user.tempMin) {
        alertasActivas.add(
          'Temperatura Baja: ${provider.temperature!.value}°C (Mín: ${user.tempMin}°C)',
        );
      }
    }

    final mensajeCombinado = alertasActivas.join('\n\n');

    if (mensajeCombinado.isNotEmpty &&
        mensajeCombinado != _lastAlertType &&
        !_isPopupShowing) {
      _lastAlertType = mensajeCombinado;
      _showEmergencyPopup(mensajeCombinado);
    } else if (mensajeCombinado.isEmpty) {
      _lastAlertType = '';
    }
  }

  // --- DISEÑO DEL POP-UP (ALERT DIALOG) ---
  void _showEmergencyPopup(String message) {
    _isPopupShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false, // Impide que se cierre tocando afuera
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.red.shade50,
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red.shade800, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡ALERTA MÉDICA!',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _isPopupShowing = false; // Liberamos el candado
              },
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          const HistoryScreen(),
          const EducationScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Aprender'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          _buildDeviceStatus(),
          _buildAlertBanner(),
          const SizedBox(height: 24),
          Text('Signos Vitales', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildVitalsGrid(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Consumer<VitalsProvider>(
      builder: (context, vitalsProvider, child) {
        if (vitalsProvider.activeAlertMessage == null)
          return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade800, width: 2),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade800,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡ALERTA MÉDICA!',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vitalsProvider.activeAlertMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceStatus() {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: deviceProvider.isConnected
                ? Colors.green.shade50
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                deviceProvider.isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: deviceProvider.isConnected
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 12),
              Text(
                deviceProvider.isConnected
                    ? 'Reloj VitalTrack Conectado'
                    : 'Buscando Reloj...',
                style: TextStyle(
                  color: deviceProvider.isConnected
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVitalsGrid() {
    return Consumer<VitalsProvider>(
      builder: (context, vitalsProvider, child) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: [
            VitalCard(
              title: 'Frec. Cardíaca',
              value: vitalsProvider.heartRate?.displayValue ?? '--',
              unit: 'lpm',
              status: vitalsProvider.isBpmAlert() ? 'Anormal' : 'Normal',
              icon: Icons.favorite,
              color: vitalsProvider.isBpmAlert()
                  ? Colors.red.shade800
                  : AppTheme.heartColor,
              onTap: () => _navigateToVitalDetail(VitalType.heartRate),
            ),
            VitalCard(
              title: 'SpO2',
              value: vitalsProvider.spo2?.displayValue ?? '--',
              unit: '%',
              status: vitalsProvider.isSpo2Alert() ? 'Bajo' : 'Normal',
              icon: Icons.air,
              color: vitalsProvider.isSpo2Alert()
                  ? Colors.red.shade800
                  : AppTheme.spo2Color,
              onTap: () => _navigateToVitalDetail(VitalType.spo2),
            ),
            VitalCard(
              title: 'Temperatura',
              value: vitalsProvider.temperature?.displayValue ?? '--',
              unit: '°C',
              status: vitalsProvider.isTempAlert() ? 'Alerta' : 'Normal',
              icon: Icons.thermostat,
              color: vitalsProvider.isTempAlert()
                  ? Colors.red.shade800
                  : Colors.orange,
              onTap: () => _navigateToVitalDetail(VitalType.temperature),
            ),
            VitalCard(
              title: 'Pasos',
              value: vitalsProvider.steps?.displayValue ?? '--',
              unit: 'pasos',
              status: 'Activo',
              icon: Icons.directions_walk,
              color: Colors.green,
              onTap: () => _navigateToVitalDetail(VitalType.steps),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones Rápidas', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.bluetooth_searching,
                label: 'Vincular Dispositivo',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DeviceScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  void _navigateToVitalDetail(VitalType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Cambia 'type: type' por el nombre correcto, por ejemplo 'vitalType: type'
        builder: (_) => VitalDetailScreen(vitalType: type),
      ),
    );
  }
}
