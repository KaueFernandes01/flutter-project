import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'log_page.dart';
import '../services/log_service.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;
  int? usuarioId;

  List<dynamic> userLogs = [];
  bool isLoading = true;
  final LogService _logService = LogService();

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _carregarLogs();
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id');
      userName = prefs.getString('nome_usuario'); 
      userEmail = prefs.getString('email_usuario'); 
    });

    if (usuarioId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Se não tiver nome/senha no SharedPreferences, buscar na API
    if (userName == null || userEmail == null) {
      // Aqui você pode chamar o AuthService pra buscar da API
      // Exemplo:
      // final usuario = await AuthService().buscarUsuario(usuarioId!);
      // setState(() {
      //   userName = usuario['nome'];
      //   userEmail = usuario['email'];
      // });
    }
  }

  Future<void> _carregarLogs() async {
    try {
      if (usuarioId != null) {
        final logs = await _logService.getLogsDoUsuario(usuarioId!);
        setState(() {
          userLogs = logs;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar logs: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: userName ?? '',
          initialEmail: userEmail ?? '',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        userName = result['name'] ?? userName;
        userEmail = result['email'] ?? userEmail;
      });
    }
  }

  void _goToLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogPage(userId: usuarioId ?? -1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth, color: theme.colorScheme.primary),
            tooltip: 'Bluetooth',
            onPressed: () => debugPrint('Botão Bluetooth pressionado'),
          ),
          IconButton(
            icon: Icon(Icons.list, color: theme.colorScheme.primary),
            tooltip: 'Ver Logs',
            onPressed: _goToLogs,
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primary,
              child: const CircleAvatar(
                radius: 56,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Informações do Usuário',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: theme.colorScheme.primary),
                    title: Text('Nome', style: theme.textTheme.titleMedium),
                    subtitle: Text(userName ?? 'Não informado', style: theme.textTheme.bodyMedium),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.email, color: theme.colorScheme.primary),
                    title: Text('Email', style: theme.textTheme.titleMedium),
                    subtitle: Text(userEmail ?? 'Não informado', style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _editProfile,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Editar Perfil'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
            ),
            child: const Text('Excluir Conta'),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Histórico de Ações',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (userLogs.isNotEmpty)
                    Column(
                      children: userLogs.map((log) {
                        return ListTile(
                          leading: Icon(Icons.history, color: theme.colorScheme.primary),
                          title: Text(log['acao']),
                          subtitle: Text('${log['detalhes']} - ${log['data_hora']}'),
                        );
                      }).toList(),
                    )
                  else
                    const Padding( // ✅ Agora funciona direitinho
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhum registro encontrado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}