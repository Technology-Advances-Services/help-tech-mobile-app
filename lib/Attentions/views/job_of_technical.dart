import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/job_service.dart';
import '../models/job.dart';

class JobOfTechnical extends StatefulWidget {
  const JobOfTechnical({super.key});

  @override
  State<JobOfTechnical> createState() => _JobOfTechnicalState();
}

class _JobOfTechnicalState extends State<JobOfTechnical> {

  final JobService _jobService = JobService();
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'PENDIENTE';
  bool _isLoading = true;

  static const List<String> _statuses = [
    'TOTAL', 'PENDIENTE','COMPLETADO','EN PROCESO','DENEGADO'
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
      final matches = _selectedStatus == 'TOTAL'|| job.jobState == _selectedStatus;
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
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            children: [
              SizedBox(
                width: 180,
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Buscar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tabla
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _buildColumns(_selectedStatus),
                rows: _filteredJobs.map(_buildDataRow).toList(),
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
        //const DataColumn(label: Text('Dirección')),
        //const DataColumn(label: Text('Descripción')),
        //const DataColumn(label: Text('Tiempo')),
        //const DataColumn(label: Text('Presupuesto')),
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

  DataRow _buildDataRow(Job job) {

    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final cells = <DataCell>[
      DataCell(Text(job.id.toString())),
      DataCell(Text(fmt.format(job.registrationDate!))),
    ];

    if (job.jobState == 'PENDIENTE' || job.jobState == 'COMPLETADO') {
      cells.addAll([
        //DataCell(Text(job.address)),
        //DataCell(Text(job.description)),
        //DataCell(Text(job.time.toString())),
        //DataCell(Text(job.laborBudget.toStringAsFixed(2))),
        DataCell(Text(job.amountFinal!.toStringAsFixed(2))),
      ]);
    }

    cells.addAll([
      DataCell(Text(job.firstName)),
      DataCell(Text(job.lastName)),
      DataCell(Text(job.jobState)),
      DataCell(IconButton(
        icon: const Icon(Icons.info),
        tooltip: 'Detalle',
        onPressed: () => {

        }
      )),
      DataCell(IconButton(
        icon: const Icon(Icons.chat),
        tooltip: 'Chat',
        onPressed: () => {

        }
      )),
    ]);

    if (job.jobState == 'PENDIENTE') {

      cells.add(DataCell(IconButton(
        icon: const Icon(Icons.check_circle),
        tooltip: 'Completar',
        onPressed: () => {

        }
      )));
    } else if (job.jobState != 'COMPLETADO') {

      cells.add(DataCell(IconButton(
        icon: const Icon(Icons.reply),
        tooltip: 'Responder',
        onPressed: () => {

        }
      )));
    }

    return DataRow(cells: cells);
  }
}