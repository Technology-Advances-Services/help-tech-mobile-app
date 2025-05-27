import 'dart:ui';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Detalle del Trabajo'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFC25252),
              Color(0xFF944FA4),
              Color(0xFF602D98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Icon(Icons.description, size: 60,
                      color: Colors.tealAccent),
                    const SizedBox(height: 20),

                    infoRow(
                      'Fecha de trabajo',
                      widget.job.workDate != null
                        ? DateFormat('yyyy-MM-dd HH:mm')
                          .format(widget.job.workDate!)
                        : 'No asignado',
                      color: Colors.white,
                    ),
                    infoRow('Dirección', widget.job.address
                      ?? 'No asignado', color: Colors.white),
                    infoRow('Descripción', widget.job.description
                      ?? 'No asignado', color: Colors.white),
                    infoRow(
                      'Tiempo estimado',
                      widget.job.time.toString() != '0.0'
                        ? '${widget.job.time.toString()} horas' : 'No asignado',
                      color: Colors.white,
                    ),
                    infoRow(
                      'Mano de obra',
                      widget.job.laborBudget != 0
                        ? 'S/ ${widget.job.laborBudget!.toStringAsFixed(2)}'
                        : 'No asignado',
                      color: Colors.white,
                    ),
                    infoRow(
                      'Materiales',
                      widget.job.materialBudget != 0
                        ? 'S/ ${widget.job.materialBudget!.toStringAsFixed(2)}'
                        : 'No asignado',
                      color: Colors.white,
                    ),
                    infoRow(
                      'Monto final',
                      widget.job.amountFinal != 0
                        ? 'S/ ${widget.job.amountFinal!.toStringAsFixed(2)}'
                        : 'No asignado',
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Regresar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets
                          .symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Colors.tealAccent.shade200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$title:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color ?? Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: color ?? Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}