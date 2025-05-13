import 'package:flutter/material.dart';

import '../../IAM/models/technical.dart';

class ProfileTechnical extends StatefulWidget {

  final String specialtyName;
  final Technical technical;

  const ProfileTechnical({
    super.key,
    required this.specialtyName,
    required this.technical,
  });

  @override
  _ProfileTechnicalState createState() => _ProfileTechnicalState();
}

class _ProfileTechnicalState extends State<ProfileTechnical> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Técnico'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            CircleAvatar(
              radius: 60,
              backgroundImage: widget.technical.profileUrl.isNotEmpty
                  ? NetworkImage(widget.technical.profileUrl)
                  : const AssetImage('assets/images/default_avatar.png')
              as ImageProvider
            ),
            const SizedBox(height: 16),

            Text(
              '${widget.technical.firstname} ${widget.technical.lastname}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )
            ),
            Text(
              widget.specialtyName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600
              )
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  children: [
                    buildProfileRow(Icons.badge, 'DNI', widget.technical.id),
                    buildProfileRow(Icons.cake, 'Edad', widget.technical.age.toString()),
                    buildProfileRow(Icons.wc, 'Género', widget.technical.genre),
                    buildProfileRow(Icons.phone, 'Teléfono', widget.technical.phone.toString()),
                    buildProfileRow(Icons.email, 'Correo', widget.technical.email)
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }

  Widget buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              )
            )
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey.shade700)
            )
          )
        ]
      )
    );
  }
}