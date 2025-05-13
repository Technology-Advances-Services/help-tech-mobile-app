import 'package:flutter/material.dart';

import '../models/complaint.dart';
import '../models/type_complaint.dart';
import '../services/complaint_service.dart';
import '../services/type_complaint_service.dart';

class RegisterComplaint extends StatefulWidget {

  final int jobId;

  const RegisterComplaint({super.key, required this.jobId});

  @override
  _RegisterComplaintState createState() => _RegisterComplaintState();
}

class _RegisterComplaintState extends State<RegisterComplaint> {

  final TypeComplaintService _typeComplaintService = TypeComplaintService();
  final ComplaintService _complaintService = ComplaintService();

  List<TypeComplaint> typeComplaints = [];
  TypeComplaint? selectedType;

  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> submitComplaint() async {

    if (selectedType == null || _descriptionController.text.isEmpty) {

      Navigator.of(context).pop(false);
    }

    setState(() {
      isLoading = true;
    });

    final complaint = Complaint(
      typeComplaintId: selectedType!.id,
      jobId: widget.jobId,
      description: _descriptionController.text,
    );

    final result = await _complaintService.registerComplaint(complaint);

    setState(() {
      isLoading = false;
    });

    Navigator.of(context).pop(result);
  }

  Future<void> loadTypeComplaints() async {

    setState(() {
      isLoading = true;
    });

    final tmpTypeComplaints = await _typeComplaintService.getTypeComplaints();

    setState(() {
      typeComplaints = tmpTypeComplaints;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadTypeComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Queja'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) :
      Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Text(
                  'Tipo de Queja',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownButtonFormField<TypeComplaint>(
                      value: selectedType,
                      items: typeComplaints.map((type) {
                        return DropdownMenuItem<TypeComplaint>(
                          value: type,
                          child: Text(
                            type.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1
                          )
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedType = value),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10)
                      ),
                      isExpanded: true
                    );
                  }
                ),
                const SizedBox(height: 20),

                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe tu queja...',
                    border: OutlineInputBorder()
                  )
                ),
                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: isLoading ? null : submitComplaint,
                  icon: const Icon(Icons.report),
                  label: isLoading ?
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                    )
                  ) :
                  const Text('Enviar Queja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}