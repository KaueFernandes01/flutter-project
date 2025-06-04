import 'package:flutter/material.dart';
import '../services/motor_service.dart';

class MotorPage extends StatefulWidget {
  const MotorPage({super.key});

  @override
  State<MotorPage> createState() => _MotorPageState();
}

class _MotorPageState extends State<MotorPage> {
  bool _motorLigado = false;
  double _velocidade = 0;
  final MotorService _motorService = MotorService();

  void _atualizarMotor() async {
    try {
      await _motorService.atualizarMotor(
        ligado: _motorLigado,
        velocidade: _velocidade,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
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
          Slider(
            value: _motorLigado ? _velocidade : 0,
            onChanged: _motorLigado
                ? (val) {
                    setState(() => _velocidade = val);
                    _atualizarMotor();
                  }
                : null,
            min: 0,
            max: 255,
            divisions: 255,
            label: '${_velocidade.toInt()}',
          ),
          const SizedBox(height: 10),
          Text('Velocidade: ${_velocidade.toInt()}'),
        ],
      ),
    );
  }
}
