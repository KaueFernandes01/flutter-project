import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'log_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Usuário Teste';
  String userEmail = 'teste@exemplo.com';

  Future<void> _editProfile() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialName: userName,
          initialEmail: userEmail,
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
      MaterialPageRoute(builder: (_) => LogPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    subtitle: Text(userName, style: theme.textTheme.bodyMedium),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.email, color: theme.colorScheme.primary),
                    title: Text('Email', style: theme.textTheme.titleMedium),
                    subtitle: Text(userEmail, style: theme.textTheme.bodyMedium),
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
              // Sem funcionalidade por enquanto
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
            ),
            child: const Text('Excluir Conta'),
          ),
        ],
      ),
    );
  }
}
