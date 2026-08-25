import 'comments.dart';
class Reel {
  final int id;
  final String nombre;
  final String descripcion;
  final DateTime createdAt;
  final String userName;
  final String? userAvatar;
  int likes;
  int commentsCount;
    String? reaccionUsuario; // Nueva propiedad para la reacción del usuario
   Map<String, int>? reaccionesTotales;
List<Comment>? comentarios;
  Reel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.createdAt,
    required this.userName,
    this.userAvatar,
    required this.likes,
    required this.commentsCount,
      this.reaccionUsuario,
    this.reaccionesTotales,
    this.comentarios
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
  final user = json['user'] ?? {};
    Map<String, int>? reacciones = {};
  if (json['reaccionesTotales'] != null && json['reaccionesTotales'] is Map) {
    json['reaccionesTotales'].forEach((key, value) {
      if (value is int) {
        reacciones![key] = value;
      }
    });
  }
   List<Comment> comentarioss = [];
  if (json['comentarios'] != null && json['comentarios'] is List) {
    comentarioss = (json['comentarios'] as List)
        .map((c) {
          print('Comentario JSON: $c');
          return Comment.fromJson(c);
        })
        .toList();
    print('Cantidad de comentarios parseados: ${comentarioss.length}');
  }

  return Reel(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'] ?? '',
    createdAt: DateTime.parse(json['created_at']),
    userName: user['nombre'] ?? '',
    userAvatar: (user['fotos'] != null && user['fotos'].toString().isNotEmpty)
        ? user['fotos']
        : 'avatar.png',
    likes: json['likes_count'] ?? 0,
    commentsCount: json['commentsCount'] ?? 0,
     reaccionUsuario: json['reaccionUsuario'],
    reaccionesTotales: reacciones,
    comentarios: comentarioss,
  );
}

  String get videoUrl {
    // Ajusta esta URL base según dónde tengas alojados tus videos
    return 'https://iidlive.com/storage/reels/$nombre';
  }
}

