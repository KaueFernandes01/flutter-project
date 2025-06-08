import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogService {
  final String baseUrl = "https://api-motor-r0ji.onrender.com"; 

  Future<List<dynamic>> getLogsDoUsuario(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/logs/usuario/$usuarioId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar logs do usuário');
    }
  }

  Future<List<dynamic>> getLogsDoMotor(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/motor/logs/$usuarioId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar logs do motor');
    }
  }
}