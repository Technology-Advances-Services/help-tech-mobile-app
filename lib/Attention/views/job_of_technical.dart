import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Attention/components/job_detail.dart';
import 'package:intl/intl.dart';
import '../components/job_response.dart';
import '../services/job_service.dart';
import '../models/job.dart';

class JobOfTechnical extends StatefulWidget {

  const JobOfTechnical({super.key});

  @override
  _JobOfTechnical createState() => _JobOfTechnical();
}

class _JobOfTechnical extends State<JobOfTechnical> {

  final JobService _jobService = JobService();

  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'PENDIENTE';
  bool _isLoading = true;

  static const List<String> _statuses = [
    'PENDIENTE','COMPLETADO','EN PROCESO','DENEGADO'
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {

    setState(() => _isLoading = true);
    _allJobs = await _jobService.jobsByTechnical();
    _applyFilters();
    setState(() => _isLoading = false);
  }

  void _applyFilters() {

    final df = DateFormat('yyyy-MM-dd');

    _filteredJobs = _allJobs.where((job) {
      final sameDate = df.format(job.registrationDate!) == df.format(_selectedDate);
      final matches = job.jobState == _selectedStatus;
      return sameDate && matches;
    }).toList();
  }

  Future<void> _pickDate() async {

    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (d != null) {
      setState(() {
        _selectedDate = d;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: _statuses.map((s) =>
                        DropdownMenuItem(value: s, child: Text(s))
                    ).toList(),
                    onChanged: (v) => setState(() {
                      _selectedStatus = v!;
                      _applyFilters();
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                ? const Center(child: Text('No hay trabajos en esta fecha.'))
                :
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredJobs.isEmpty
                  ? const Center(child: Text('No hay trabajos en esta fecha.'))
                  : PaginatedDataTable(
                header: const Text(
                  'Tabla de trabajo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                columns: _buildColumns(_selectedStatus),
                source: JobDataSource(_filteredJobs, context),
                rowsPerPage: 6,
                columnSpacing: 24,
                headingRowColor: WidgetStateColor.resolveWith(
                        (states) => Colors.blue.shade50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(String state) {

    final cols = <DataColumn>[
      const DataColumn(label: Text('ID')),
      const DataColumn(label: Text('Emisión')),
    ];

    if (state == 'PENDIENTE' || state == 'COMPLETADO') {

      cols.addAll([
        const DataColumn(label: Text('Final')),
      ]);
    }

    cols.addAll([
      const DataColumn(label: Text('Nombre')),
      const DataColumn(label: Text('Apellido')),
      const DataColumn(label: Text('Estado')),
      const DataColumn(label: Text('Detalle')),
      const DataColumn(label: Text('Chat')),
    ]);

    if (state == 'PENDIENTE') {
      cols.add(const DataColumn(label: Text('Completar')));
    } else if (state != 'COMPLETADO') {
      cols.add(const DataColumn(label: Text('Responder')));
    }

    return cols;
  }
}

class JobDataSource extends DataTableSource {

  final List<Job> _jobs;
  final BuildContext context;
  final DateFormat _fmt = DateFormat('dd/MM/yyyy HH:mm');

  JobDataSource(this._jobs, this.context);

  @override
  DataRow getRow(int index) {

    final job = _jobs[index];

    final List<DataCell> cells = [
      DataCell(Text(job.id.toString())),
      DataCell(Text(_fmt.format(job.registrationDate!))),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetail(job: job)),
          );
        },
      )),
      DataCell(IconButton(
        icon: const Icon(Icons.chat, color: Colors.green),
        tooltip: 'Chat',
        onPressed: () {},
      )),
    ]);

    if (job.jobState == 'PENDIENTE') {
      cells.add(DataCell(IconButton(
        icon: const Icon(Icons.check_circle, color: Colors.orange),
        tooltip: 'Completar',
        onPressed: () {},
      )));
    }
    else if (job.jobState != 'COMPLETADO') {
      cells.add(DataCell(IconButton(
        icon: const Icon(Icons.reply, color: Colors.deepPurple),
        tooltip: 'Responder',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobResponse(jobId: job.id),
            ),
          );
        },
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