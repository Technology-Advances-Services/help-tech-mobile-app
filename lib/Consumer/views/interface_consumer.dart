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

class InterfaceConsumer extends StatefulWidget {

  const InterfaceConsumer({super.key});

  @override
  _InterfaceConsumerState createState() => _InterfaceConsumerState();
}

class _InterfaceConsumerState extends State<InterfaceConsumer> {

  final InformationService _informationService = InformationService();
  final JobService _jobService = JobService();

  List<Department> departments = [];
  List<District> districts = [];
  List<Specialty> specialties = [];

  Department? selectedDepartment;
  District? selectedDistrict;
  Specialty? selectedSpecialty;

  List<Technical> allTechnicals = [];
  List<Technical> filteredTechnicals = [];

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
      filteredTechnicals = allTechnicals.where((tech) {
        final matchesDistrict = selectedDistrict != null &&
          tech.districtId == selectedDistrict!.id;
        final matchesSpecialty = selectedSpecialty != null &&
          tech.specialtyId == selectedSpecialty!.id;
        return matchesDistrict && matchesSpecialty;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
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

            Expanded(child: filteredTechnicals.isEmpty ?
              const Center(child: Text(
                'No hay técnicos disponibles.',
                  style: TextStyle(
                    color: Colors.white,        // Color blanco
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ) :
              ListView.builder(
                itemCount: filteredTechnicals.length,
                itemBuilder: (context, index) {
                  final tech = filteredTechnicals[index];
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
          ],
        ),
      ),
    );
  }
}