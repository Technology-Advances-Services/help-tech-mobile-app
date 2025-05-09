import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobResponse extends StatefulWidget {

  final int jobId;

  const JobResponse({super.key, required this.jobId});

  @override
  _JobResponse createState() => _JobResponse();
}

class _JobResponse extends State<JobResponse> {

  final _formKey = GlobalKey<FormState>();

  DateTime? _workDate;
  final _timeController = TextEditingController();
  final _laborBudgetController = TextEditingController();
  final _materialBudgetController = TextEditingController();

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

  void _submit() {

    if (_formKey.currentState!.validate() && _workDate != null) {

      final responseData = {
        'jobId': widget.jobId,
        'workDate': _workDate,
        'time': _timeController.text.trim(),
        'laborBudget': double.tryParse(_laborBudgetController.text.trim()) ?? 0.0,
        'materialBudget': double.tryParse(_materialBudgetController.text.trim()) ?? 0.0,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuesta registrada con éxito')),
      );

      Navigator.pop(context);
    } else if (_workDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha de trabajo')),
      );
    }
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