import 'dart:ui';

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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Perfil del Técnico'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.technical.profileUrl.isNotEmpty
                        ? NetworkImage(widget.technical.profileUrl)
                        : const AssetImage
                        ('assets/images/default_avatar.png') as ImageProvider,
                    ),
                    const SizedBox(height: 16),

                    Text(
                      '${widget.technical.firstname} '
                      '${widget.technical.lastname}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    Text(
                      widget.specialtyName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),

                    GlassCard(
                      color: Colors.white.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.symmetric
                          (vertical: 16, horizontal: 10),
                        child: Column(
                          children: [
                            buildProfileRow(Icons.badge, 'DNI',
                              widget.technical.id),
                            buildProfileRow(Icons.cake, 'Edad',
                              widget.technical.age.toString()),
                            buildProfileRow(Icons.wc, 'Género',
                              widget.technical.genre),
                            buildProfileRow(Icons.phone, 'Teléfono',
                              widget.technical.phone.toString()),
                            buildProfileRow(Icons.email, 'Correo',
                              widget.technical.email),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const GlassCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}