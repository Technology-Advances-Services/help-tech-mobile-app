import 'package:flutter/material.dart';

import '../../Shared/widgets/base_layout.dart';
import '../../Statistic/services/statistic_service.dart';

class InterfaceTechnical extends StatefulWidget {

  const InterfaceTechnical({super.key});

  @override
  _InterfaceTechnicalState createState() => _InterfaceTechnicalState();
}

class _InterfaceTechnicalState extends State<InterfaceTechnical> {

  final StatisticService _statisticService = StatisticService();

  double totalIncome = 0;
  int totalConsumersServed = 0;
  double totalWorkTime = 0;
  int totalPendingsJobs = 0;

  Future<void> loadDashboard() async {

    var generalStatistic = await _statisticService.generalTechnicalStatistic();

    if (generalStatistic == null) {
      setState(() {
        totalIncome = 0;
        totalConsumersServed = 0;
        totalWorkTime = 0;
        totalPendingsJobs = 0;
      });
    }
    else {
      setState(() {
        totalIncome = generalStatistic.totalIncome;
        totalConsumersServed = generalStatistic.totalConsumersServed;
        totalWorkTime = generalStatistic.totalWorkTime;
        totalPendingsJobs = generalStatistic.totalPendingsJobs;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Estadístícas del mes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            )
          ),
          buildCard('Ingresos', '\$$totalIncome',
              Icons.attach_money, Colors.green),
          buildCard('Consumidores Atendidos', '$totalConsumersServed',
              Icons.person_outline, Colors.lightBlue),
          buildCard('Tiempo de Trabajo', '$totalWorkTime h',
              Icons.access_time, Colors.orange),
          buildCard('Trabajos Pendientes', '$totalPendingsJobs',
              Icons.assignment_late_outlined, Colors.redAccent)
        ]
      )
    );
  }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [

            Icon(icon, color: color, size: 40),
            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(title, style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),

                  Text(value, style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500))
                ]
              )
            )
          ]
        )
      )
    );
  }
}