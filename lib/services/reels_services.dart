import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reels.dart';


class ReelService {
  final String baseUrl = 'https://iidlive.com';

  // Obtener token desde SharedPreferences
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    // Aquí podrías agregar lógica para refrescar token si está expirado
    return token;
  }
  /**funcion para las reacciones de los reels
   * se cambiara la url de la api 
   */
  Future<void> enviarReaccionReel(int reelId, String tipo) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    print('⚠️ Usuario no autenticado');
    return;
  }

   final url = Uri.parse('https://iidlive.com/api/reels/$reelId/like');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'tipo': tipo}),
  );

  if (response.headers['content-type']?.contains('application/json') ?? false) {
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      print('✅ Reacción enviada: ${data['message']}');
    } else {
      print('❌ Error en reacción: ${data['message']}');
    }
  } else {
    print('❌ Respuesta no es JSON:');
    print(response.body);
  }
}
Future<void> enviarComentarioReel({
  required int videoId,
  required String comentario,
  int? parentId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception('Token no encontrado');
  }

  final url = Uri.parse('https://iidlive.com/api/videocomments');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'video_id': videoId,
      'comment': comentario,
      if (parentId != null) 'parent_id': parentId,
    }),
  );

  if (response.statusCode == 201) {
    try {
      final data = jsonDecode(response.body);
      print('✅ Comentario enviado: ${data['comment']}');
    } catch (e) {
      print('✅ Comentario enviado, pero no se pudo parsear JSON: $e');
      print('Respuesta cruda: ${response.body}');
    }
  } else {
    try {
      final errorData = jsonDecode(response.body);
      print('❌ Error al enviar comentario: ${errorData['message'] ?? errorData}');
    } catch (_) {
      print('❌ Error al enviar comentario, respuesta cruda: ${response.body}');
    }
    throw Exception('Error al enviar comentario: Código ${response.statusCode}');
  }
}


  // Obtener reels para un usuario, método estático para mayor facilidad
  
  Future<List<Reel>> fetchReels(int userId) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/reels/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final reelsList = jsonResponse['reels'] as List;
      return reelsList.map((json) => Reel.fromJson(json)).toList();
    } else {
      // Opcional: extraer mensaje de error si existe
      String errorMessage = 'Error al obtener reels';
      try {
        final errorResponse = json.decode(response.body);
        if (errorResponse['message'] != null) {
          errorMessage = errorResponse['message'];
        }
      } catch (_) {}
      throw Exception('$errorMessage: ${response.body}');
    }
  }

  // Opcional: método para obtener datos usuario si lo necesitas
  Future<Map<String, dynamic>?> getUserData(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/usuario/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['usuario'];
    } else {
      return null;
    }
  }

  sendReaction(int id, String tipo) {}
}


//   Future<bool> sendReaction(int reelId, String tipo) async {
//   final prefs = await SharedPreferences.getInstance();
//   final userId = prefs.getInt('user_id') ?? 1;

//   final response = await http.post(
//     Uri.parse('https://iidlive.com/api/reels/reaccion'),
//     body: {
//       'reel_id': reelId.toString(),
//       'user_id': userId.toString(),
//       'tipo': tipo,
//     },
//   );

//   return response.statusCode == 200;
// }

// Future<int?> likeReel(int reelId, int likes) async {
//   const baseUrl = 'https://iidlive.com/';
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token') ?? '';

//   final url = Uri.parse('$baseUrl/reels/$reelId/like');

//   final headers = {
//     'Content-Type': 'application/json',
//     if (token.isNotEmpty) 'Authorization': 'Bearer $token',
//   };

//   final body = jsonEncode({'likesp': likes.toString()});

//   final response = await http.post(url, headers: headers, body: body);

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return data['total_likes'];
//   } else {
//     return null;
//   }
// }