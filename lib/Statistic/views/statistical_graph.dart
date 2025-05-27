import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/review_statistic.dart';
import '../services/statistic_service.dart';

class StatisticalGraph extends StatefulWidget {

  const StatisticalGraph({super.key});

  @override
  _StatisticalGraphState createState() => _StatisticalGraphState();
}

class _StatisticalGraphState extends State<StatisticalGraph> {

  final StatisticService _statisticService = StatisticService();

  dynamic statistic;

  String selectedType = 'TOTAL';

  List<ReviewStatistic> reviews = [];

  bool isLoading = true;

  Future<void> loadGraph() async {

    setState(() => isLoading = true);

    if (selectedType == 'RESEÑAS') {
      reviews = await _statisticService.reviewStatistic();
      statistic = null;
    }
    else {
      statistic = await _statisticService
        .detailedTechnicalStatistic(selectedType);
      reviews.clear();
    }

    setState(() => isLoading = false);
  }

  List<BarChartGroupData> buildBarData() {

    if (selectedType == 'RESEÑAS' && reviews.isNotEmpty) {

      final review = reviews.first;

      final barGroups = review.scores.entries.map((entry) {
        return BarChartGroupData(
          x: entry.key - 1,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: Colors.teal,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }).toList();

      final maxX = barGroups.isNotEmpty
        ? barGroups.map((b) => b.x).reduce((a, b) => a > b ? a : b)
        : 5;

      barGroups.add(
        BarChartGroupData(
          x: maxX + 1, barRods: [
            BarChartRodData(
              toY: review.averageScore.toDouble(),
              color: Colors.grey,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );

      return barGroups;
    }
    else if (statistic != null) {
      return [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: statistic!.totalIncome.toDouble(),
              color: Colors.green,
              width: 18,
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: statistic!.totalConsumersServed.toDouble(),
              color: Colors.blue,
              width: 18,
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: statistic!.totalWorkTime.toDouble(),
              color: Colors.orange,
              width: 18,
            ),
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              toY: statistic!.totalPendingsJobs.toDouble(),
              color: Colors.red,
              width: 18,
            ),
          ],
        ),
      ];
    }

    return [];
  }

  List<String> buildLabels() {

    if (selectedType == 'RESEÑAS') {
      return ['1', '2', '3', '4', '5', 'Promedio'];
    }

    return ['Ingresos', 'Clientes', 'Horas', 'Pendientes'];
  }

  double calculateMaxY(List<BarChartGroupData> groups) {

    double max = 0;

    for (var group in groups) {
      for (var rod in group.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }

    return (max * 1.2).ceilToDouble();
  }

  @override
  void initState() {
    super.initState();
    loadGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2), width: 1.5
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            height: 450,
            child: isLoading ? const Center(child: CircularProgressIndicator
              (color: Colors.white)) :
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Estadísticas Técnicas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.85),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                buildButtons(),
                const SizedBox(height: 30),

                Expanded(child: buildChart()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['TOTAL', 'MENSUAL', 'RESEÑAS'].map((type) {

          final isSelected = selectedType == type;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                  ? Colors.tealAccent.shade400
                  : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.teal.shade400 : Colors.white24,
                  width: 1.2,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedType != type) {
                    setState(() => selectedType = type);
                    loadGraph();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: isSelected
                    ? Colors.black87 : Colors.white70,
                  padding: const EdgeInsets.symmetric
                    (horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildChart() {

    final barGroups = buildBarData();
    final labels = buildLabels();

    return AspectRatio(
      aspectRatio: 1.2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: calculateMaxY(barGroups),
            barTouchData: BarTouchData(enabled: true),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.black,
                  strokeWidth: 0.8,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: Colors.black,
                  strokeWidth: 0.8,
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    return Text(
                      index < labels.length ? labels[index] : '',
                      style: const TextStyle
                        (color: Colors.white70, fontSize: 12),
                    );
                  }
                ),
              ),
              rightTitles: const AxisTitles
                (sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles
                (sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }
}