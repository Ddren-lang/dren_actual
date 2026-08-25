// // TODO Implement this library.
// class Usuario {
//   final String nombre;
//   final String nombreUsuario;
//   final String email;
//   final String pais;
//   final String direccion;
//   final String ciudad;
//   final String codigoPostal;
//   final String descripcion;
//   final String fotos;

//   Usuario({
//     required this.nombre,
//     required this.nombreUsuario,
//     required this.email,
//     required this.pais,
//     required this.direccion,
//     required this.ciudad,
//     required this.codigoPostal,
//     required this.descripcion,
//     required this.fotos,
//   });

//   // Método para convertir un JSON en un objeto Usuario
//   factory Usuario.fromJson(Map<String, dynamic> json) {
//     return Usuario(
//       nombre: json['nombre'] ?? '',
//       nombreUsuario: json['nombreusuario'] ?? '',
//       email: json['email'] ?? '',
//       pais: json['pais'] ?? '',
//       direccion: json['direccion'] ?? '',
//       ciudad: json['ciudad'] ?? '',
//       codigoPostal: json['codigopostal'] ?? '',
//       descripcion: json['descripcion'] ?? '',
//       fotos: json['fotos'] ?? '',
//     );
//   }
// }
class Usuario {
  final int? id;
  final String nombre;
  final String nombreusuario;
  final String email;
  final String direccion;
  final String ciudad;
  final String pais;
  final int? codigopostal;
  final String descripcion;
  final String fotos;

  Usuario({
    this.id,
    required this.nombre,
    required this.nombreusuario,
    required this.email,
    required this.direccion,
    required this.ciudad,
    required this.pais,
    required this.codigopostal,
    required this.descripcion,
    required this.fotos,
  });

factory Usuario.fromJson(Map<String, dynamic> json) {
  final userData = json['user'] ?? json; // Si está anidado, toma ese, sino el mismo json

  return Usuario(
    id: userData['id'] is int ? userData['id'] : int.tryParse(userData['id'].toString()),
    nombre: userData['nombre']?.toString() ?? '',
    nombreusuario: userData['nombreusuario']?.toString() ?? '',
    email: userData['email']?.toString() ?? '',
    direccion: userData['direccion']?.toString() ?? '',
    ciudad: userData['ciudad']?.toString() ?? '',
    pais: userData['pais']?.toString() ?? '',
    codigopostal: userData['codigo_postal'] != null
    ? int.tryParse(userData['codigo_postal'].toString())
    : null,
    descripcion: userData['descripcion']?.toString() ?? '',
    fotos: userData['fotos']?.toString() ?? '',
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombreusuario': nombreusuario,
      'email': email,
      'direccion': direccion,
      'ciudad': ciudad,
      'pais': pais,
      'codigo_postal': codigopostal,
      'descripcion': descripcion,
      'fotos': fotos,
    };
  }
}
