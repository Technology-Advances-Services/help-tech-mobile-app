import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/job.dart';
import '../services/job_service.dart';

class JobResponse extends StatefulWidget {

  final int jobId;

  const JobResponse({super.key, required this.jobId});

  @override
  _JobResponseState createState() => _JobResponseState();
}

class _JobResponseState extends State<JobResponse> {

  final _formKey = GlobalKey<FormState>();
  final JobService _jobService = JobService();

  DateTime? workDate;
  final _timeController = TextEditingController();
  final _laborBudgetController = TextEditingController();
  final _materialBudgetController = TextEditingController();
  String? selectedStatus;

  bool isLoading = false;

  Future<void> submitRequest() async {

    if (!_formKey.currentState!.validate() || workDate == null ||
        _timeController.text.isEmpty || _laborBudgetController.text.isEmpty ||
        _materialBudgetController.text.isEmpty || selectedStatus == null) {

      Navigator.of(context).pop(false);
    }

    setState(() => isLoading = true);

    final Job job = Job(
      id: widget.jobId,
      workDate: workDate,
      time: double.tryParse(_timeController.text) ?? 0.0,
      laborBudget: double.tryParse(_laborBudgetController.text) ?? 0.0,
      materialBudget: double.tryParse(_materialBudgetController.text) ?? 0.0,
      jobState: selectedStatus!,
    );

    final result = await _jobService.assignJobDetail(job);

    setState(() => isLoading = false);

    Navigator.of(context).pop(result);
  }

  Future<void> pickDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: workDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(workDate ?? now),
    );

    if (pickedTime == null) return;

    final fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      workDate = fullDateTime;
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    _laborBudgetController.dispose();
    _materialBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder al trabajo'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8B782), Color(0xFFAD745D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          )
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.work, size: 60, color: Colors.brown),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha de trabajo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)
                            )
                          ),
                          child: Text(workDate != null
                                ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(workDate!) : 'Seleccionar fecha',
                            style: TextStyle(
                              color: workDate != null ?
                              Colors.black87 : Colors.grey
                            )
                          )
                        )
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Tiempo estimado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ?
                        'Este campo es requerido' : null
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _laborBudgetController,
                        keyboardType: const TextInputType
                            .numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Presupuesto Mano de Obra',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ?
                        'Este campo es requerido' : null
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _materialBudgetController,
                        keyboardType: const TextInputType
                            .numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Presupuesto Materiales',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Este campo es requerido' : null
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        items: const [
                          DropdownMenuItem(value: 'PENDIENTE',
                              child: Text('PENDIENTE')),
                          DropdownMenuItem(value: 'DENEGADO',
                              child: Text('DENEGADO'))
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                        validator: (value) =>
                        value == null || value.isEmpty ?
                        'Seleccione un estado' : null
                      ),
                      const SizedBox(height: 16),

                      isLoading ? const CircularProgressIndicator() :
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: submitRequest,
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar respuesta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          )
                        )
                      )
                    ]
                  )
                )
              )
            )
          )
        )
      )
    );
  }
}