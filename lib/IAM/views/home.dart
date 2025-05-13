import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helptechmobileapp/Consumer/views/interface_consumer.dart';
import 'package:helptechmobileapp/IAM/services/login_service.dart';
import 'package:helptechmobileapp/IAM/views/login.dart';
import 'package:helptechmobileapp/IAM/views/register.dart';
import 'package:helptechmobileapp/Shared/widgets/unauthorized.dart';
import 'package:helptechmobileapp/Technical/views/interface_technical.dart';

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
              fit: BoxFit.cover
            ),
          ),
          Center(
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      )
                    ),
                    const Text(
                      'HelpTechMobileApp',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54
                      )
                    ),
                    const SizedBox(height: 20),

                    Image.asset(
                      'assets/IAM/home_logo.PNG',
                      width: 100,
                      height: 100
                    ),
                    const SizedBox(height: 30),

                    const Text('Bienvenido, ¿Qué desea hacer?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87
                      )
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async {

                        if (await _loginService.isAuthenticated() == true) {

                          String? storedRole = await _storage.read(key: 'role');

                          if (storedRole == 'TECNICO') {
                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) =>
                              const InterfaceTechnical()),
                                  (route) => false
                            );
                          }
                          else if (storedRole == 'CONSUMIDOR'){

                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) =>
                              const InterfaceConsumer()),
                                  (route) => false
                            );
                          }
                          else {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) =>
                              const Unauthorized())
                            );
                          }
                        }
                        else {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>
                            const Login())
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )
                      ),
                      child: const Text('Iniciar sesión')
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) =>
                          const Register())
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                        )
                      ),
                      child: const Text('Registrarse')
                    )
                  ]
                )
              )
            )
          )
        ]
      )
    );
  }
}