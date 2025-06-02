import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailCtrl = TextEditingController();
  String? mensagem;

  void _enviarEmail() {
    if (emailCtrl.text.trim().isEmpty) {
      setState(() => mensagem = 'Digite seu email.');
    } else {
      setState(() => mensagem = 'Foi enviado um email para você realizar a alteração da sua senha.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Esqueci minha senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _enviarEmail, child: const Text('Enviar')),
            if (mensagem != null) ...[
              const SizedBox(height: 20),
              Text(mensagem!, style: const TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
