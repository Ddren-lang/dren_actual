import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dren/services/auth_service.dart';
import '../models/users.dart';

//import 'package:shared_preferences/shared_preferences.dart';

class UserService {
 final String baseUrl = 'https://iidlive.com/api';

Future<List<User>> obtenerSugerencias(String token) async {
  print('Token enviadossa: $token');
  
  final response = await http.get(
    Uri.parse('$baseUrl/sugerencias'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => User.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener sugerencias: ${response.statusCode}');
  }
}

Future<void> seguirUsuario(int userId, String token) async {
  final token = await AuthService.getToken(); // Usa la función de AuthService

  if (token == null || token.isEmpty) {
    throw Exception('Token no encontrado');
  }

  print('Token usado para seguir usuario: $token');

  final url = Uri.parse('https://iidlive.com/api/follow/$userId');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    print('Error al seguir usuario: ${response.body}');
    throw Exception('Error al seguir usuario');
  }
}
}

  // Seguir a un usuario
  // Future<void> seguirUsuario(int userId, String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('token') ?? '';
  //     print('Token usado para obtener seguidores: $token');

  //   final url = Uri.parse('$baseUrl/api/follow/$userId');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //     },
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Error al seguir al usuario: ${response.body}');
  //   }
  // }


