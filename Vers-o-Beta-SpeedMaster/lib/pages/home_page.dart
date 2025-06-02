import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'log_page.dart';  // Import para a página de logs

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeedMaster'),
        backgroundColor: Colors.blueGrey,                // Fundo do AppBar (escurinho)
        iconTheme: const IconThemeData(color: Colors.white), // Cor branca para os ícones
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LogPage()),
              );
            },
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
