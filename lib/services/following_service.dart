import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/following.dart';

class FollowingService {
  final String baseUrl;

  FollowingService({this.baseUrl = 'https://iidlive.com'});

  Future<List<Following>> getFollowing(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/api/users/$userId/following');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Verificar si existe 'following' y es lista
      if (jsonResponse['following'] is List) {
        final followingList = jsonResponse['following'] as List;
        return followingList.map((json) => Following.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Error al obtener seguidos: ${response.body}');
    }
  }
}
