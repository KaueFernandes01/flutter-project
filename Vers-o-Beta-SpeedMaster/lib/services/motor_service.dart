import 'dart:convert';
import 'package:http/http.dart' as http;

class MotorService {
  final String baseUrl = 'https://api-motor-r0ji.onrender.com';

  Future<void> ligarMotor(bool ligado) async {
    await http.post(
      Uri.parse('$baseUrl/motor'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ligado': ligado}),
    );
  }

  Future<void> setVelocidade(double velocidade) async {
    await http.post(
      Uri.parse('$baseUrl/motor/velocidade'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'velocidade': velocidade.toInt()}),
    );
  }
}
