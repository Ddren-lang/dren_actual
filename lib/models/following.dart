class Following {
  final int id;
  final String name;
  final String email;
  final String userAvatar;
  bool isFollowing;
   // Asumimos que siempre está siguiendo
  Following({
    required this.id,
    required this.name,
    required this.email,
    required this.userAvatar,
    this.isFollowing = false,
  });

  factory Following.fromJson(Map<String, dynamic> json) {
    
    return Following(
      id: json['id'],
      name: json['nombre'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
     userAvatar: (json['fotos'] != null && json['fotos'].toString().isNotEmpty)
      ? json['fotos']
      : 'avatar.png',
      isFollowing: json['isFollowing'] ?? false, 
    );
  }
}
