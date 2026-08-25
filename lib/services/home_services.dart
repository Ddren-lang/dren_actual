// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:iidlive_app/models/post.dart';
// import 'package:metadata_fetch/metadata_fetch.dart';
// class ApiService {
//   static const String baseUrl = 'https://iidlive.com/api/';

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//   // token para obtener el usuario y se obtenga los posts del usario 
//  Future<List<Post>> fetchAllPosts({required int page, String? category}) async {
//   final token = await getToken();
//   String url = '${baseUrl}posts/inicio?page=$page'; // 🔁 URL corregida
//   if (category != null && category != 'Todos') {
//     url += '&categoria=${Uri.encodeComponent(category)}';
//   }

//   final response = await http.get(
//     Uri.parse(url),
//     headers: {
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     List postsData = data['posts'] ?? [];
//     return postsData.map<Post>((json) => Post.fromJson(json)).toList();
//   } else {
//     throw Exception('Error al obtener posts: ${response.statusCode}');
//   }
// }

// Future<List<Post>> fetchPosts(String category, {required int page}) async {
//   final token = await getToken();
//   final url = '${baseUrl}posts?categoria=${Uri.encodeComponent(category)}&page=$page';

//   final response = await http.get(
//     Uri.parse(url),
//     headers: {
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     List postsData = data['posts'] ?? [];
//     return postsData.map<Post>((json) => Post.fromJson(json)).toList();
//   } else {
//     throw Exception('Error fetching posts by category: ${response.statusCode}');
//   }
// }

//   // Future<List<Post>> fetchPosts(int userId, {String? category, required int page}) async {
//   //   String url = '${baseUrl}posts?user_id=$userId';
//   //   if (category != null && category != 'Todos') {
//   //     url += '&category=${Uri.encodeComponent(category)}';
//   //   }

//   //   final token = await getToken();

//   //   final response = await http.get(
//   //     Uri.parse(url),
//   //     headers: {
//   //       'Accept': 'application/json',
//   //       if (token != null) 'Authorization': 'Bearer $token',
//   //     },
//   //   );

//   //   if (response.statusCode == 200) {
//   //     final data = jsonDecode(response.body);
//   //     List postsData = data['posts'] ?? [];
//   //     return postsData.map<Post>((json) => Post.fromJson(json)).toList();
//   //   } else {
//   //     throw Exception('Error fetching posts: ${response.statusCode}');
//   //   }
//   // } 
//  //poner token para que se obtenga el usuario
//   Future<List<String>> fetchCategorias() async {
//     final response = await http.get(Uri.parse('${baseUrl}categorias'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       List categoriasData = data['data'] ?? [];
//       return categoriasData.map<String>((c) => c['nameCategoria'] as String).toList();
//     } else {
//       throw Exception('Error fetching categories: ${response.statusCode}');
//     }
//   }

//   Future<Map<String, dynamic>?> fetchUserData(int userId) async {
//   print('Llamando a fetchUserData para el usuario $userId');
//   try {
//     final response = await http
//         .get(Uri.parse('${baseUrl}usuario/$userId'))
//         .timeout(const Duration(seconds: 10));
//     print('Respuesta de fetchUserData: ${response.body}');
//     if (response.statusCode == 200) {
//       final decoded = jsonDecode(response.body);
// return decoded['usuario'];  
//     } else {
//       throw Exception('Error al obtener usuario: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error de red al obtener datos del usuario: $e');
//     return null;
//   }
// }


//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//   }

//   // Helpers para URLs de imágenes
//   String getUserAvatarUrl(String? fileName) {
//     const baseUrl = 'https://iidlive.com/';
//     if (fileName == null || fileName.isEmpty) {
//       return '${baseUrl}plataforma/perfil/avatar.png';
//     }
//     if (fileName.startsWith('uploads/avatars/')) {
//       return baseUrl + fileName;
//     }
//     return baseUrl + 'uploads/avatars/' + fileName;
//   }
// String getImageUrl(String? imagePath) {
//   const baseUrl = 'https://www.iidlive.com/uploads/posts/';
//   if (imagePath == null || imagePath.isEmpty) {
//     return '';  // o una URL de imagen placeholder
//   }
//   if (imagePath.startsWith('http')) {
//     return imagePath;
//   }
//   // Evitar duplicar la ruta uploads/posts/ si ya está incluida
//   if (imagePath.startsWith('uploads/posts/')) {
//     return 'https://www.iidlive.com/' + imagePath;
//   }
//   return baseUrl + imagePath;
// }

//   // String getImageUrl(String? imagePath) {
//   //   const baseUrl = 'https://www.iidlive.com/uploads/posts/';
//   //   if (imagePath == null || imagePath.isEmpty) {
//   //     return '';
//   //   }
//   //   if (imagePath.startsWith('http')) {
//   //     return imagePath;
//   //   }
//   //   return baseUrl + imagePath;
//   // }

// }

// // Helpers para links de YouTube y abrir URLs
// class LinkUtils {
//   static String extractYouTubeId(String url) {
//     final RegExp regExp = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*');
//     final match = regExp.firstMatch(url);
//     return match != null ? match.group(1)! : '';
//   }

