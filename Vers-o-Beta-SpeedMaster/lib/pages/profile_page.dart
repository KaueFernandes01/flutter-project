import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'log_page.dart';
import 'log_motor_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? usuarioId;
  late Future<Map<String, dynamic>> usuarioFuture;

  @override
  void initState() {
    super.initState();
    _carregarUsuarioId().then((_) {
      if (usuarioId != null) {
        usuarioFuture = AuthService().buscarUsuario(usuarioId!);
      }
    });
  }

  Future<void> _carregarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (usuarioId == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: usuarioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar perfil: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Dados do usuário indisponíveis."));
          }

          final usuario = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                // Foto do usuário
                const Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                  ),
                ),
                const SizedBox(height: 24),

                // Dados do usuário
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações do Usuário',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: const Text('Nome'),
                          subtitle: Text(usuario['nome'] ?? 'Não informado'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.blue),
                          title: const Text('Email'),
                          subtitle: Text(usuario['email'] ?? 'Não informado'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Botão Logs do Usuário
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogPage(userId: usuarioId!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Ver Logs do Usuário'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 16),

                // Botão Logs do Motor
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogMotorPage(usuarioId: usuarioId!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings_remote),
                  label: const Text('Ver Logs do Motor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}