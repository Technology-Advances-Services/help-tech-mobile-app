import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../Attention/views/job_of_consumer.dart';
import '../../Attention/views/job_of_technical.dart';
import '../../Consumer/views/account_consumer.dart';
import '../../IAM/services/login_service.dart';
import '../../IAM/views/login.dart';
import '../../Statistic/views/statistical_graph.dart';
import '../../Technical/views/account_technical.dart';

class BaseLayout extends StatefulWidget {

  final Widget child;

  const BaseLayout({super.key, required this.child});

  @override
  _BaseLayoutState createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LoginService _loginService = LoginService();

  String role = '';
  int selectedIndex = 0;

  final Map<String, List<Widget>> _pagesByRole = {
    'TECNICO': [
      const SizedBox(),
      const JobOfTechnical(),
      const StatisticalGraph(),
      const AccountTechnical(),
      const Text('Logout')
    ],
    'CONSUMIDOR': [
      const SizedBox(),
      const JobOfConsumer(),
      const AccountConsumer(),
      const Text('Logout')
    ],
  };

  List<BottomNavigationBarItem> buildNavItems(String role) {

    if (role == 'TECNICO') {
      return [
        const BottomNavigationBarItem
          (icon: Icon(Icons.home), label: 'Inicio'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.work), label: 'Atenciones'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.bar_chart), label: 'Reportes'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.account_circle), label: 'Cuenta'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.logout), label: 'Salir')
      ];
    }

    return [
      const BottomNavigationBarItem
        (icon: Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem
        (icon: Icon(Icons.work), label: 'Atenciones'),
      const BottomNavigationBarItem
        (icon: Icon(Icons.account_circle), label: 'Cuenta'),
      const BottomNavigationBarItem
        (icon: Icon(Icons.logout), label: 'Salir')
    ];
  }

  Future<void> loadRole() async {

    String? storedRole = await _storage.read(key: 'role');

    if (storedRole != null && mounted) {
      setState(() {
        role = storedRole;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadRole();
  }

  @override
  Widget build(BuildContext context) {

    if (role.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    }

    final pages = _pagesByRole[role]!;
    final navItems = buildNavItems(role);

    final List<Widget> updatedPages = List.from(pages);
    updatedPages[0] = widget.child;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${role.toLowerCase()}'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/IAM/home_logo.PNG')
        )
      ),
      body: Center(child: updatedPages[selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: navItems,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: (index) {

          final isLogout = (role == 'TECNICO' && index == 4) ||
              (role == 'CONSUMIDOR' && index == 3);

          if (isLogout) {

            _loginService.logout();

            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) => const Login()), (route) => false
            );
          }
          else {
            setState(() => selectedIndex = index);
          }
        }
      )
    );
  }
}