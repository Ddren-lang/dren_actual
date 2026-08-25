// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/follower.dart';

// class FollowerService {
//   // Definimos baseUrl fijo aquí:
//   static const String baseUrl = 'https://iidlive.com';

//   // Eliminamos el constructor porque no necesitamos pasar baseUrl
//   FollowerService();

//   Future<List<Follower>> getFollowers(int userId) async {
//     final url = Uri.parse('$baseUrl/api/users/$userId/followers');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       final followersList = jsonResponse['followers'] as List;
//       return followersList.map((json) => Follower.fromJson(json)).toList();
//     } else {
//       throw Exception('Error al obtener seguidores');
//     }
//   }
  

  
// }
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/follower.dart';

// class FollowerService {
//   static const String baseUrl = 'https://iidlive.com';

//   FollowerService();

//   // Obtener la lista de seguidores a los que me siguen y no me siguen
//   Future<List<Follower>> getFollowers(int userId) async {
//     final url = Uri.parse('$baseUrl/api/users/$userId/followers');

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       final followersList = jsonResponse['followers'] as List;
//       return followersList.map((json) => Follower.fromJson(json)).toList();
//     } else {
//       throw Exception('Error al obtener seguidores');
//     }
//   }

//   // Seguir a un usuario
//   // Future<void> followUser(int userId) async {  
//   //   final url = Uri.parse('$baseUrl/api/follow/$userId');
//   //   final response = await http.post(url);

//   //   if (response.statusCode != 200) {
//   //     throw Exception('Error al seguir al usuario');
//   //   }
//   // }

//   // // Dejar de seguir a un usuario
//   // Future<void> unfollowUser(int userId) async {
//   //   final url = Uri.parse('$baseUrl/api/unfollow/$userId');
//   //   final response = await http.delete(url);

//   //   if (response.statusCode != 200) {
//   //     throw Exception('Error al dejar de seguir al usuario');
//   //   }
//   // }
//   Future<void> followUser(int userId) async {
//   final url = Uri.parse('$baseUrl/api/follow/$userId');
//   final response = await http.post(url);

//   if (response.statusCode != 200) {
//     throw Exception('Error al seguir al usuario');
//   }
// }

// Future<void> unfollowUser(int userId) async {
//   final url = Uri.parse('$baseUrl/api/unfollow/$userId');
//   final response = await http.delete(url);  // Aquí es DELETE, no POST

//   print('Unfollow status: ${response.statusCode}');
//   print('Unfollow body: ${response.body}');

//   if (response.statusCode != 200) {
//     throw Exception('Error al dejar de seguir al usuario: ${response.body}');
//   }
// }


  
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dren/services/auth_service.dart';
import '../models/follower.dart';
import 'package:shared_preferences/shared_preferences.dart';
class FollowerService {
  static const String baseUrl = 'https://iidlive.com';

  FollowerService();

  Future<List<Follower>> getFollowers(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('$baseUrl/api/users/$userId/followers');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

   if (response.statusCode == 200) {
  final jsonResponse = json.decode(response.body);
  final followersList = jsonResponse['followers'] as List;
  return followersList.map((json) => Follower.fromJson(json)).toList();
} else {
  print('Error al obtener seguidores: ${response.statusCode}');
  print('Response body: ${response.body}');
  throw Exception('Error al obtener seguidores: ${response.body}');
}
  }
  Future<void> followUser(int userId) async {
  final token = await AuthService.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Token no encontrado');
  }

  final url = Uri.parse('$baseUrl/api/follow/$userId');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al seguir al usuario: ${response.body}');
  }
}
Future<void> unfollowUser(int userId) async {
  final token = await AuthService.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Token no encontrado');
  }

  final url = Uri.parse('$baseUrl/api/unfollow/$userId');
  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al dejar de seguir al usuario: ${response.body}');
  }
}
}

  // Future<void> followUser(int userId, String token) async {
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

//   Future<void> unfollowUser(int userId, String token) async {
//     final url = Uri.parse('$baseUrl/api/unfollow/$userId');
//     final response = await http.delete(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Error al dejar de seguir al usuario: ${response.body}');
//     }
//   }
// }
  // Seguir a un usuario
  // Future<void> followUser(int userId) async {  
  //   final url = Uri.parse('$baseUrl/api/follow/$userId');
  //   final response = await http.post(url);

  //   if (response.statusCode != 200) {
  //     throw Exception('Error al seguir al usuario');
  //   }
  // }

  // // Dejar de seguir a un usuario
  // Future<void> unfollowUser(int userId) async {
  //   final url = Uri.parse('$baseUrl/api/unfollow/$userId');
  //   final response = await http.delete(url);

  //   if (response.statusCode != 200) {
  //     throw Exception('Error al dejar de seguir al usuario');
  //   }
  // }
//   Future<void> followUser(int userId) async {
//   final url = Uri.parse('$baseUrl/api/follow/$userId');
//   final response = await http.post(url);

//   if (response.statusCode != 200) {
//     throw Exception('Error al seguir al usuario');
//   }
// }

// Future<void> unfollowUser(int userId) async {
//   final url = Uri.parse('$baseUrl/api/unfollow/$userId');
//   final response = await http.delete(url);  // Aquí es DELETE, no POST

//   print('Unfollow status: ${response.statusCode}');
//   print('Unfollow body: ${response.body}');

//   if (response.statusCode != 200) {
//     throw Exception('Error al dejar de seguir al usuario: ${response.body}');
//   }
// }

