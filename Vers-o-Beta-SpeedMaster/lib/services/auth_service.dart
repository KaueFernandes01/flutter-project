import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
    final String baseUrl = "https://api-motor-r0ji.onrender.com";

    Future<int> login(String login, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'login': login,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final usuario_id = data['usuario_id']; // <- isso precisa existir na resposta da sua API

      if (usuario_id == null) {
        throw Exception('ID do usuário não encontrado');
      }

      return usuario_id;
    } else if (response.statusCode == 401) {
      throw Exception('Login ou senha incorretos.');
    } else {
      throw Exception('Erro ao realizar login: ${response.body}');
    }
  }
    Future<void> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao registrar: ${response.body}');
    }
  }
    Future<void> logout() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_login');
      await prefs.remove('user_password');
  }

}
