import 'dart:ui';

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

  final _descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> submitComplaint() async {

    if (selectedType == null || _descriptionController.text.isEmpty) {

      Navigator.of(context).pop(false);

      return;
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
    return Stack(
      children: [
        Container(
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
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Registrar Queja'),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: isLoading ? const Center(child: CircularProgressIndicator()) :
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white30),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        DropdownButtonFormField<TypeComplaint>(
                          value: selectedType,
                          isExpanded: true,
                          dropdownColor: Colors.deepPurple.shade200
                            .withOpacity(0.9),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Tipo de queja',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric
                              (horizontal: 12, vertical: 14),
                          ),
                          items: typeComplaints.map((type) {
                            return DropdownMenuItem<TypeComplaint>(
                              value: type,
                              child: Text(
                                type.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                            setState(() => selectedType = value),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Describe tu queja...',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide
                                (color: Colors.white.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La queja es obligatoria.';
                            }
                            return null;
                          },
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
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                Colors.white
                              ),
                            ),
                          ) :
                          const Text('Enviar Queja'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent.shade700,
                            foregroundColor: Colors.white,
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.tealAccent.shade200,
                            elevation: 10,
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
      ],
    );
  }
}