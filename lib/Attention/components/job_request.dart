import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Attention/components/review_of_technical.dart';

import '../../Consumer/components/profile_technical.dart';
import '../../IAM/models/technical.dart';
import '../models/job.dart';
import '../services/job_service.dart';

class JobRequest extends StatefulWidget {

  final String specialtyName;
  final Technical technical;

  const JobRequest({
    super.key,
    required this.specialtyName,
    required this.technical,
  });

  @override
  _JobRequestState createState() => _JobRequestState();
}

class _JobRequestState extends State<JobRequest> {

  final JobService _jobService = JobService();

  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> submitRequest() async {

    if (_addressController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      Navigator.of(context).pop(false);
    }

    setState(() => isLoading = true);

    final Job job = Job(
      agendaId: await _jobService.getAgendaId(widget.technical.id),
      address: _addressController.text,
      description: _descriptionController.text,
    );

    final result = await _jobService.registerRequestJob(job);

    setState(() => isLoading = false);

    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Solicitar Servicio Técnico'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(widget.technical.profileUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Usted escogió el servicio de:\n${widget.specialtyName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Información general',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        roundedButton(
                          color: Colors.orange,
                          icon: Icons.person,
                          label: "Ver Perfil",
                          onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => ProfileTechnical(
                                  specialtyName: widget.specialtyName,
                                  technical: widget.technical,
                                ),
                              ),
                            );
                          },
                        ),
                        roundedButton(
                          color: Colors.blue,
                          icon: Icons.reviews,
                          label: "Ver Reseñas",
                          onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => ReviewOfTechnical(
                                  technical: widget.technical,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.build_circle_outlined, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Solicitar servicio',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    glassInput(
                      controller: _addressController,
                      label: 'Domicilio',
                    ),
                    const SizedBox(height: 16),
                    glassInput(
                      controller: _descriptionController,
                      label: 'Descripción',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              isLoading ? const CircularProgressIndicator(color: Colors.white) :
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: submitRequest,
                  icon: const Icon(Icons.send),
                  label: const Text('Solicitar Servicio Técnico'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget glassInput({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget roundedButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 4,
        shadowColor: Colors.tealAccent.shade200,
      ),
    );
  }
}