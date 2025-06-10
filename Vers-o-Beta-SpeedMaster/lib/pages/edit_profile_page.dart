import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialLogin;
  final int usuarioId;

  const EditProfilePage({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialLogin,
    required this.usuarioId,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController loginController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late int usuarioId;

  @override
  void initState() {
    super.initState();

    usuarioId = widget.usuarioId;
    
    nameController = TextEditingController(text: widget.initialName);
    emailController = TextEditingController(text: widget.initialEmail);
    loginController = TextEditingController(text: widget.initialLogin);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    loginController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final nome = nameController.text.trim();
      final email = emailController.text.trim();
      final login = loginController.text.trim();
      final senha = passwordController.text.trim();
      final confirm = confirmPasswordController.text.trim();

      // Valida se as senhas coincidem
      if (senha.isNotEmpty && senha != confirm) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await AuthService().atualizarPerfil(
          usuarioId: usuarioId,
          nome: nome,
          email: email,
          login: login,
          senha: senha.isEmpty ? null : senha,
        );

        if (!mounted) return;

        Navigator.pop(context, {
          'nome': nome,
          'email': email,
          'login': login,
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira um email válido';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: loginController,
                      decoration: const InputDecoration(labelText: 'Login'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira um login';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      decoration:
                          const InputDecoration(labelText: 'Nova Senha (opcional)'),
                      obscureText: true,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return 'Senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration:
                          const InputDecoration(labelText: 'Confirmar Nova Senha'),
                      obscureText: true,
                      validator: (value) {
                        if (passwordController.text.isNotEmpty &&
                            confirmPasswordController.text.isEmpty) {
                          return 'Por favor, confirme sua nova senha';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : const Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}