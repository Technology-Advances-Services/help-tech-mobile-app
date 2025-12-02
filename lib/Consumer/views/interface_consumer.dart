import 'dart:ui';

import 'package:flutter/material.dart';

import '../../Attention/components/job_request.dart';
import '../../Attention/services/job_service.dart';
import '../../IAM/models/technical.dart';
import '../../Location/models/department.dart';
import '../../Location/models/district.dart';
import '../../Location/models/specialty.dart';
import '../../Location/services/information_service.dart';
import '../../Shared/widgets/base_layout.dart';
import '../../Shared/widgets/error_dialog.dart';
import '../../Shared/widgets/success_dialog.dart';
import '../services/chatbot_service.dart';

class InterfaceConsumer extends StatefulWidget {

  const InterfaceConsumer({super.key});

  @override
  _InterfaceConsumerState createState() => _InterfaceConsumerState();
}

class _InterfaceConsumerState extends State<InterfaceConsumer> {

  final InformationService _informationService = InformationService();
  final JobService _jobService = JobService();
  final ChatBotService _chatBotService = ChatBotService();

  final TextEditingController _chatController = TextEditingController();

  List<Department> departments = [];
  List<District> districts = [];
  List<Specialty> specialties = [];

  Department? selectedDepartment;
  District? selectedDistrict;
  Specialty? selectedSpecialty;

  List<Technical> allTechnicals = [];
  List<Technical> filteredTechnicals = [];
  List<Technical> filteredTechnicalsML = [];

  bool sending = false;
  bool isLoading = true;

  Future<void> loadInitialData() async {

    final tmpDepartments = await _informationService.getDepartments();
    final tmpSpecialties = await _informationService.getSpecialties();
    final tmpTechnicals = await _jobService.technicalsByAvailability();

    setState(() {
      departments = tmpDepartments;
      specialties = tmpSpecialties;
      allTechnicals = tmpTechnicals;
      isLoading = false;
    });
  }

  Future<void> onDepartmentSelected(Department? department) async {

    setState(() {
      selectedDepartment = department;
      selectedDistrict = null;
      districts = [];
    });

    if (department != null) {
      final tmpDistricts = await _informationService
        .getDistrictsByDepartment(department.id);
      setState(() => districts = tmpDistricts);
    }
  }

  void onDistrictOrSpecialtyChanged() {
    setState(() {

      filteredTechnicalsML.clear();

      filteredTechnicals = allTechnicals.where((tech) {
        final matchesDistrict = selectedDistrict != null &&
          tech.districtId == selectedDistrict!.id;
        final matchesSpecialty = selectedSpecialty != null &&
          tech.specialtyId == selectedSpecialty!.id;
        return matchesDistrict && matchesSpecialty;
      }).toList();
    });
  }

  void filterTechnicalsByResponseML(int specialtyId) {
    setState(() {

      filteredTechnicals.clear();

      filteredTechnicalsML = allTechnicals.where((tech) {
        return tech.specialtyId == specialtyId;
      }).toList();
    });
  }

  void openChatbotModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.55,
            maxChildSize: 0.90,
            minChildSize: 0.40,
            expand: false,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Scaffold(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    resizeToAvoidBottomInset: true,
                    body: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.smart_toy_rounded,
                                  color: Colors.tealAccent, size: 36),
                              SizedBox(width: 10),
                              Text(
                                "Asistente IA",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),

                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: const Text(
                                "Hola 👋, soy tu asistente inteligente.\n"
                                    "Describe tu problema y te recomendaré un técnico.",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) async {
                                      await handleSendFromModal(context);
                                    },
                                    decoration: const InputDecoration(
                                      hintText: "Describe tu problema...",
                                      hintStyle: TextStyle(color: Colors.white54),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),

                                sending
                                    ? const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.tealAccent,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                    : IconButton(
                                  icon: const Icon(Icons.send,
                                      color: Colors.tealAccent),
                                  onPressed: () async {
                                    await handleSendFromModal(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> handleSendFromModal(BuildContext context) async {

    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() => sending = true);

    try {

      final int specialtyId = (await _chatBotService
          .getMachineLearningResponse(text)) as int;

      if (specialtyId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se obtuvo una recomendación válida.')),
        );
      } else {
        filterTechnicalsByResponseML(specialtyId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Técnicos filtrados según la recomendación.')),
        );

        Navigator.pop(context);
        _chatController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al consultar la IA: $e')),
      );
    } finally {
      setState(() => sending = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: isLoading ? const Center(child: CircularProgressIndicator
        (color: Colors.white)) :
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            DropdownButtonFormField<Department>(
              value: selectedDepartment,
              dropdownColor: Colors.deepPurple.shade200.withOpacity(0.9),
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Departamento',
                labelStyle: TextStyle(color: Colors.white),
              ),
              items: departments.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: onDepartmentSelected,
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<District>(
              value: selectedDistrict,
              dropdownColor: Colors.deepPurple.shade200.withOpacity(0.9),
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Distrito',
                labelStyle: TextStyle(color: Colors.white),
              ),
              items: districts.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedDistrict = val);
                onDistrictOrSpecialtyChanged();
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<Specialty>(
              value: selectedSpecialty,
              dropdownColor: Colors.deepPurple.shade200.withOpacity(0.9),
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Especialidad',
                labelStyle: TextStyle(color: Colors.white),
              ),
              items: specialties.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedSpecialty = val);
                onDistrictOrSpecialtyChanged();
              },
            ),
            const SizedBox(height: 20),

            Expanded(
              child: (filteredTechnicalsML.isNotEmpty
                  ? filteredTechnicalsML
                  : filteredTechnicals).isEmpty ?
              const Center(
                child: Text(
                  'No hay técnicos disponibles.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ) :
              ListView.builder(
                itemCount: (filteredTechnicalsML.isNotEmpty
                  ? filteredTechnicalsML
                  : filteredTechnicals).length,
                itemBuilder: (context, index) {
                  final tech = (filteredTechnicalsML.isNotEmpty
                      ? filteredTechnicalsML : filteredTechnicals)[index];
                  return InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobRequest(
                            specialtyName: selectedSpecialty?.name ?? '',
                            technical: tech,
                          ),
                        ),
                      );

                      showDialog(context: context,
                        builder: (context) => result == true
                          ? const SuccessDialog
                            (message: 'Solicitud registrada.')
                          : const ErrorDialog
                            (message: 'No se registró su solicitud.'),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric
                            (horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2)
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(tech.profileUrl),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(
                              '${tech.firstname} ${tech.lastname}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Especialidad: '
                                  '${selectedSpecialty?.name ?? "N/A"}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Contacto: ${tech.phone}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.circle,
                              color: tech.availability == 'DISPONIBLE'
                                ? Colors.green
                                : Colors.red,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.white,
                elevation: 6,
                child: const Icon(Icons.smart_toy_rounded),
                onPressed: () => openChatbotModal(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}