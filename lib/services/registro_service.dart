import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistroService {
  final String baseUrl = 'https://iidlive.com/api/register'; // usa tu ruta real

  Future<String?> registrarUsuario({
    required String nombre,
    required String nombreUsuario,
    required String email,
    required String password,
    required String fechanac,
  }) async {
    try {
      final response = await http.post(
  Uri.parse(baseUrl),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'nombre': nombre,
    'nombreusuario': nombreUsuario,
    'email': email,
    'password': password,
    'fechanac': fechanac,
  }),
);

print('🟡 Status: ${response.statusCode}');
print('🟡 Body: ${response.body}');

try {
  final data = jsonDecode(response.body);
  if (response.statusCode == 201 || data['message'] == 'Registro exitoso') {
    return null;
  } else {
    return data['message'] ?? 'Error desconocido';
  }
} catch (e) {
  print('🔴 Error al parsear JSON: $e');
  return 'Error al procesar la respuesta del servidor: ${response.body}';
}
    } catch (e) {
      print('🔴 Error al registrar usuario: $e');
      return 'Error al conectar con el servidor';
    } 
  }
}
