import 'dart:ui';

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

    if (!_formKey.currentState!.validate() ||
        workDate == null ||
        _timeController.text.isEmpty ||
        _laborBudgetController.text.isEmpty ||
        _materialBudgetController.text.isEmpty ||
        selectedStatus == null) {

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Responder al trabajo'),
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
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
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
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Icon(Icons.work, size: 60,
                          color: Colors.tealAccent),
                        const SizedBox(height: 20),

                        InkWell(
                          onTap: pickDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de trabajo',
                              labelStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide
                                  (color: Colors.white54),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              workDate != null
                                ? DateFormat('dd/MM/yyyy HH:mm')
                                .format(workDate!)
                                : 'Seleccionar fecha',
                              style: TextStyle(
                                color: workDate != null
                                  ? Colors.white
                                  : Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        buildTextField(
                          controller: _timeController,
                          label: 'Tiempo estimado',
                        ),

                        buildTextField(
                          controller: _laborBudgetController,
                          label: 'Presupuesto Mano de Obra',
                          isNumeric: true,
                        ),

                        buildTextField(
                          controller: _materialBudgetController,
                          label: 'Presupuesto Materiales',
                          isNumeric: true,
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          dropdownColor: Colors.deepPurple.shade200
                            .withOpacity(0.9),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Estado',
                            labelStyle: const TextStyle(color: Colors.white),
                            fillColor: Colors.white.withOpacity(0.15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide
                                (color: Colors.white54),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'PENDIENTE',
                              child: Text('PENDIENTE')),
                            DropdownMenuItem(value: 'DENEGADO',
                              child: Text('DENEGADO')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                          validator: (value) =>
                          value == null || value.isEmpty
                            ? 'Seleccione un estado' : null,
                        ),
                        const SizedBox(height: 24),

                        isLoading ?
                        const CircularProgressIndicator(color: Colors.white) :
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: submitRequest,
                            icon: const Icon(Icons.send),
                            label: const Text('Enviar respuesta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 6,
                              shadowColor: Colors.tealAccent.shade200,
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
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white54),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(color: Colors.white),
        validator: (value) => value == null || value.isEmpty
          ? 'Este campo es requerido'
          : null,
      ),
    );
  }
}