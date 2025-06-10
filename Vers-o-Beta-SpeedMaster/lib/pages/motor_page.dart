import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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

  BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _connected = false;
  String targetDeviceName = 'HC-05';

  @override
  void initState() {
    super.initState();
    _carregarUsuarioId();
    _inicializarBluetooth();
  }

  Future<void> _carregarUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt('usuario_id');
    });
  }

  Future<void> _inicializarBluetooth() async {
    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;

    if (isEnabled == null) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    _escanearEDescobrirHC05();
  }

  Future<void> _escanearEDescobrirHC05() async {
    setState(() => _isConnecting = true);

    try {
      final bondedDevices =
          await FlutterBluetoothSerial.instance.getBondedDevices();

      final hc05 = bondedDevices.firstWhere(
        (d) => d.name == targetDeviceName,
        orElse: () => throw Exception("HC-05 não pareado"),
      );

      await BluetoothConnection.toAddress(hc05.address).then((conn) {
        _connection = conn;
        setState(() {
          _connected = true;
          _isConnecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conectado ao HC-05")),
        );

        _connection!.input?.listen((data) {
          print(utf8.decode(data));
        });
      });
    } catch (e) {
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao conectar: $e")),
      );
    }
  }

  Future<void> _enviarComando(String comando) async {
    if (_connection != null && _connected) {
      try {
        _connection!.output.add(utf8.encode("$comando\n"));
        await _connection!.output.allSent;
        print("Comando enviado: $comando");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar comando: $e")),
        );
      }
    }
  }

  void _desconectar() {
    _connection?.dispose();
    setState(() {
      _connected = false;
      _connection = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Desconectado")),
    );
  }

  Future<void> _atualizarMotor() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = prefs.getInt('usuario_id');

    if (token == null || usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário não autenticado")),
      );
      return;
    }

    try {
      await _motorService.atualizarMotor(
        usuarioId: usuarioId,
        ligado: _motorLigado,
        velocidade: _velocidade,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar motor: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle do Motor')),
      body: Padding(
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
                _enviarComando(_motorLigado ? "MOTOR_ON" : "MOTOR_OFF");
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
                          _enviarComando("VEL:$_velocidade");
                        }
                      : null,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                Text('$_velocidade Vel', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _motorLigado
                      ? () {
                          setState(() => _velocidade = (_velocidade + 10).clamp(0, 50));
                          _atualizarMotor();
                          _enviarComando("VEL:$_velocidade");
                        }
                      : null,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _connected
                  ? _desconectar
                  : (_isConnecting ? null : _escanearEDescobrirHC05),
              icon: _connected
                  ? const Icon(Icons.bluetooth_connected, color: Colors.green)
                  : (_isConnecting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                      : const Icon(Icons.bluetooth)),
              label: Text(
                _connected ? 'Desconectar' : (_isConnecting ? 'Conectando...' : 'Conectar ao HC-05'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _connected ? Colors.red : Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
