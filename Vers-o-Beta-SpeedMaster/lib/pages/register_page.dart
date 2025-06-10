import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _register() async {
    final nome = _nameController.text.trim();
    final email = _emailController.text.trim();
    final login = _loginController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if ([nome, email, login, password, confirm].any((e) => e.isEmpty)) {
      _showError('Todos os campos são obrigatórios.');
      return;
    }

    if (password.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    if (password != confirm) {
      _showError('As senhas não coincidem.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(nome, email, login, password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      _showError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome completo')),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: _loginController, decoration: const InputDecoration(labelText: 'Login')),
                  TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
                  TextField(controller: _confirmController, decoration: const InputDecoration(labelText: 'Confirmar Senha'), obscureText: true),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _register, child: const Text("Registrar")),
                ],
              ),
            ),
    );
  }
}