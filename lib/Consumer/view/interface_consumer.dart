import 'package:flutter/material.dart';
import '../../Attention/services/job_service.dart';
import '../../IAM/models/technical.dart';
import '../../Location/models/department.dart';
import '../../Location/models/district.dart';
import '../../Location/models/specialty.dart';
import '../../Location/services/information_service.dart';
import '../../shared/widgets/base_layout.dart';

class InterfaceConsumer extends StatefulWidget {
  const InterfaceConsumer({super.key});

  @override
  _InterfaceConsumer createState() => _InterfaceConsumer();
}

class _InterfaceConsumer extends State<InterfaceConsumer> {
  final InformationService _informationService = InformationService();
  final JobService _jobService = JobService();

  List<Department> _departments = [];
  List<District> _districts = [];
  List<Specialty> _specialties = [];

  Department? _selectedDepartment;
  District? _selectedDistrict;
  Specialty? _selectedSpecialty;

  List<Technical> _allTechnicals = [];
  List<Technical> _filteredTechnicals = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {

    final departments = await _informationService.getDepartments();
    final specialties = await _informationService.getSpecialties();
    final technicals = await _jobService.technicalsByAvailability();

    setState(() {
      _departments = departments;
      _specialties = specialties;
      _allTechnicals = technicals;
      _isLoading = false;
    });
  }

  Future<void> _onDepartmentSelected(Department? department) async {

    setState(() {
      _selectedDepartment = department;
      _selectedDistrict = null;
      _districts = [];
    });

    if (department != null) {
      final districts = await _informationService.getDistrictsByDepartment(department.id);
      setState(() => _districts = districts);
    }
  }

  void _onDistrictOrSpecialtyChanged() {

    setState(() {
      _filteredTechnicals = _allTechnicals.where((tech) {
        final matchesDistrict = _selectedDistrict == null || tech.districtId == _selectedDistrict!.id;
        final matchesSpecialty = _selectedSpecialty == null || tech.specialtyId == _selectedSpecialty!.id;
        return matchesDistrict && matchesSpecialty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [

            DropdownButtonFormField<Department>(
              decoration: const InputDecoration(labelText: 'Departamento'),
              value: _selectedDepartment,
              items: _departments.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: _onDepartmentSelected,
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<District>(
              decoration: const InputDecoration(labelText: 'Distrito'),
              value: _selectedDistrict,
              items: _districts.map((d) {
                return DropdownMenuItem(
                  value: d,
                  child: Text(d.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedDistrict = val);
                _onDistrictOrSpecialtyChanged();
              },
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<Specialty>(
              decoration: const InputDecoration(labelText: 'Especialidad'),
              value: _selectedSpecialty,
              items: _specialties.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedSpecialty = val);
                _onDistrictOrSpecialtyChanged();
              },
            ),
            const SizedBox(height: 20),

            Expanded(
              child: _filteredTechnicals.isEmpty
                  ? const Center(child: Text("No hay técnicos disponibles."))
                  : ListView.builder(
                itemCount: _filteredTechnicals.length,
                itemBuilder: (context, index) {
                  final tech = _filteredTechnicals[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(tech.profileUrl),
                        child:const Icon(Icons.person),
                      ),
                      title: Text('${tech.firstname} ${tech.lastname}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Especialidad: ${_selectedSpecialty?.name ?? "N/A"}'),
                          Text('Contacto: ${tech.phone}'),
                        ],
                      ),
                      trailing: tech.availability == 'DISPONIBLE'
                          ? const Icon(Icons.circle, color: Colors.green, size: 12)
                          : const Icon(Icons.circle, color: Colors.red, size: 12),
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