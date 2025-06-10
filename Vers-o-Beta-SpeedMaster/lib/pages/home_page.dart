import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'log_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  int? usuarioId;

  @override
  void initState() {
    super.initState();
    _carregarUsuarioId();
  }

  Future<void> _carregarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id');
    });
  }

  void _irParaLogPage() async {
    if (usuarioId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LogPage(usuarioId: usuarioId!),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário não encontrado. Faça login novamente.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeedMaster'),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth),
            tooltip: 'Bluetooth',
            onPressed: () {
              debugPrint('Botão Bluetooth pressionado');
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Ver Log',
            onPressed: _irParaLogPage,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              authService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Bem-vindo ao painel!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}