import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

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
      const Text('Logout'),
    ],
    'CONSUMIDOR': [
      const SizedBox(),
      const JobOfConsumer(),
      const AccountConsumer(),
      const Text('Logout'),
    ],
  };

  List<SalomonBottomBarItem> buildSalomonItems(String role) {

    if (role == 'TECNICO') {
      return [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text('Inicio'),
          selectedColor: Colors.tealAccent.shade400,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.work),
          title: const Text('Atenciones'),
          selectedColor: Colors.tealAccent.shade400,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.bar_chart),
          title: const Text('Reportes'),
          selectedColor: Colors.tealAccent.shade400,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.account_circle),
          title: const Text('Cuenta'),
          selectedColor: Colors.tealAccent.shade400,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.logout),
          title: const Text('Salir'),
          selectedColor: Colors.redAccent,
        ),
      ];
    }

    return [
      SalomonBottomBarItem(
        icon: const Icon(Icons.home),
        title: const Text('Inicio'),
        selectedColor: Colors.tealAccent.shade400,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.work),
        title: const Text('Atenciones'),
        selectedColor: Colors.tealAccent.shade400,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.account_circle),
        title: const Text('Cuenta'),
        selectedColor: Colors.tealAccent.shade400,
      ),
      SalomonBottomBarItem(
        icon: const Icon(Icons.logout),
        title: const Text('Salir'),
        selectedColor: Colors.redAccent,
      ),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = _pagesByRole[role]!;
    final salomonItems = buildSalomonItems(role);
    final List<Widget> updatedPages = List.from(pages);

    updatedPages[0] = widget.child;

    return Container(
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
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Bienvenido, ${role.toLowerCase()}'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset('assets/IAM/home_logo.PNG'),
          ),
        ),
        body: Center(child: updatedPages[selectedIndex]),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: SalomonBottomBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {

                    final isLogout = (role == 'TECNICO' && index == 4) ||
                      (role == 'CONSUMIDOR' && index == 3);

                    if (isLogout) {

                      _loginService.logout();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                          (route) => false,
                      );
                    } else {
                      setState(() => selectedIndex = index);
                    }
                  },
                  items: salomonItems,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}