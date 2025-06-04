import 'dart:convert';
import 'package:http/http.dart' as http;

class LogService {
  final String baseUrl = "https://api-motor-r0ji.onrender.com"; 

  Future<List<dynamic>> getLogsDoUsuario(int usuarioId) async {
    final response = await http.get(Uri.parse('$baseUrl/logs/usuario/$usuarioId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar logs do usuário');
    }
  }
}