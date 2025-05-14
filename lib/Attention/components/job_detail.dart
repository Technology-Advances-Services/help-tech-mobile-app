import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/job.dart';

class JobDetail extends StatefulWidget {

  final Job job;

  const JobDetail({super.key, required this.job});

  @override
  _JobDetailState createState() => _JobDetailState();
}

class _JobDetailState extends State<JobDetail> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Trabajo'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 4
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8B782), Color(0xFFAD745D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          )
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description, size: 60, color: Colors.indigo),
                  const SizedBox(height: 20),

                  infoRow(
                    'Fecha de trabajo',
                    widget.job.workDate != null
                        ? DateFormat('yyyy-MM-dd HH:mm')
                        .format(widget.job.workDate!)
                        : 'No disponible',
                  ),
                  infoRow('Dirección', widget.job.address ??
                      'No disponible'),
                  infoRow('Descripción', widget.job.description ??
                      'No disponible'),
                  infoRow('Tiempo estimado', widget.job.time.toString() != '0.0' ?
                    '${widget.job.time.toString()} horas' : 'No asignado'),
                  infoRow(
                    'Mano de obra', widget.job.laborBudget != 0 ?
                    'S/ ${widget.job.laborBudget!
                        .toStringAsFixed(2)}' : 'No asignado',
                  ),
                  infoRow(
                    'Materiales',
                    widget.job.materialBudget != 0 ?
                    'S/ ${widget.job.materialBudget!
                        .toStringAsFixed(2)}' : 'No asignado',
                  ),
                  infoRow(
                    'Monto final',
                    widget.job.amountFinal != 0 ? 'S/ ${widget.job.amountFinal!
                        .toStringAsFixed(2)}' : 'No asignado',
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))
                    )
                  )
                ]
              )
            )
          )
        )
      )
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            )
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: const TextStyle(fontSize: 16))
          )
        ]
      )
    );
  }
}