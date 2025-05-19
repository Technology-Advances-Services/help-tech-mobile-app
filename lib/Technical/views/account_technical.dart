import 'package:flutter/material.dart';

import '../../IAM/models/technical.dart';
import '../../IAM/services/profile_service.dart';
import '../../Location/models/specialty.dart';
import '../../Location/services/information_service.dart';

class AccountTechnical extends StatefulWidget {

  const AccountTechnical({super.key});

  @override
  _AccountTechnicalState createState() => _AccountTechnicalState();
}

class _AccountTechnicalState extends State<AccountTechnical> {

  final InformationService _informationService = InformationService();
  final ProfileService _profileService = ProfileService();

  List<Specialty> specialties = [];

  Technical? technical;

  bool isLoading = true;

  Future<void> loadProfile() async {

    final tmpSpecialties = await _informationService.getSpecialties();
    final profile = await _profileService.profileTechnical();

    setState(() {
      technical = profile;
      specialties = tmpSpecialties;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (technical == null) {
      return const Center(child: Text('No se pudo cargar el perfil.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(technical!.profileUrl)
          ),
          const SizedBox(height: 16),
          Text('${technical!.firstname} ${technical!.lastname}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 8),
          Text(technical!.email ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey
            )
          ),
          const SizedBox(height: 16),
          buildProfileCard(
              Icons.phone, 'Teléfono', technical!.phone.toString()),
          buildProfileCard(
              Icons.cake, 'Edad', '${technical!.age} años'),
          buildProfileCard(
              Icons.person, 'Género', technical!.genre),
          buildProfileCard(Icons.engineering, 'Especialidad',
            specialties.firstWhere((s) => s.id == technical!.specialtyId,
              orElse: () => Specialty(name: 'Desconocido')).name
          )
        ]
      )
    );
  }

  Widget buildProfileCard(IconData icon, String label, String? value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown),
        title: Text(label),
        subtitle: Text(value ?? 'No especificado')
      )
    );
  }
}