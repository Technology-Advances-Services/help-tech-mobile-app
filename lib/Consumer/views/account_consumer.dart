import 'package:flutter/material.dart';

import '../../IAM/models/consumer.dart';
import '../../IAM/services/profile_service.dart';

class AccountConsumer extends StatefulWidget {

  const AccountConsumer({super.key});

  @override
  _AccountConsumerState createState() => _AccountConsumerState();
}

class _AccountConsumerState extends State<AccountConsumer> {

  final ProfileService _profileService = ProfileService();

  Consumer? consumer;

  bool isLoading = true;

  Future<void> loadProfile() async {

    final profile = await _profileService.profileConsumer();

    setState(() {
      consumer = profile;
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

    if (consumer == null) {
      return const Center(child: Text('No se pudo cargar el perfil.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(consumer!.profileUrl)
          ),
          const SizedBox(height: 16),
          Text('${consumer!.firstname} ${consumer!.lastname}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 8),
          Text(consumer!.email ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey
            )
          ),
          const SizedBox(height: 16),
          buildProfileCard(
            Icons.phone, 'Teléfono', consumer!.phone.toString()),
          buildProfileCard(
            Icons.cake, 'Edad', '${consumer!.age} años'),
          buildProfileCard(
            Icons.person, 'Género', consumer!.genre)
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