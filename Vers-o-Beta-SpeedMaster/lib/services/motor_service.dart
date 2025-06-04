import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class MotorService {
  final String baseUrl = 'https://api-motor-r0ji.onrender.com';

  Future<void> atualizarMotor({required bool ligado, required double velocidade}) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('user_id');

    if (usuarioId == null) {
      throw Exception("Usuário não logado");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/motor'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': usuarioId,
        'status': ligado ? 'ligado' : 'desligado',
        'velocidade': velocidade.toInt(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar motor');
    }
  }
}