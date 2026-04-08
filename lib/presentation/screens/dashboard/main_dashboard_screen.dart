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

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // INYECTAR EL ID DEL PACIENTE PARA SUPABASE
      final authProvider = context.read<AuthProvider>();
      final vitalsProvider = context.read<VitalsProvider>();
      
      if (authProvider.currentUser != null) {
        vitalsProvider.setPatientId(authProvider.currentUser!.id);
      }
      vitalsProvider.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeviceScreen()));
            },
            tooltip: 'Conectar dispositivo',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Educación'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildDashboard();
      case 1: return const ProfileScreen();
      case 2: return const EducationScreen();
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<VitalsProvider>().refreshData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceStatus(),
            const SizedBox(height: 24),
            Text('Signos Vitales', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildVitalsGrid(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatus() {
    return Consumer<DeviceProvider>(
      builder: (context, deviceProvider, child) {
        final isConnected = deviceProvider.isConnected;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isConnected ? Icons.watch : Icons.watch_off,
                  color: isConnected ? AppTheme.successColor : AppTheme.textDisabled,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? deviceProvider.connectedDevice?.name ?? 'Dispositivo' : 'Sin dispositivo vinculado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        isConnected ? 'Conectado' : 'Toca para conectar',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isConnected)
                  Text(
                    '${deviceProvider.connectedDevice?.batteryLevel ?? 0}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.successColor),
                  ),
              ],
            ),
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
          childAspectRatio: 0.75, // <-- ARREGLO DE UX: Tarjetas más altas
          children: [
            VitalCard(
              title: 'Frecuencia Cardíaca',
              value: vitalsProvider.heartRate?.value.toStringAsFixed(0) ?? '--',
              unit: 'lpm',
              status: vitalsProvider.heartRate?.getStatus() ?? '',
              icon: Icons.favorite,
              color: AppTheme.heartColor,
              onTap: () => _navigateToVitalDetail(VitalType.heartRate),
            ),
            VitalCard(
              title: 'Presión Arterial',
              value: vitalsProvider.bloodPressure?.displayValue ?? '--/--',
              unit: 'mmHg',
              status: vitalsProvider.bloodPressure?.getStatus() ?? '',
              icon: Icons.speed,
              color: AppTheme.bloodPressureColor,
              onTap: () => _navigateToVitalDetail(VitalType.bloodPressure),
            ),
            VitalCard(
              title: 'SpO2',
              value: vitalsProvider.spo2?.value.toStringAsFixed(0) ?? '--',
              unit: '%',
              status: vitalsProvider.spo2?.getStatus() ?? '',
              icon: Icons.air,
              color: AppTheme.spo2Color,
              onTap: () => _navigateToVitalDetail(VitalType.spo2),
            ),
            VitalCard(
              title: 'Sueño',
              value: vitalsProvider.sleep?.value.toStringAsFixed(1) ?? '--',
              unit: 'hrs',
              status: vitalsProvider.sleep?.getStatus() ?? '',
              icon: Icons.bedtime,
              color: AppTheme.sleepColor,
              onTap: () => _navigateToVitalDetail(VitalType.sleep),
            ),
            VitalCard(
              title: 'Ejercicio',
              value: vitalsProvider.exercise?.value.toStringAsFixed(0) ?? '--',
              unit: 'min',
              status: vitalsProvider.exercise?.getStatus() ?? '',
              icon: Icons.directions_run,
              color: AppTheme.exerciseColor,
              onTap: () => _navigateToVitalDetail(VitalType.exercise),
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
                icon: Icons.refresh,
                label: 'Actualizar',
                onTap: () {
                  context.read<VitalsProvider>().refreshData();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                icon: Icons.bluetooth_searching,
                label: 'Vincular',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeviceScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), const SizedBox(width: 8), Text(label)],
      ),
    );
  }

  void _navigateToVitalDetail(VitalType type) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => VitalDetailScreen(vitalType: type)));
  }
}