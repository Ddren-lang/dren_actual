
// import 'comment.dart';
// class Post {
//   final int id;
//   final String content;
//   final String? imageUrl;
//   final String userName;
//   final String nombre;
//   final String userAvatar;
//   final String createdAt;
//   final String nameCategoria; // Nueva propiedad
//    // Inicializado a 0 por defecto
//     List<Comment>? comentarios;
//    int likes;
//     int commentsCount;
//     String? reaccionUsuario; // Nueva propiedad para la reacción del usuario
//    Map<String, int>? reaccionesTotales;
//    List<Comment>? comments; // Lista de comentarios asociados al post
//   Post({
//     required this.id,
//     required this.content,
//     this.imageUrl,
//     required this.userName,
//     required this.nombre,
//     required this.userAvatar,
//     required this.createdAt,
//     required this.nameCategoria,
//     required this.likes,
//     required this.commentsCount,
//      this.comentarios,
//     this.reaccionUsuario,
//     this.reaccionesTotales,
    
//   });
// factory Post.fromJson(Map<String, dynamic> json) {
//   Map<String, int>? reacciones = {};
//   if (json['reaccionesTotales'] != null && json['reaccionesTotales'] is Map) {
//     json['reaccionesTotales'].forEach((key, value) {
//       if (value is int) {
//         reacciones![key] = value;
//       }
//     });
//   }
//    // Parsear comentarios
//   List<Post> posts = (json['posts'] as List)
//     .where((item) => item != null) // ← descarta nulos
//     .map((item) => Post.fromJson(item))
//     .toList();

//   return Post(
//     id: json['id'] ?? 0,
//     content: json['content'] ?? '',
//     imageUrl: (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty)
//         ? json['imageUrl']
//         : null,
//     userName: json['userName'] ?? '',
//     nombre: json['nombre'] ?? '',
//     userAvatar: (json['userAvatar'] != null && json['userAvatar'].toString().isNotEmpty)
//         ? json['userAvatar']
//         : 'avatar.png',
//     createdAt: json['created_at'] ?? '',
//     nameCategoria: json['nameCategoria'] ?? 'Sin categoría',
//     likes: 0, // Si no estás enviando 'likes_count' directamente
//     commentsCount: 0, // Igual si no hay 'comments_count'
//     reaccionUsuario: json['reaccionUsuario'],
//     reaccionesTotales: reacciones,
//        comentarios: (json['comentarios'] ?? []).map<Comment>((c) => Comment.fromJson(c)).toList(),

//   );
// }

// //   factory Post.fromJson(Map<String, dynamic> json) {
// //   final user = json['user'] ?? {};
// //    final category = json['category'] ?? {};
// //      // Mapeo de reacciones individuales
// //     Map<String, int>? reacciones = {};
// //     if (json['reacciones'] != null && json['reacciones'] is Map) {
// //       json['reacciones'].forEach((key, value) {
// //         if (value is int) {
// //           reacciones[key] = value;
// //         }
// //       });
// //     }
// //  // Esto te muestra directamente el avatar
// //   return Post(
// //     id: json['id'] ?? 0,
// //     content: json['content'] ?? '',
// //   imageUrl: (json['image'] != null && json['image'].toString().isNotEmpty)
// //     ? json['image']
// //     : null,
// //     nameCategoria: category['nameCategoria'] ?? '',
// //     userName: user['nombre'] ?? '',
// //     nombre: user['nombreusuario'] ?? '',
// //     userAvatar: (user['fotos'] != null && user['fotos'].toString().isNotEmpty)
// //     ? user['fotos']
// //     : 'avatar.png',
// //     createdAt: json['created_at'] ?? '',
// //       likes: json['likes_count'] ?? 0,
// // commentsCount: json['comments_count'] ?? 0,
// //    reaccionUsuario: json['reaccion_usuario'], // Este campo viene de la API
// //       reaccionesTotales: reacciones,
// //     // Asegúrate de que likes_count sea un entero 
// //   );
// // }

// }
import 'comment.dart';

class Post {
  final int id;
  final String content;
  final String? imageUrl;
  final String userName;
  final String nombre;
  final String userAvatar;
  final String createdAt;
  final String nameCategoria;
  final int likes;
  final int commentsCount;
   String? reaccionUsuario;
   Map<String, int>? reaccionesTotales;
   List<Comment>? comentarios;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.userName,
    required this.nombre,
    required this.userAvatar,
    required this.createdAt,
    required this.nameCategoria,
    required this.likes,
    required this.commentsCount,
    this.reaccionUsuario,
    this.reaccionesTotales,
    this.comentarios,
  });

 factory Post.fromJson(Map<String, dynamic> json) {
  // Reacciones
  Map<String, int> reacciones = {};
  if (json['reaccionesTotales'] != null && json['reaccionesTotales'] is Map) {
    json['reaccionesTotales'].forEach((key, value) {
      if (value is int) {
        reacciones[key] = value;
      }
    });
  }

  // Comentarios
  List<Comment> comentarios = [];
  if (json['comentarios'] != null && json['comentarios'] is List) {
    comentarios = (json['comentarios'] as List)
        .map((c) {
          print('Comentario JSON: $c');
          return Comment.fromJson(c);
        })
        .toList();
    //print('Cantidad de comentarios parseados: ${comentarios.length}');
  }

    return Post(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      imageUrl: (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty)
          ? json['imageUrl']
          : null,
      userName: json['userName'] ?? '',
      nombre: json['nombre'] != null ? json['nombre'].toString() : 'Usuario',

      userAvatar: json['userAvatar'] ?? 'avatar.png',
      createdAt: json['created_at'] ?? '',
      nameCategoria: json['nameCategoria'] ?? 'Sin categoría',
      likes: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      reaccionUsuario: json['reaccionUsuario'],
      reaccionesTotales: reacciones,
      comentarios: comentarios,
    );
  }
}
