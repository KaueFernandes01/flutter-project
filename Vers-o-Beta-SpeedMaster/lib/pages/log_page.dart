import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  final List<String> logs = [
    'Usuário criado: rodrigo_souza - 23/05/2025 14:32',
    'Login realizado: rodrigo_souza - 23/05/2025 14:33',
    'Velocidade alterada para 120 RPM - 23/05/2025 14:34',
    'Logout - 23/05/2025 14:35',
  ];

  LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Atividades'),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(logs[index]),
          );
        },
      ),
    );
  }
}
