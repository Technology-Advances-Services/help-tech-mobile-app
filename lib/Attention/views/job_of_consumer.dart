import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Interaction/services/chat_member_service.dart';
import '../../Interaction/views/chat_page.dart';
import '../../Report/components/register_complaint.dart';
import '../../Shared/widgets/error_dialog.dart';
import '../../Shared/widgets/success_dialog.dart';
import '../components/add_review.dart';
import '../components/job_detail.dart';
import '../models/job.dart';
import '../services/job_service.dart';

class JobOfConsumer extends StatefulWidget {

  const JobOfConsumer({super.key});

  @override
  _JobOfConsumerState createState() => _JobOfConsumerState();
}

class _JobOfConsumerState extends State<JobOfConsumer> {

  final JobService _jobService = JobService();

  List<Job> allJobs = [];
  List<Job> filteredJobs = [];
  DateTime selectedDate = DateTime.now();
  String selectedStatus = 'COMPLETADO';
  bool isLoading = true;

  static const List<String> _statuses = [
    'PENDIENTE','COMPLETADO','EN PROCESO','DENEGADO'
  ];

  Future<void> loadJobs() async {

    setState(() => isLoading = true);

    allJobs = await _jobService.jobsByConsumer();
    filteredJobs = allJobs.where((job) {
      return job.jobState == selectedStatus;
    }).toList();

    setState(() => isLoading = false);
  }

  Future<void> pickDate() async {

    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365))
    );

    if (d != null) {
      setState(() {
        selectedDate = d;
        applyFilters();
      });
    }
  }

  void applyFilters() {

    final df = DateFormat('yyyy-MM-dd');

    filteredJobs = allJobs.where((job) {

      final matches = job.jobState == selectedStatus;

      if (!matches) return false;

      if (selectedStatus == 'PENDIENTE' || selectedStatus == 'COMPLETADO') {

        if (job.workDate == null) return false;

        return df.format(job.workDate!) == df.format(selectedDate);
      }
      else {

        if (job.registrationDate == null) return false;

        return df.format(job.registrationDate!) == df.format(selectedDate);
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 200,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    dropdownColor: Colors.deepPurple.shade200
                      .withOpacity(0.9),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      labelStyle: const TextStyle(color: Colors.white),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide
                          (color: Colors.blue.shade400, width: 2),
                      ),
                    ),
                    items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                    onChanged: (v) => setState(() {
                      selectedStatus = v!;
                      applyFilters();
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (filteredJobs.isEmpty)
            const Center(
              child: Text(
                'No hay trabajos en esta fecha.',
                style: TextStyle(
                  color: Colors.white,        // Color blanco
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            PaginatedDataTable(
              header: const Text(
                'Tabla de trabajo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              columns: buildColumns(selectedStatus),
              source: JobDataSource(filteredJobs, context),
              rowsPerPage: 6,
              columnSpacing: 24,
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => Colors.blue.shade50),
            ),
        ],
      ),
    );
  }

  List<DataColumn> buildColumns(String state) {

    final cols = <DataColumn>[
      const DataColumn(label: Text('ID')),
      const DataColumn(label: Text('Emisión'))
    ];

    if (state == 'PENDIENTE' || state == 'COMPLETADO') {

      cols.addAll([
        const DataColumn(label: Text('Final'))
      ]);
    }

    cols.addAll([
      const DataColumn(label: Text('Nombre')),
      const DataColumn(label: Text('Apellido')),
      const DataColumn(label: Text('Estado')),
      const DataColumn(label: Text('Detalle')),
      const DataColumn(label: Text('Chat'))
    ]);

    if (state == 'COMPLETADO') {
      cols.add(const DataColumn(label: Text('Calificar')));
      cols.add(const DataColumn(label: Text('Queja')));
    }

    return cols;
  }
}

class JobDataSource extends DataTableSource {

  final ChatMemberService _chatMemberService = ChatMemberService();

  final List<Job> _jobs;
  final BuildContext context;

  final DateFormat _fmt = DateFormat('dd/MM/yyyy HH:mm');

  JobDataSource(this._jobs, this.context);

  @override
  DataRow getRow(int index) {

    final job = _jobs[index];

    final List<DataCell> cells = [
      DataCell(Text(job.id.toString())),
      DataCell(Text(_fmt.format(job.registrationDate!)))
    ];

    if (job.jobState == 'PENDIENTE' || job.jobState == 'COMPLETADO') {
      cells.add(DataCell(Text(job.amountFinal!.toStringAsFixed(2))));
    }

    cells.addAll([
      DataCell(Text(job.firstName)),
      DataCell(Text(job.lastName)),
      DataCell(Text(job.jobState)),
      DataCell(IconButton(
        icon: const Icon(Icons.info, color: Colors.blue),
        tooltip: 'Detalle',
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
              JobDetail(job: job)
            )
          );
        }
      )),
      DataCell(IconButton(
        icon: const Icon(Icons.chat, color: Colors.green),
        tooltip: 'Chat',
        onPressed: () async {

          final chatMember = await _chatMemberService
            .chatsMembersByConsumer(job.personId);

          Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
              ChatPage(chatMember: chatMember!, role: 'CONSUMIDOR')
            )
          );
        }
      ))
    ]);

    if (job.jobState == 'COMPLETADO') {
      cells.add(DataCell(IconButton(
        icon: const Icon(Icons.star, color: Colors.yellow),
        tooltip: 'Calificar',
        onPressed: () async {

          final result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
              AddReview(technicalId: job.personId))
          );

          if (result == true) {

            showDialog(context: context, builder: (context) =>
            const SuccessDialog(message: 'Reseña registrada.'));
          }
          else {

            showDialog(context: context, builder: (context) =>
            const ErrorDialog(message: 'No se registró la reseña.'));
          }
        }
      )));
      cells.add(DataCell(IconButton(
        icon: const Icon(Icons.warning, color: Colors.red),
        tooltip: 'Queja',
        onPressed: () async {

          var result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
              RegisterComplaint(jobId: job.id))
          );

          if (result == true) {

            showDialog(context: context, builder: (context) =>
            const SuccessDialog(message: 'Queja registrada.'));
          }
          else {

            showDialog(context: context, builder: (context) =>
            const ErrorDialog(message: 'No se registró la queja.'));
          }
        }
      )));
    }

    return DataRow.byIndex(index: index, cells: cells);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _jobs.length;

  @override
  int get selectedRowCount => 0;
}