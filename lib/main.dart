import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Attention/views/job_of_consumer.dart';
import 'package:helptechmobileapp/Attention/views/job_of_technical.dart';
import 'package:helptechmobileapp/Consumer/views/account_consumer.dart';
import 'package:helptechmobileapp/Consumer/views/interface_consumer.dart';
import 'package:helptechmobileapp/IAM/views/login.dart';
import 'package:helptechmobileapp/Technical/views/account_technical.dart';
import 'package:helptechmobileapp/Technical/views/interface_technical.dart';

import 'IAM/views/home.dart';
import 'Statistic/views/statistical_graph.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MyHomePage());
}

class MyHomePage extends StatelessWidget {

  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Help Tech',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Home(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => const Login(),
        '/technical': (context) => const InterfaceTechnical(),
        '/statistic': (context) => const StatisticalGraph(),
        '/job_technical': (context) => const JobOfTechnical(),
        '/account_technical': (context) => const AccountTechnical(),
        '/consumer': (context) => const InterfaceConsumer(),
        '/job_consumer': (context) => const JobOfConsumer(),
        '/account_consumer': (context) => const AccountConsumer()
      }
    );
  }
}