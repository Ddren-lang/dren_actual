// lib/services/influencer_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class InfluencerService {
  // Ahora recibes el userId además del token (o solo userId si no usas token)
  static Future<Map<String, dynamic>> fetchStats(String userId) async {
  final response = await http.get(
    Uri.parse('https://www.iidlive.com/api/puntos?user_id=$userId'),
    headers: {
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Error al cargar las métricas, status code: ${response.statusCode}');
  }
}

}
