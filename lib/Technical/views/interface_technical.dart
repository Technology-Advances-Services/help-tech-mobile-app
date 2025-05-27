import 'dart:ui';

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
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Estadísticas del mes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          GlassStatCard(
            title: 'Ingresos',
            value: '\$$totalIncome',
            icon: Icons.attach_money,
            color: Colors.greenAccent,
          ),
          GlassStatCard(
            title: 'Consumidores Atendidos',
            value: '$totalConsumersServed',
            icon: Icons.person_outline,
            color: Colors.lightBlueAccent,
          ),
          GlassStatCard(
            title: 'Tiempo de Trabajo',
            value: '$totalWorkTime h',
            icon: Icons.access_time,
            color: Colors.orangeAccent,
          ),
          GlassStatCard(
            title: 'Trabajos Pendientes',
            value: '$totalPendingsJobs',
            icon: Icons.assignment_late_outlined,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class GlassStatCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const GlassStatCard({super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.25), width: 1.5
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(value, style:
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}