//   static Future<void> openUrl(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }
//   static Future<Metadata?> fetchMetadata(String url) async {
//     try {
//       return await MetadataFetch.extract(url);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Future<Map<String, dynamic>?> _getUserData(int userId) async {
// //   const String baseUrl = 'https://iidlive.com/api/usuario/'; // Ajusta si es necesario.
// //   try {
// //     final response = await http.get(Uri.parse('$baseUrl$userId'));
// //     if (response.statusCode == 200) {
// //       final data = jsonDecode(response.body);
// //       return data;
// //     } else {
// //       print('Error al obtener datos del usuario: ${response.statusCode}');
// //       return null;
// //     }
// //   } catch (e) {
// //     print('Error de red al obtener datos del usuario: $e');
// //     return null;
// //   }
// // }
// // Future<void> _logout(BuildContext context) async {
// //   final prefs = await SharedPreferences.getInstance();
// //   await prefs.remove('token'); // o el nombre de tu key para el token

// //   // Redirigir al login (ajusta la ruta si es necesario)
// //   Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
// // }
//   // String _extractYouTubeId(String url) {
//   //   final RegExp regExp = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*');
//   //   final match = regExp.firstMatch(url);
//   //   return match != null ? match.group(1)! : '';
//   // }

//   // Future<void> _openUrl(String url) async {
//   //   final uri = Uri.parse(url);
//   //   if (await canLaunchUrl(uri)) {
//   //     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   //   }
//   // }

// }
  // Future<List<Post>> fetchPosts(String category, {required int page, required int userId}) async {
  //   final token = await getToken();
  //   final url = '${baseUrl}posts?categoria=${Uri.encodeComponent(category)}&page=$page';

  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       'Accept': 'application/json',
  //       if (token != null) 'Authorization': 'Bearer $token',
  //     },
  //   );

  //   print('fetchPosts response: ${response.body}');
  //   print('fetchAllPosts response: ${response.body}');

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (!data.containsKey('posts')) {
  //       throw Exception('La respuesta no contiene "posts". Data: $data');
  //     }
  //     List postsData = data['posts'];
  //     return postsData.map<Post>((json) => Post.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Error fetching posts by category: ${response.statusCode}');
  //   }
  // }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dren/models/post.dart';

class ApiService {
  static const String baseUrl = 'https://iidlive.com/api/';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  /**
   * para el usario pueda obtener los posts de todos los usarios
   * y la de los seguidores, asi como sus reacciones y sus comentarios
   */
Future<List<Post>> fetchAllPosts({required int page, String? category}) async {
    final token = await getToken(); // ahora sí funcionará

    final uri = Uri.parse('${baseUrl}posts/inicio').replace(queryParameters: {
  'page': page.toString(),
  if (category != null && category.isNotEmpty && category != 'Todos')
    'categoria': Uri.encodeComponent(category),
});

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final postsData = data['posts'] ?? [];
      
      return postsData.map<Post>((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener posts: ${response.statusCode}');
    }
  }

  Future<List<String>> fetchCategorias() async {
    final response = await http.get(Uri.parse('${baseUrl}categorias'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List categoriasData = data['data'] ?? [];
      return categoriasData.map<String>((c) => c['nameCategoria'] as String).toList();
    } else {
      throw Exception('Error fetching categories: ${response.statusCode}');
    }
  }


  Future<Map<String, dynamic>?> fetchUserData(int userId) async {
    print('Llamando a fetchUserData para el usuario $userId');
    try {
      final response = await http
          .get(Uri.parse('${baseUrl}usuario/$userId'))
          .timeout(const Duration(seconds: 10));
      print('Respuesta de fetchUserData: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['usuario'];
      } else {
        throw Exception('Error al obtener usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de red al obtener datos del usuario: $e');
      return null;
    }
  }
  /**
   * muestra las imagenes de los posts de los usarios
   * @param imagePath la ruta de la imagen
   * @return la url completa de la imagen
   */
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  String getUserAvatarUrl(String? fileName) {
    const baseUrl = 'https://iidlive.com/';
    if (fileName == null || fileName.isEmpty) {
      return '${baseUrl}plataforma/perfil/avatar.png';
    }
    if (fileName.startsWith('uploads/avatars/')) {
      return baseUrl + fileName;
    }
    return baseUrl + 'uploads/avatars/' + fileName;
  }

  String getImageUrl(String? imagePath) {
    const baseUrl = 'https://www.iidlive.com/uploads/posts/';
    if (imagePath == null || imagePath.isEmpty) {
      return '';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    if (imagePath.startsWith('uploads/posts/')) {
      return 'https://www.iidlive.com/' + imagePath;
    }
    return baseUrl + imagePath;
  }
Future<Map<String, dynamic>> fetchPostById(int postId) async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse('${baseUrl}posts/$postId'),
    headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['post']; // asumiendo que el backend devuelve 'post'
  } else {
    throw Exception('Error al obtener el post: ${response.body}');
  }
}

}
