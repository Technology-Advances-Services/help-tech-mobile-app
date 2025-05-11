import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Consumer/view/interface_consumer.dart';
import 'package:helptechmobileapp/IAM/services/login_service.dart';
import 'package:helptechmobileapp/IAM/views/terms_and_conditions.dart';
import 'package:helptechmobileapp/Shared/widgets/error_dialog.dart';
import 'package:helptechmobileapp/Technical/views/interface_technical.dart';

class Login extends StatefulWidget {

  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final LoginService _loginService = LoginService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Help Tech',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'HelpTechAppMobile',
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
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'Usuario',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: () async {

                              String username = _usernameController.text;
                              String password = _passwordController.text;
                              String role = 'TECNICO';

                              if (username != "" &&
                                  password != "" &&
                                  role != "") {

                                var result = await _loginService.accessToApp(
                                    username, password, role);

                                if (result == true) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                    const InterfaceTechnical()),
                                        (route) => false,
                                  );
                                }
                                else {
                                  showDialog(
                                      context: context,
                                      builder: (context) => const ErrorDialog
                                        (message: 'Credenciales inválidas')
                                  );
                                }
                              }
                              else {
                                showDialog(
                                    context: context,
                                    builder: (context) => const ErrorDialog
                                      (message: 'Credenciales inválidas')
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Técnico'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {

                              String username = _usernameController.text;
                              String password = _passwordController.text;
                              String role = 'CONSUMIDOR';

                              if (username != "" &&
                                  password != "" &&
                                  role != "") {

                                var result = await _loginService.accessToApp(
                                    username, password, role);

                                if (result == true) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                    const InterfaceConsumer()),
                                        (route) => false,
                                  );
                                }
                                else {
                                  showDialog(
                                      context: context,
                                      builder: (context) => const ErrorDialog
                                        (message: 'Credenciales inválidas')
                                  );
                                }
                              }
                              else {
                                showDialog(
                                    context: context,
                                    builder: (context) => const ErrorDialog
                                      (message: 'Credenciales inválidas')
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Consumidor'),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                const TermsAndConditions()),
                              );
                            },
                            child: const Text(
                              'Ver Términos y Condiciones',
                              style: TextStyle(
                                color: Colors.teal,
                                decoration: TextDecoration.underline,
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
        ],
      ),
    );
  }
}
