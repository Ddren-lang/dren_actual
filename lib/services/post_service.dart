import 'package:dren/models/post.dart';
import 'package:dren/services/home_services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  final ApiService apiService;

  PostService(this.apiService);
Future<List<Post>> fetchAllPosts({required int page, String? category}) async {
  return await apiService.fetchAllPosts(page: page, category: category);
}
  

  Future<List<String>> fetchCategorias() async {
    return await apiService.fetchCategorias();
  }

  final String baseUrl = 'https://iidlive.com/api';
  Future<void> enviarReaccion(String postId, String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('⚠️ Usuario no autenticado');
      return;
    }

    final url = Uri.parse('$baseUrl/posts/$postId/like');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'tipo': tipo}),
    );

    if (response.headers['content-type']?.contains('application/json') ??
        false) {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Reacción: ${data['message']}');
      } else {
        print('❌ Error: ${data['message']}');
      }
    } else {
      print('❌ Respuesta no es JSON:');
      print(response.body);
    }
  }
Future<void> enviarComentario({
  required int postId,
  required String body,
  int? parentId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('Usuario no autenticado');
  }

  final Map<String, dynamic> data = {
    'body': body,
    'post_id': postId,  // ✔️ usas esto porque en tu tabla existe post_id
  };

  if (parentId != null) {
    data['parent_id'] = parentId;  // ✔️ para subcomentarios
  }

  final response = await http.post(
  Uri.parse('https://iidlive.com/api/comments'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(data),
);

print('Status code: ${response.statusCode}');
print('Response headers: ${response.headers}');
print('Response body: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Error al enviar comentario: ${response.body}');
  }
}

}
