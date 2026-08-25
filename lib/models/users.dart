class User {
  final int id;
  final String nombre;  // aquí cambié name a nombre
  final String email;
  final String fotos;

  User({required this.id, required this.nombre, required this.email,required this.fotos,});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],  // aquí también
      email: json['email'],
       fotos: json['fotos']?.toString() ?? '',
    );
  }
}
