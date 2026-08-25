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
    final userData = json['user'] ?? json;

    return Usuario(
      id: userData['id'] is int
          ? userData['id']
          : int.tryParse(userData['id'].toString()),
      nombre: userData['nombre']?.toString() ?? '',
      nombreusuario: userData['nombreusuario']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      direccion: userData['direccion']?.toString() ?? '',
      ciudad: userData['ciudad']?.toString() ?? '',
      pais: userData['pais']?.toString() ?? '',
      codigopostal: userData['codigopostal'] != null
    ? (userData['codigopostal'] is int 
        ? userData['codigopostal'] 
        : int.tryParse(userData['codigopostal'].toString()))
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
      'codigopostal': codigopostal,
      'descripcion': descripcion,
      'fotos': fotos,
    };
  }
}
