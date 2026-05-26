import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/pesagem_model.dart';
import '../app_colors.dart';

class WeightLineChart extends StatelessWidget {
  final List<PesagemModel> data;

  const WeightLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma leitura registrada ainda.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final spots = data.reversed.toList().asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.pesoKg);
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 6,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white12, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              FlLine(color: Colors.white12, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white24),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '${value.toStringAsFixed(1)} kg',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 2,
            dotData: FlDotData(show: spots.length <= 20),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueAccent.withValues(alpha: 0.1),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 5.0,
              color: AppColors.sobrepeso,
              strokeWidth: 1.5,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (_) => 'Limite',
                style: TextStyle(color: AppColors.sobrepeso, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
