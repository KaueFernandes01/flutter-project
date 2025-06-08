import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MotorService {
  final String baseUrl = "https://api-motor-r0ji.onrender.com";  

  Future<void> atualizarMotor({
    required int usuarioId,
    required bool ligado,
    required int velocidade,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); 

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', 
    };

    final response = await http.post(
      Uri.parse('$baseUrl/motor'),
      headers: headers,
      body: jsonEncode({
        'usuario_id': usuarioId,
        'status': ligado ? 'ligado' : 'desligado',
        'velocidade': velocidade,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar motor. Resposta: ${response.body}');
    }
  }
}