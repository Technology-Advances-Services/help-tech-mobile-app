import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:helptechmobileapp/IAM/views/terms_and_conditions.dart';

import '../../Consumer/views/interface_consumer.dart';
import '../../Shared/widgets/error_dialog.dart';
import '../../Technical/views/interface_technical.dart';
import '../services/login_service.dart';

class Login extends StatefulWidget {

  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final LoginService _loginService = LoginService();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> handleLogin(String role) async {

    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty || role.isEmpty) {

      showDialog(context: context, builder: (context) =>
        const ErrorDialog(message: 'Credenciales inválidas')
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    var result = await _loginService.accessToApp(username, password, role);

    setState(() {
      isLoading = false;
    });

    if (result == true) {

      Widget nextScreen = role == 'TECNICO'
        ? const InterfaceTechnical()
        : const InterfaceConsumer();

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute
        (builder: (context) => nextScreen), (route) => false
      );
    }
    else {
      showDialog(context: context, builder: (context) =>
        const ErrorDialog(message: 'Credenciales inválidas')
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87
                              ),
                            ),

                            const Text(
                              'HelpTechMobileApp',
                              style:
                              TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 20),

                            Image.asset(
                              'assets/IAM/home_logo.PNG',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 30),

                            const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87
                              ),
                            ),
                            const SizedBox(height: 20),

                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                labelText: 'Usuario',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 15),

                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                labelText: 'Contraseña',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 25),

                            if (isLoading)
                              const CircularProgressIndicator()
                            else ...[
                              GlassButton(
                                text: 'Técnico',
                                onTap: () async {
                                  await handleLogin('TECNICO');
                                },
                                color: Colors.tealAccent.shade700,
                              ),
                              const SizedBox(height: 10),

                              GlassButton(
                                text: 'Consumidor',
                                onTap: () async {
                                  await handleLogin('CONSUMIDOR');
                                },
                                color: Colors.tealAccent.shade700,
                              ),
                            ],
                            const SizedBox(height: 20),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                  const TermsAndConditions())
                                );
                              },
                              child: const Text(
                                'Ver Términos y Condiciones',
                                style: TextStyle(
                                  color: Colors.orange,
                                  decoration: TextDecoration.underline
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
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
    required this.color,
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