import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/motor_service.dart';

class MotorPage extends StatefulWidget {
  const MotorPage({super.key});

  @override
  State<MotorPage> createState() => _MotorPageState();
}

class _MotorPageState extends State<MotorPage> {
  bool _motorLigado = false;
  int _velocidade = 0;
  final MotorService _motorService = MotorService();
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

  void _atualizarMotor() async {
    if (usuarioId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuário não autenticado")),
        );
      }
      return;
    }

    try {
      await _motorService.atualizarMotor(
        usuarioId: usuarioId!,
        ligado: _motorLigado,
        velocidade: _velocidade,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar motor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Controle do Motor', style: TextStyle(fontSize: 20)),
          SwitchListTile(
            title: Text(_motorLigado ? 'Motor Ligado' : 'Motor Desligado'),
            value: _motorLigado,
            onChanged: (val) {
              setState(() => _motorLigado = val);
              _atualizarMotor();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _motorLigado
                    ? () {
                        setState(() => _velocidade = (_velocidade - 10).clamp(0, 50));
                        _atualizarMotor();
                      }
                    : null,
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 20),
              Text(
                '$_velocidade Vel',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _motorLigado
                    ? () {
                        setState(() => _velocidade = (_velocidade + 10).clamp(0, 50));
                        _atualizarMotor();
                      }
                    : null,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}