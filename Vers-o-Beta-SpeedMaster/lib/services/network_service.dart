import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkService {
  final String baseUrl = "https://api-motor-r0ji.onrender.com";  // Substitua pelo seu endereço da API

  // Função para fazer login
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Se a requisição for bem-sucedida, retorne verdadeiro
      return true;
    } else {
      // Se falhar, retorne falso
      return false;
    }
  }

  // Função para buscar os usuários
  Future<List<dynamic>> fetchUsuarios() async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios'));

    if (response.statusCode == 200) {
      // Se a requisição for bem-sucedida, decodifique o JSON
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }
}
