import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "https://api-motor-r0ji.onrender.com"; 

  Future<int> login(String login, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': login,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['token'] == null) {
        throw Exception('Token não recebido');
      }

      final int usuarioId = data['usuario_id'];
      final String token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('usuario_id', usuarioId);
      await prefs.setString('token', token);

      return usuarioId;
    } else if (response.statusCode == 401) {
      throw Exception('Login ou senha incorretos.');
    } else {
      throw Exception('Erro ao realizar login: ${response.body}');
    }
  }
  Future<void> atualizarPerfil({
  required int usuarioId,
  required String nome,
  required String email,
  required String login,
  String? senha,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('Token não encontrado. Faça login novamente.');
  }

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final body = {
    'nome': nome,
    'email': email,
    'login': login,
  };

  if (senha != null && senha.isNotEmpty) {
    body['senha'] = senha;
  }

  final response = await http.put(
    Uri.parse('$baseUrl/usuarios/$usuarioId'), 
    headers: headers,
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    try {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['erro'] ?? 'Erro ao atualizar perfil');
    } catch (_) {
      throw Exception('Erro ao atualizar perfil. Código: ${response.statusCode}');
    }
  }
}
Future<void> excluirUsuario(int usuarioId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.delete(
    Uri.parse('$baseUrl/usuarios/$usuarioId'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['erro'] ?? 'Erro ao excluir conta');
  }
}
  Future<void> register(String nome, String email, String login, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/usuarios/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'nome': nome,
      'email': email,
      'login': login,
      'senha': password,
    }),
  );

  if (response.statusCode == 201) {
    return;
  } else {
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['erro'] ?? 'Erro ao registrar usuário');
  }
}

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_id');
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<int?> buscarUsuarioId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('usuario_id');
}
  Future<Map<String, dynamic>> buscarUsuario(int usuarioId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(
    Uri.parse('$baseUrl/usuarios/$usuarioId'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data is List && data.isNotEmpty) {
      
      if (data[0] is Map<String, dynamic>) {
        return data[0] as Map<String, dynamic>;
      } else {
        throw Exception('Formato inválido para dados do usuário');
      }
    } else if (data is Map) {
      
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception('Dados do usuário inválidos ou vazios');
    }
  } else {
    throw Exception('Erro ao buscar dados do usuário');
  }
}
}