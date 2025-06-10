import 'package:flutter/material.dart';
import 'motor_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int? usuarioId;
  bool isLoading = true;

  Future<void> _carregarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id');
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarUsuarioId();
  }

  Widget _getPage(int index) {
    if (isLoading || usuarioId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (index) {
      case 0:
        return const MotorPage(); // agora MotorPage tem acesso ao usuarioId
      case 1:
        return const ProfilePage(); // perfil também
      default:
        return const Text("Página não encontrada");
    }
  }

  void _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeedMaster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: usuarioId == null
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Motor'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
              ],
            ),
    );
  }
}