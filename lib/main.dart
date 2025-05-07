import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helptechmobileapp/IAM/views/login.dart';
import 'package:helptechmobileapp/Technical/views/interface_technical.dart';

import 'IAM/views/home.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyHomePage());
}

class MyHomePage extends StatelessWidget {

  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help Tech',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Home(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const Home(),
        '/login': (context) => const Login(),
        '/technical': (context) => const InterfaceTechnical()
      },
    );
  }
}