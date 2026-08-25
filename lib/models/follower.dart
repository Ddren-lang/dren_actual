// class Follower {
//   final int id;
//   final String name;
//   final String email;
//   final String userAvatar;
//     bool isFollowing;
//   Follower({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.userAvatar,
//     this.isFollowing = false,
//   });

//   factory Follower.fromJson(Map<String, dynamic> json) {
    
//     return Follower(
//       id: json['id'],
//       name: json['nombre'] ?? json['name'] ?? '',
//       email: json['email'] ?? '',
//      userAvatar: (json['fotos'] != null && json['fotos'].toString().isNotEmpty)
//       ? json['fotos']
//       : 'avatar.png',
//       isFollowing: json['isFollowing'] ?? false,
//     );
    
//   }
// }
class Follower {
  final int id;
  final String name;
  final String email;
  final String userAvatar;
  bool isFollowing;

  Follower({
    required this.id,
    required this.name,
    required this.email,
    required this.userAvatar,
    this.isFollowing = false,
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
  return Follower(
    id: json['id'],
    name: json['nombre'] ?? json['name'] ?? '',
    email: json['email'] ?? '',
    userAvatar: (json['fotos'] != null && json['fotos'].toString().isNotEmpty)
      ? json['fotos']
      : 'avatar.png',
    isFollowing: json['isFollowing'] ?? false,  // <- aquí depende del backend
  );
}
}
// class Follower {
//   final int id;
//   final String name;
//   final String email;
//   final String? userAvatar;
//   bool isFollowing;

//   Follower({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.userAvatar,
//     this.isFollowing = false,
//   });

//   factory Follower.fromJson(Map<String, dynamic> json) {
//     return Follower(
//       id: json['id'],
//       name: json['name'],
//       email: json['email'],
//       userAvatar: json['userAvatar'],
//       isFollowing: json['isFollowing'] ?? false, // Ojo con este campo
//     );
//   }
// }

  

