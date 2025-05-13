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

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = false;

  Future<void> submitRequest() async {

    if (_addressController.text.isEmpty || _descriptionController.text.isEmpty) {

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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Solicitar Servicio Técnico'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(widget.technical.profileUrl)
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Usted escogió el servicio de:\n${widget.specialtyName}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)
                  )
                )
              ]
            ),
            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Información general', style: TextStyle(
                            fontWeight: FontWeight.bold))
                      ]
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileTechnical(
                                  specialtyName: widget.specialtyName,
                                  technical: widget.technical
                                )
                              )
                            );
                          },
                          icon: const Icon(Icons.person),
                          label: const Text("Ver Perfil"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange)
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewOfTechnical(
                                  technical: widget.technical
                                )
                              )
                            );
                          },
                          icon: const Icon(Icons.reviews),
                          label: const Text("Ver Reseñas"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue)
                        )
                      ]
                    )
                  ]
                )
              )
            ),
            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    const Row(
                      children: [
                        Icon(Icons.build_circle_outlined, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Solicitar servicio', style: TextStyle(
                            fontWeight: FontWeight.bold))
                      ]
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Domicilio',
                        border: OutlineInputBorder()
                      )
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder()
                      )
                    )
                  ]
                )
              )
            ),
            const SizedBox(height: 24),

            isLoading ? const CircularProgressIndicator() :
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                child: const Text(
                  'Solicitar Servicio Técnico',
                  style: TextStyle(fontSize: 16, color: Colors.white)
                )
              )
            )
          ]
        )
      )
    );
  }
}