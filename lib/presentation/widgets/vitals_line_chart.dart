// lib/presentation/widgets/vitals_line_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class VitalsLineChart extends StatelessWidget {
  final List<FlSpot> dataPoints;
  final Color lineColor;
  final String title;
  final double minY;
  final double maxY;
  final double minX;
  final double maxX;
  final String period;

  const VitalsLineChart({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    required this.title,
    required this.minY,
    required this.maxY,
    required this.minX,
    required this.maxX,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: minX,
          maxX: maxX,

          // --- CONFIGURACIÓN DEL TOOLTIP CORREGIDA ---
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // AQUÍ ESTÁ LA CORRECCIÓN: Usamos getTooltipColor en lugar de tooltipBgColor
              getTooltipColor: (touchedSpot) => lineColor.withOpacity(0.9),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((barSpot) {
                  // 1. Extraemos la hora exacta de los milisegundos del eje X
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    barSpot.x.toInt(),
                  );
                  final hourStr = date.hour.toString().padLeft(2, '0');

                  // 2. Creamos el texto del rango de hora
                  final timeRange = '$hourStr:00 - $hourStr:59';

                  // 3. Devolvemos el Tooltip con la hora arriba y el valor en negritas abajo
                  return LineTooltipItem(
                    '$timeRange\n',
                    const TextStyle(color: Colors.white70, fontSize: 12),
                    children: [
                      TextSpan(
                        text: barSpot.y.toString(), // Ya viene con 2 decimales
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),

          // --------------------------------------------------
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxX - minX) / 4,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('HH:mm').format(date),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              curveSmoothness: 0.3,
              preventCurveOverShooting: true,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withOpacity(0.2),
                    lineColor.withOpacity(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
