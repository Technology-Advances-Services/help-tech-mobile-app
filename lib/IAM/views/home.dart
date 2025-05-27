import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helptechmobileapp/IAM/views/register.dart';

import '../../Consumer/views/interface_consumer.dart';
import '../../Shared/widgets/unauthorized.dart';
import '../../Technical/views/interface_technical.dart';
import '../services/login_service.dart';

import 'login.dart';

class Home extends StatelessWidget {

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LoginService _loginService = LoginService();

  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/IAM/home_wallpaper.PNG',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.symmetric
                    (vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Help Tech',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'HelpTechMobileApp',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/IAM/home_logo.PNG',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Bienvenido, ¿Qué desea hacer?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      GlassButton(
                        text: 'Iniciar sesión',
                        onTap: () async {

                          if (await _loginService.isAuthenticated() == true) {

                            String? storedRole = await _storage
                              .read(key: 'role');

                            if (storedRole == 'TECNICO') {
                              Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) =>
                                  const InterfaceTechnical()), (route) => false,
                              );
                            }
                            else if (storedRole == 'CONSUMIDOR') {
                              Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) =>
                                  const InterfaceConsumer()), (route) => false,
                              );
                            }
                            else {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>
                                  const Unauthorized()),
                              );
                            }
                          }
                          else {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                                const Login()),
                            );
                          }
                        },
                        color: Colors.tealAccent.shade700,
                      ),
                      const SizedBox(height: 15),

                      GlassButton(
                        text: 'Registrarse',
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                              const Register()),
                          );
                        },
                        color: Colors.tealAccent.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassButton extends StatefulWidget {

  final String text;
  final VoidCallback onTap;
  final Color color;

  const GlassButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.color
  });

  @override
  _GlassButtonState createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {

  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (context) => setState(() => pressed = true),
      onTapUp: (context) {
        setState(() => pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 60),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(pressed ? 0.7 : 1),
          borderRadius: BorderRadius.circular(30),
          boxShadow: pressed ? [] : [
            BoxShadow(
              color: widget.color.withOpacity(0.6),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}