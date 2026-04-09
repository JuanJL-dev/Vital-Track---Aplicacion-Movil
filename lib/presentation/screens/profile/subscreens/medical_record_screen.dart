import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/repositories/patient_repository.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final PatientRepository _patientRepository = PatientRepository();
  Map<String, dynamic>? _medicalRecord;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicalRecord();
  }

  Future<void> _loadMedicalRecord() async {
    final authProvider = context.read<AuthProvider>();
    final pacienteId = authProvider.currentUser?.id;

    if (pacienteId != null) {
      final record = await _patientRepository.getMedicalRecord(pacienteId);
      setState(() {
        _medicalRecord = record?.toJson();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario del AuthProvider para los rangos configurados
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Expediente Médico')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medicalRecord == null
          ? _buildEmptyState()
          : _buildMedicalRecordContent(user), // Pasamos el usuario aquí
    );
  }

  Widget _buildMedicalRecordContent(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Información Personal'),
          _buildReadOnlyCard([
            _buildReadOnlyField(
              'Nombre',
              _medicalRecord?['nombre'] ?? 'No disponible',
            ),
            _buildReadOnlyField(
              'Apellido',
              _medicalRecord?['apellido'] ?? 'No disponible',
            ),
            _buildReadOnlyField(
              'Género',
              _medicalRecord?['genero'] ?? 'No especificado',
            ),
            _buildReadOnlyField(
              'Edad',
              _medicalRecord?['edad']?.toString() ?? 'No especificada',
            ),
            _buildReadOnlyField(
              'Domicilio',
              _medicalRecord?['domicilio'] ?? 'No registrado',
            ),
            _buildReadOnlyField(
              'Teléfono',
              _medicalRecord?['telefono'] ?? 'No registrado',
            ),
            _buildReadOnlyField(
              'Correo',
              _medicalRecord?['correo'] ?? 'No registrado',
            ),
          ]),

          const SizedBox(height: 24),

          // NUEVA SECCIÓN DE RANGOS CONFIGURADOS
          _buildSectionHeader('Rangos Configurados'),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildRangoItem(
                'Frec. Cardíaca',
                '${user?.bpmMin.toStringAsFixed(0)} - ${user?.bpmMax.toStringAsFixed(0)}',
                'bpm',
                Colors.red,
              ),
              _buildRangoItem(
                'Oxigenación Mín.',
                '> ${user?.spo2Min.toStringAsFixed(0)}%',
                'SpO2',
                Colors.blue,
              ),
              _buildRangoItem(
                'Temperatura',
                '${user?.tempMin.toStringAsFixed(1)}° - ${user?.tempMax.toStringAsFixed(1)}°',
                '°C',
                Colors.orange,
              ),
              _buildRangoItem(
                'Estado Sistema',
                'Activo',
                'Monitoreo',
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Estado de la Cuenta'),
          _buildReadOnlyCard([
            _buildReadOnlyField(
              'Estado',
              _medicalRecord?['status'] ?? 'Activo',
            ),
            _buildReadOnlyField(
              'Fecha de Registro',
              _formatDate(_medicalRecord?['created_at']),
            ),
          ]),

          const SizedBox(height: 24),
          _buildInfoBanner(),
        ],
      ),
    );
  }

  // Widget auxiliar para las tarjetas de rangos
  Widget _buildRangoItem(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // --- MÉTODOS DE APOYO EXISTENTES ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReadOnlyCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.lock_outline,
        size: 16,
        color: AppTheme.textDisabled,
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'El expediente médico es administrado por tu médico. Para modificarlo, contacta a tu proveedor.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No hay expediente médico disponible'));
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'No disponible';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'No disponible';
    }
  }
}
