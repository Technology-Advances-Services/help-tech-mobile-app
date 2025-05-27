import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../IAM/models/technical.dart';
import '../../IAM/services/profile_service.dart';
import '../../Location/models/specialty.dart';
import '../../Location/services/information_service.dart';
import '../../Subscription/models/contract.dart';
import '../../Subscription/services/contract_service.dart';

class AccountTechnical extends StatefulWidget {

  const AccountTechnical({super.key});

  @override
  _AccountTechnicalState createState() => _AccountTechnicalState();
}

class _AccountTechnicalState extends State<AccountTechnical> {

  final InformationService _informationService = InformationService();
  final ProfileService _profileService = ProfileService();
  final ContractService _contractService = ContractService();

  List<Specialty> specialties = [];

  Technical? technical;
  Contract? contract;

  bool isLoading = true;

  Future<void> loadProfile() async {

    final tmpSpecialties = await _informationService.getSpecialties();
    final profile = await _profileService.profileTechnical();
    final tmpContract = await _contractService.getContract();

    setState(() {
      specialties = tmpSpecialties;
      technical = profile;
      contract = tmpContract;
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
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (technical == null) {
      return const Center(
        child: Text(
          'No se pudo cargar el perfil.',
          style: TextStyle(
            color: Colors.white,        // Color blanco
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withOpacity(0.3), width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(technical!.profileUrl),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            '${technical!.firstname} ${technical!.lastname}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black45,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          Text(
            technical!.email ?? '',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),

          buildGlassCard(Icons.phone, 'Teléfono', technical!.phone.toString()),
          buildGlassCard(Icons.cake, 'Edad', '${technical!.age} años'),
          buildGlassCard(Icons.person, 'Género', technical!.genre),
          buildGlassCard(Icons.engineering, 'Especialidad',
            specialties.firstWhere((s) => s.id == technical!.specialtyId,
              orElse: () => Specialty(name: 'Desconocido')
            ).name
          ),
          buildGlassCard(Icons.card_membership, 'Membresía', contract!.name),
          buildGlassCard(Icons.attach_money, 'Precio', 'S/ ${contract!.price}'),
          buildGlassCard(Icons.description, 'Políticas', contract!.policies),
          buildGlassCard(Icons.date_range, 'Fecha Inicio',
            contract!.startDate != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(contract!.startDate!)
              : 'No asignado',
          ),
          buildGlassCard(Icons.date_range, 'Fecha Fin',
            contract!.finalDate != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(contract!.finalDate!)
              : 'No asignado',
          ),
        ],
      ),
    );
  }

  Widget buildGlassCard(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              leading: Icon(icon, color: Colors.tealAccent.shade400),
              title: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                value ?? 'No especificado',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}