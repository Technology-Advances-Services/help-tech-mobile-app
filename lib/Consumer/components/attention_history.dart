import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

import '../../Attention/models/job.dart';
import '../../Attention/services/job_service.dart';

class AttentionHistory extends StatefulWidget {

  const AttentionHistory({super.key});

  @override
  _AttentionHistoryState createState() => _AttentionHistoryState();
}

class _AttentionHistoryState extends State<AttentionHistory> {

  final JobService _jobService = JobService();

  List<Job> allJobs = [];
  List<Job> filteredJobs = [];
  bool isLoading = true;

  Future<void> loadJobs() async {

    setState(() => isLoading = true);

    allJobs = await _jobService.jobsByConsumer();
    filteredJobs = allJobs.where((job) {
      return job.jobState == 'COMPLETADO';
    }).toList();

    setState(() => isLoading = false);
  }

  Future<pw.Document> buildJobHistoryPdf(List<Job> jobs) async {

    final pdf = pw.Document();

    final currencyFormatter = NumberFormat.currency(locale: 'es_PE', symbol: 'S/');

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.openSansRegular(),
            bold: await PdfGoogleFonts.openSansBold(),
          ),
        ),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Historial de Trabajos',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.deepPurple800,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            tableWidth: pw.TableWidth.max,
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration
                  (color: PdfColors.deepPurple100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Descripción',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Material',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Mano de obra',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Monto Final',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ), ...
              jobs.map((job) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(job.description),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(currencyFormatter.format(job.materialBudget ?? 0)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(currencyFormatter.format(job.laborBudget ?? 0)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(currencyFormatter.format(job.amountFinal ?? 0)),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  Future<void> savePdfToDownloads
      (pw.Document pdf, String fileName, BuildContext context) async {

    final status = await Permission.storage.request();

    if (!status.isGranted) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de almacenamiento denegado')),
      );

      return;
    }

    try {

      final directory = Directory('/storage/emulated/0/Download');
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en: $filePath')),
      );
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el PDF: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Historial de Atenciones'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {

              if (isLoading || filteredJobs.isEmpty) return;

              final pdf = await buildJobHistoryPdf(filteredJobs);

              await savePdfToDownloads(pdf, 'Historial_Trabajos.pdf', context);
            },
          )
        ],
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
        child: isLoading ?
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ) :
        filteredJobs.isEmpty ?
        const Center(
          child: Text(
            'No hay trabajos completados.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ) :
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 32),
          child: Column(
            children: filteredJobs.map((job) {
              return GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      job.description,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    infoRow('Precio Mano de Obra:',
                        'S/ ${job.laborBudget?.toStringAsFixed(2) ?? '0.00'}'),

                    infoRow('Precio Materiales:',
                        'S/ ${job.materialBudget?.toStringAsFixed(2)
                          ?? '0.00'}'),

                    infoRow('Monto Final:',
                        'S/ ${job.amountFinal?.toStringAsFixed(2) ?? '0.00'}'),

                    if (job.workDate != null)
                      infoRow('Fecha Trabajo:', DateFormat
                        ('yyyy-MM-dd – kk:mm').format(job.workDate!)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {

  final Widget child;

  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}