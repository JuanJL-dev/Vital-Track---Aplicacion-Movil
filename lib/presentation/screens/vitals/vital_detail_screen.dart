import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/vital_sign_model.dart';
import '../../widgets/animated_vital_icon.dart';
import '../../providers/vitals_provider.dart';

class VitalDetailScreen extends StatefulWidget {
  final VitalType vitalType;

  const VitalDetailScreen({super.key, required this.vitalType});

  @override
  State<VitalDetailScreen> createState() => _VitalDetailScreenState();
}

class _VitalDetailScreenState extends State<VitalDetailScreen> {
  String _selectedPeriod = 'Semana';
  final List<String> _periods = ['Día', 'Semana', 'Mes', 'Año'];
  List<VitalSign> _historicalData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final days = _selectedPeriod == 'Día'
        ? 1
        : _selectedPeriod == 'Semana'
        ? 7
        : _selectedPeriod == 'Mes'
        ? 30
        : 365;
    final provider = context.read<VitalsProvider>();
    setState(() {
      _historicalData = provider.getHistoricalData(widget.vitalType, days);
    });
  }

  String get _title {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return 'Frecuencia Cardíaca';
      case VitalType.bloodPressure:
        return 'Presión Arterial';
      case VitalType.spo2:
        return 'SpO2';
      case VitalType.sleep:
        return 'Sueño';
      case VitalType.exercise:
        return 'Ejercicio';
      case VitalType.steps:
        return 'Pasos';
    }
  }

  IconData get _icon {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return Icons.favorite;
      case VitalType.bloodPressure:
        return Icons.speed;
      case VitalType.spo2:
        return Icons.air;
      case VitalType.sleep:
        return Icons.bedtime;
      case VitalType.exercise:
        return Icons.directions_run;
      case VitalType.steps:
        return Icons.directions_walk;
    }
  }

  Color get _color {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return AppTheme.heartColor;
      case VitalType.bloodPressure:
        return AppTheme.bloodPressureColor;
      case VitalType.spo2:
        return AppTheme.spo2Color;
      case VitalType.sleep:
        return AppTheme.sleepColor;
      case VitalType.exercise:
        return AppTheme.exerciseColor;
      case VitalType.steps:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Consumer<VitalsProvider>(
        builder: (context, vitalsProvider, child) {
          final vital = _getCurrentVital(vitalsProvider);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCurrentValue(vitalsProvider, vital),
                const SizedBox(height: 24),
                _buildPeriodSelector(),
                const SizedBox(height: 16),
                _buildChart(),
                const SizedBox(height: 24),
                _buildReferenceRanges(),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<VitalsProvider>(
        builder: (context, vitalsProvider, child) {
          return _buildMeasureButton(vitalsProvider);
        },
      ),
    );
  }

  VitalSign? _getCurrentVital(VitalsProvider provider) {
    return provider.getCurrentVital(widget.vitalType);
  }

  Widget _buildCurrentValue(VitalsProvider provider, VitalSign? vital) {
    final isMeasuring = provider.isMeasuring;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          label:
              'Valor actual de ${_title}: ${vital?.displayValue ?? "sin datos"}',
          child: Column(
            children: [
              PulsingGlow(
                glowColor: _color,
                isActive: isMeasuring,
                child: AnimatedVitalIcon(
                  vitalType: widget.vitalType,
                  isAnimating: isMeasuring,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isMeasuring
                      ? 'Midiendo...'
                      : (vital?.getStatus() ?? 'Sin datos'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: _color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              selectedColor: _color,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  _loadData();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    if (_historicalData.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 200,
          child: Center(child: Text('No hay datos disponibles')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Semantics(
          label: 'Gráfica histórica de ${_title}',
          child: SizedBox(height: 250, child: LineChart(_createChartData())),
        ),
      ),
    );
  }

  LineChartData _createChartData() {
    final spots = _historicalData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final minY = _historicalData
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);
    final maxY = _historicalData
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppTheme.textSecondary.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY - padding,
      maxY: maxY + padding,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: _color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_color.withOpacity(0.3), _color.withOpacity(0.0)],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppTheme.surfaceColor,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < _historicalData.length) {
                final data = _historicalData[index];
                return LineTooltipItem(
                  data.displayValue,
                  TextStyle(color: _color, fontWeight: FontWeight.bold),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildReferenceRanges() {
    final ranges = _getReferenceRanges();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rangos de Referencia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...ranges.map(
              (range) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Semantics(
                  label: '${range['status']}: ${range['range']}',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(range['status']!),
                      Text(
                        range['range']!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getReferenceRanges() {
    switch (widget.vitalType) {
      case VitalType.heartRate:
        return [
          {'status': 'Bajo', 'range': '< 60 lpm'},
          {'status': 'Normal', 'range': '60 - 100 lpm'},
          {'status': 'Elevado', 'range': '> 100 lpm'},
        ];
      case VitalType.bloodPressure:
        return [
          {'status': 'Normal', 'range': '< 120/80 mmHg'},
          {'status': 'Prehipertensión', 'range': '120-139/80-89 mmHg'},
          {'status': 'Hipertensión Etapa 1', 'range': '140-159/90-99 mmHg'},
          {'status': 'Hipertensión Etapa 2', 'range': '≥ 160/100 mmHg'},
        ];
      case VitalType.spo2:
        return [
          {'status': 'Hipoxia Leve', 'range': '90 - 94 %'},
          {'status': 'Normal', 'range': '95 - 100 %'},
        ];
      case VitalType.sleep:
        return [
          {'status': 'Insuficiente', 'range': '< 6 horas'},
          {'status': 'Suficiente', 'range': '6 - 7 horas'},
          {'status': 'Óptimo', 'range': '7 - 9 horas'},
        ];
      case VitalType.exercise:
        return [
          {'status': 'Sedentario', 'range': '< 30 min'},
          {'status': 'Moderado', 'range': '30 - 60 min'},
          {'status': 'Activo', 'range': '> 60 min'},
        ];
      case VitalType.steps:
        return [
          {'status': 'Bajo', 'range': '< 5,000 pasos'},
          {'status': 'Normal', 'range': '5,000 - 10,000 pasos'},
          {'status': 'Activo', 'range': '> 10,000 pasos'},
        ];
    }
  }

  Widget _buildMeasureButton(VitalsProvider provider) {
    final isMeasuring = provider.isMeasuring;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Semantics(
          label: isMeasuring ? 'Midiendo signo vital' : 'Iniciar medición',
          button: true,
          enabled: !isMeasuring,
          child: ElevatedButton.icon(
            onPressed: isMeasuring
                ? null
                : () async {
                    await provider.startMeasurement(widget.vitalType);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _color,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isMeasuring
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.play_arrow, color: Colors.white),
            label: Text(
              isMeasuring ? 'Midiendo...' : 'Iniciar Medición',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
