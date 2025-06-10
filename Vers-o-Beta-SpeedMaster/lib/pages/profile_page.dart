import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'log_page.dart';
import 'log_motor_page.dart';
import 'edit_profile_page.dart';
import 'login_page.dart'; 

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
      } else {
        usuarioFuture = Future.error('Usuário não autenticado');
      }
    });
  }

  Future<void> _carregarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id');
    });
  }

  Future<void> _editarPerfil() async {
    if (!mounted || usuarioId == null) return;

    final snapshot = await usuarioFuture;

    final nameController = TextEditingController(text: snapshot['nome']);
    final emailController = TextEditingController(text: snapshot['email']);
    final loginController = TextEditingController(text: snapshot['login']);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          initialName: nameController.text.trim(),
          initialEmail: emailController.text.trim(),
          initialLogin: loginController.text.trim(),
          usuarioId: usuarioId!,
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      try {
        setState(() {
          usuarioFuture = Future.value({
            'nome': result['nome'] ?? 'Nome não informado',
            'email': result['email'] ?? 'Email não informado',
            'login': result['login'] ?? 'Login não informado',
          });
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
        );
      }
    }
  }

  Future<void> _excluirConta() async {
    if (!mounted || usuarioId == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text('Tem certeza que deseja excluir sua conta permanentemente?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await AuthService().excluirUsuario(usuarioId!);

        await AuthService().logout();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir conta: $e')),
        );
      }
    }
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
          final String nome = usuario['nome'] ?? 'Não informado';
          final String email = usuario['email'] ?? 'Não informado';
          final String login = usuario['login'] ?? 'Não informado';

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
                          subtitle: Text(nome),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.blue),
                          title: const Text('Email'),
                          subtitle: Text(email),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.login, color: Colors.blue),
                          title: const Text('Login'),
                          subtitle: Text(login),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botão de editar perfil
                ElevatedButton.icon(
                  onPressed: _editarPerfil,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _excluirConta,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Excluir Conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogPage(usuarioId: usuarioId!),
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