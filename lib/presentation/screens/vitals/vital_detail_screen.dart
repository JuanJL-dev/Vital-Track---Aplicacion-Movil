import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vital_sign_model.dart';
import '../../widgets/animated_vital_icon.dart';
import '../../widgets/vitals_line_chart.dart';
import '../../providers/vitals_provider.dart';
import '../../providers/auth_provider.dart';

class VitalDetailScreen extends StatefulWidget {
  final VitalType vitalType;

  const VitalDetailScreen({super.key, required this.vitalType});

  @override
  State<VitalDetailScreen> createState() => _VitalDetailScreenState();
}

class _VitalDetailScreenState extends State<VitalDetailScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VitalsProvider>().fetchHistoricalData(widget.vitalType, 30);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _color,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  // Filtra por el día exacto, agrupa por hora y aplica reglas de decimales
  List<FlSpot> _getCleanSpots(List<VitalSign> data) {
    if (data.isEmpty) return [];

    Map<int, List<double>> hourlyData = {};

    for (var v in data) {
      final localTime = v.timestamp.toLocal();
      if (localTime.year == _selectedDate.year &&
          localTime.month == _selectedDate.month &&
          localTime.day == _selectedDate.day) {
        int hourKey = localTime.hour;
        hourlyData.putIfAbsent(hourKey, () => []).add(v.value.toDouble());
      }
    }

    List<FlSpot> spots = [];
    hourlyData.forEach((hour, values) {
      double rawAverage = values.reduce((a, b) => a + b) / values.length;

      double finalValue;
      // AQUÍ ESTÁ LA MAGIA: Excepción para la temperatura
      if (widget.vitalType == VitalType.temperature) {
        // Redondeamos a 1 decimal (ej. 37.4)
        finalValue = double.parse(rawAverage.toStringAsFixed(1));
      } else {
        // Forzamos entero para todo lo demás (ej. 85.0 -> se ve como 85)
        finalValue = rawAverage.roundToDouble();
      }

      final timeContext = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
      );

      spots.add(
        FlSpot(timeContext.millisecondsSinceEpoch.toDouble(), finalValue),
      );
    });

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  String get _title {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return 'Frecuencia Cardíaca';
      case VitalType.spo2:
        return 'SpO2';
      case VitalType.temperature:
        return 'Temperatura';
      case VitalType.exercise:
        return 'Ejercicio';
      case VitalType.steps:
        return 'Pasos';
    }
  }

  Color get _color {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return AppTheme.heartColor;
      case VitalType.spo2:
        return AppTheme.spo2Color;
      case VitalType.temperature:
        return Colors.orange;
      case VitalType.exercise:
        return AppTheme.exerciseColor;
      case VitalType.steps:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<VitalsProvider>(
        builder: (context, vitalsProvider, child) {
          final vital = vitalsProvider.getCurrentVital(widget.vitalType);
          final historicalData = vitalsProvider.getHistoryForType(
            widget.vitalType,
          );
          final isLoading = vitalsProvider.isLoadingHistory;

          final spots = _getCleanSpots(historicalData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCurrentValue(vital),
                const SizedBox(height: 24),

                _buildDateHeader(),
                const SizedBox(height: 16),

                if (isLoading)
                  const Card(
                    child: SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else
                  _buildChart(spots),

                const SizedBox(height: 24),
                _buildReferenceRanges(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentValue(VitalSign? vital) {
    final hasData = vital != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            PulsingGlow(
              glowColor: _color,
              isActive: hasData,
              child: AnimatedVitalIcon(
                vitalType: widget.vitalType,
                isAnimating: hasData,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vital?.displayValue ?? '--',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: _color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              vital?.unit ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hasData ? 'Monitoreando en tiempo real' : 'Esperando datos...',
                style: TextStyle(color: _color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    String formattedDate = DateFormat(
      'EEEE, d MMMM',
      'es',
    ).format(_selectedDate);
    formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, color: _color),
            onPressed: () => _selectDate(context),
            tooltip: 'Seleccionar fecha',
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return const Card(
        color: Color(0xFF1A1A1A),
        child: SizedBox(
          height: 250,
          child: Center(
            child: Text(
              'Sin datos registrados para este día',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    // Calculamos los límites dinámicos en base a los datos reales
    double currentMinY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double currentMaxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    double padding = (currentMaxY - currentMinY) * 0.15;
    if (padding == 0)
      padding = widget.vitalType == VitalType.temperature ? 1.0 : 5.0;

    double finalMinY = (currentMinY - padding).floorToDouble();
    double finalMaxY = (currentMaxY + padding).ceilToDouble();

    // Reglas de protección para la UI
    if (widget.vitalType == VitalType.spo2 && finalMaxY > 100) finalMaxY = 100;
    if (finalMinY < 0 && widget.vitalType != VitalType.temperature)
      finalMinY = 0;

    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return VitalsLineChart(
      title: 'Lecturas del día',
      lineColor: _color,
      minY: finalMinY,
      maxY: finalMaxY,
      minX: startOfDay.millisecondsSinceEpoch.toDouble(),
      maxX: endOfDay.millisecondsSinceEpoch.toDouble(),
      period: 'Día',
      dataPoints: spots,
    );
  }

  Widget _buildReferenceRanges() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    double minLimit = 0;
    double maxLimit = 0;
    String unit = '';

    switch (widget.vitalType) {
      case VitalType.heartRate:
        minLimit = (user?.bpmMin ?? 60).toDouble();
        maxLimit = (user?.bpmMax ?? 100).toDouble();
        unit = 'lpm';
        break;
      case VitalType.spo2:
        minLimit = (user?.spo2Min ?? 95).toDouble();
        maxLimit = 100.0;
        unit = '%';
        break;
      case VitalType.temperature:
        minLimit = (user?.tempMin ?? 36.0).toDouble();
        maxLimit = (user?.tempMax ?? 37.5).toDouble();
        unit = '°C';
        break;
      default:
        break;
    }

    List<Map<String, String>> ranges = [
      if (widget.vitalType != VitalType.spo2 &&
          widget.vitalType != VitalType.steps &&
          widget.vitalType != VitalType.exercise)
        {
          'status': 'Bajo (Alerta)',
          'range': '< ${minLimit.toStringAsFixed(1)} $unit',
        },
      if (widget.vitalType != VitalType.steps &&
          widget.vitalType != VitalType.exercise)
        {
          'status': 'Normal (Tu perfil)',
          'range':
              '${minLimit.toStringAsFixed(1)} - ${maxLimit.toStringAsFixed(1)} $unit',
        },
      if (widget.vitalType != VitalType.steps &&
          widget.vitalType != VitalType.exercise)
        {
          'status': 'Elevado (Alerta)',
          'range': '> ${maxLimit.toStringAsFixed(1)} $unit',
        },
    ];

    if (ranges.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tus Rangos de Referencia',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ranges.map(
              (range) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      range['status']!,
                      style: TextStyle(
                        color: range['status']!.contains('Alerta')
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      range['range']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
