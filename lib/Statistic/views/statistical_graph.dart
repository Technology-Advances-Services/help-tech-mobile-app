import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/statistic_service.dart';
import '../models/review_statistic.dart';

class StatisticalGraph extends StatefulWidget {
  const StatisticalGraph({super.key});

  @override
  _StatisticalGraph createState() => _StatisticalGraph();
}

class _StatisticalGraph extends State<StatisticalGraph> {

  final StatisticService _statisticService = StatisticService();

  String selectedType = 'TOTAL';

  dynamic statistic;

  List<ReviewStatistic> reviews = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGraph();
  }

  Future<void> _loadGraph() async {

    setState(() => isLoading = true);

    if (selectedType == 'RESEÑAS') {
      reviews = await _statisticService.reviewStatistic();
      statistic = null;
    }
    else {
      statistic = await _statisticService.detailedTechnicalStatistic(selectedType);
      reviews.clear();
    }

    setState(() => isLoading = false);
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['TOTAL', 'MENSUAL', 'RESEÑAS'].map((type) {

        final isSelected = selectedType == type;

        return ElevatedButton(
          onPressed: () {
            if (selectedType != type) {
              setState(() => selectedType = type);
              _loadGraph();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.teal : Colors.grey.shade300,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(type),
        );
      }).toList(),
    );
  }

  List<BarChartGroupData> _buildBarData() {

    if (selectedType == 'RESEÑAS' && reviews.isNotEmpty) {

      final review = reviews.first;

      return review.scores.entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
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
    }
    else if (statistic != null) {
      return [
        BarChartGroupData(x: 0, barRods: [
          BarChartRodData(toY: statistic!.totalIncome.toDouble(), color: Colors.green, width: 18)
        ]),
        BarChartGroupData(x: 1, barRods: [
          BarChartRodData(toY: statistic!.totalConsumersServed.toDouble(), color: Colors.blue, width: 18)
        ]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(toY: statistic!.totalWorkTime.toDouble(), color: Colors.orange, width: 18)
        ]),
        BarChartGroupData(x: 3, barRods: [
          BarChartRodData(toY: statistic!.totalPendingsJobs.toDouble(), color: Colors.red, width: 18)
        ]),
      ];
    }
    else {
      return [];
    }
  }

  List<String> _buildLabels() {

    if (selectedType == 'RESEÑAS') {
      return ['1', '2', '3', '4', '5', 'Promedio'];
    } else {
      return ['Ingresos', 'Clientes', 'Horas', 'Pendientes'];
    }
  }

  Widget _buildChart() {

    final barGroups = _buildBarData();
    final labels = _buildLabels();

    return AspectRatio(
      aspectRatio: 1.2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _calculateMaxY(barGroups),
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    return Text(
                      index < labels.length ? labels[index] : '',
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

  double _calculateMaxY(List<BarChartGroupData> groups) {

    double max = 0;

    for (var group in groups) {
      for (var rod in group.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }
    return (max * 1.2).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const Text(
            'Estadísticas Técnicas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildButtons(),
          const SizedBox(height: 20),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }
}