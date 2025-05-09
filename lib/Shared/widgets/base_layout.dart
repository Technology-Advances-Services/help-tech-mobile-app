import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helptechmobileapp/Attention/views/job_of_technical.dart';
import 'package:helptechmobileapp/IAM/services/login_service.dart';
import 'package:helptechmobileapp/IAM/views/login.dart';
import 'package:helptechmobileapp/Statistic/views/statistical_graph.dart';

class BaseLayout extends StatefulWidget {

  final Widget child;

  const BaseLayout({super.key, required this.child});

  @override
  _BaseLayout createState() => _BaseLayout();
}

class _BaseLayout extends State<BaseLayout> {

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LoginService _loginService = LoginService();

  String _role = '';
  int _selectedIndex = 0;

  final Map<String, List<Widget>> _pagesByRole = {
    'TECNICO': [
      const SizedBox(),
      const JobOfTechnical(),
      const StatisticalGraph(),
      const Text('Logout'),
    ],
    'CONSUMIDOR': [
      const SizedBox(),
      const Text('Atenciones'),
      const Text('Logout'),
    ],
  };

  List<BottomNavigationBarItem> _buildNavItems(String role) {

    if (role == 'TECNICO') {
      return [
        const BottomNavigationBarItem
          (icon: Icon(Icons.home), label: 'Inicio'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.assignment_ind), label: 'Atenciones'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.bar_chart), label: 'Reportes'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.logout), label: 'Salir'),
      ];
    }
    else {
      return [
        const BottomNavigationBarItem
          (icon: Icon(Icons.home), label: 'Inicio'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.assignment_ind), label: 'Atenciones'),
        const BottomNavigationBarItem
          (icon: Icon(Icons.logout), label: 'Salir'),
      ];
    }
  }

  Future<void> _loadRole() async {

    String? storedRole = await _storage.read(key: 'role');

    if (storedRole != null && mounted) {
      setState(() {
        _role = storedRole;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  @override
  Widget build(BuildContext context) {
    if (_role.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = _pagesByRole[_role]!;
    final navItems = _buildNavItems(_role);

    final List<Widget> updatedPages = List.from(pages);
    updatedPages[0] = widget.child;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Bienvenido, exitos en tu trabajo.'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/IAM/home_logo.PNG'),
        ),
      ),
      body: Center(child: updatedPages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: navItems,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: (index) {

          final isLogout = (_role == 'TECNICO' && index == 3) ||
              (_role == 'CONSUMIDOR' && index == 2);

          if (isLogout) {

            _loginService.logout();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
            );
          }
          else {
            setState(() => _selectedIndex = index);
          }
        },
      ),
    );
  }
}