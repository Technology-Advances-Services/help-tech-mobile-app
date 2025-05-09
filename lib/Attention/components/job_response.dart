import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Attention/services/job_service.dart';
import 'package:helptechmobileapp/Shared/widgets/error_dialog.dart';
import 'package:helptechmobileapp/Shared/widgets/success_dialog.dart';
import 'package:intl/intl.dart';

import '../models/job.dart';

class JobResponse extends StatefulWidget {

  final int jobId;

  const JobResponse({super.key, required this.jobId});

  @override
  _JobResponse createState() => _JobResponse();
}

class _JobResponse extends State<JobResponse> {

  final _formKey = GlobalKey<FormState>();

  final JobService _jobService = JobService();

  DateTime? _workDate;
  final _timeController = TextEditingController();
  final _laborBudgetController = TextEditingController();
  final _materialBudgetController = TextEditingController();
  String? _selectedStatus;

  Future<void> _pickDate() async {

    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _workDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _workDate = picked);
    }
  }

  Future<void> _submit() async {

    if (_formKey.currentState!.validate() &&
        _workDate != null && _selectedStatus != null) {

      final Job job = Job(
        id: widget.jobId,
        workDate: _workDate,
        time: double.tryParse(_timeController.text) ?? 0.0,
        laborBudget: double.tryParse(_laborBudgetController.text) ?? 0.0,
        jobState: _selectedStatus!
      );

      var result = await _jobService.assignJobDetail(job);

      if (result == true){

        showDialog(
          context: context,
          builder: (context) =>
          const SuccessDialog(message: 'Respuesta registrada.')
        );

        Navigator.of(context).pop(true);
      }
      else {

        showDialog(
          context: context,
          builder: (context) =>
          const ErrorDialog(message: 'No se registro su respuesta.')
        );
      }
    }
    else if (_workDate == null && _selectedStatus == null) {

      showDialog(
        context: context,
        builder: (context) =>
        const ErrorDialog(message: 'Campos vacios.')
      );
    }

    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder al trabajo'),
        backgroundColor: Colors.brown
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8B782), Color(0xFFAD745D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child:
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Icon(Icons.work, size: 60, color: Colors.brown),
                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha de trabajo',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _workDate != null
                                ? DateFormat('dd/MM/yyyy').format(_workDate!)
                                : 'Seleccionar fecha',
                            style: TextStyle(
                              color: _workDate != null ? Colors.black87 : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Tiempo estimado',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Este campo es requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _laborBudgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Presupuesto Mano de Obra',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Este campo es requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _materialBudgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Presupuesto Materiales',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Este campo es requerido' : null,
                      ),
                      const SizedBox(height: 24),

                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'PENDIENTE', child: Text('PENDIENTE')),
                          DropdownMenuItem(value: 'DENEGADO', child: Text('DENEGADO')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Seleccione un estado' : null,
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.send),
                          label: const Text('Enviar respuesta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FB6B3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}