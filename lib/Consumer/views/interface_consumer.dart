import 'package:flutter/material.dart';
import '../../Attention/components/job_request.dart';
import '../../Attention/services/job_service.dart';
import '../../IAM/models/technical.dart';
import '../../Location/models/department.dart';
import '../../Location/models/district.dart';
import '../../Location/models/specialty.dart';
import '../../Location/services/information_service.dart';
import '../../Shared/widgets/error_dialog.dart';
import '../../Shared/widgets/success_dialog.dart';
import '../../shared/widgets/base_layout.dart';

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
      final tmpDistricts = await _informationService.getDistrictsByDepartment(department.id);
      setState(() => districts = tmpDistricts);
    }
  }

  void onDistrictOrSpecialtyChanged() {

    setState(() {
      filteredTechnicals = allTechnicals.where((tech) {
        final matchesDistrict = tech.districtId == selectedDistrict!.id;
        final matchesSpecialty = tech.specialtyId == selectedSpecialty!.id;
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
      child: isLoading ?
      const Center(child: CircularProgressIndicator()) :
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [

            DropdownButtonFormField<Department>(
              decoration: const InputDecoration(labelText: 'Departamento'),
              value: selectedDepartment,
              items: departments.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name)
                );
              }).toList(),
              onChanged: onDepartmentSelected
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<District>(
              decoration: const InputDecoration(labelText: 'Distrito'),
              value: selectedDistrict,
              items: districts.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name)
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedDistrict = val);
                onDistrictOrSpecialtyChanged();
              }
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<Specialty>(
              decoration: const InputDecoration(labelText: 'Especialidad'),
              value: selectedSpecialty,
              items: specialties.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name)
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedSpecialty = val);
                onDistrictOrSpecialtyChanged();
              }
            ),
            const SizedBox(height: 20),

            Expanded(
              child: filteredTechnicals.isEmpty ?
              const Center(child: Text("No hay técnicos disponibles.")) :
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
                            technical: tech
                          )
                        )
                      );

                      if (result == true){

                        showDialog(context: context, builder: (context) =>
                        const SuccessDialog(message: 'Solicitud registrada.')
                        );
                      }
                      else {

                        showDialog(context: context, builder: (context) =>
                        const ErrorDialog(
                            message: 'No se registro su solicitud.')
                        );
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(tech.profileUrl),
                          child: const Icon(Icons.person)
                        ),
                        title: Text('${tech.firstname} ${tech.lastname}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Especialidad: ${selectedSpecialty?.name ??
                                "N/A"}'),
                            Text('Contacto: ${tech.phone}')
                          ]
                        ),
                        trailing: tech.availability == 'DISPONIBLE'
                            ? const Icon(Icons.circle,
                            color:Colors.green, size: 12)
                            : const Icon(Icons.circle,
                            color: Colors.red, size: 12)
                      )
                    )
                  );
                }
              )
            )
          ]
        )
      )
    );
  }
}