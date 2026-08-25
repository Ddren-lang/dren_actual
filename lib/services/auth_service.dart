import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // URL base de la API
  // Puedes cambiar esta URL según tu entorno de desarrollo o producción
  // Con autenticacon de usarios 
  /** la cual si el usario no ha autenticado el correo no puede acceder
   * para lo cual se le envia un correo de verificacion
   * y si el correo no esta verificado se le envia un mensaje de error 
   */
  static const String _baseUrl = 'https://iidlive.com/api';
static Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      if (data.containsKey('token')) {
        await prefs.setString('token', data['token']);
      }
      await prefs.setString('usuario', jsonEncode(data['usuario']));
      await prefs.setString('userId', data['usuario']['id'].toString());

      return {'success': true, 'message': 'Login correcto'};
    } else if (response.statusCode == 403) {
      // Correo no verificado
      return {'success': false, 'message': data['message'] ?? 'Correo no verificado'};
    }

    return {'success': false, 'message': data['message'] ?? 'Error al iniciar sesión'};
  } on SocketException {
    return {'success': false, 'message': 'Sin conexión a internet'};
  } on TimeoutException {
    return {'success': false, 'message': 'Tiempo de espera agotado'};
  } catch (e) {
    return {'success': false, 'message': 'Error inesperado: $e'};
  }
}

  /// Iniciar sesión y guardar token + usuario en SharedPreferences
  // static Future<Map<String, dynamic>> login(String email, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/login'),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Accept": "application/json",
  //       },
  //       body: jsonEncode({
  //         "email": email,
  //         "password": password,
  //       }),
  //     ).timeout(const Duration(seconds: 10));

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200 && data['status'] == 'success') {
  //       final prefs = await SharedPreferences.getInstance();

  //       // Guarda el token (si tu backend lo envía)
  //       if (data.containsKey('token')) {
  //         await prefs.setString('token', data['token']);
  //       }

  //       // Guarda el usuario completo como JSON
  //       await prefs.setString('usuario', jsonEncode(data['usuario']));

  //       // Guarda el ID del usuario
  //       await prefs.setString('userId', data['usuario']['id'].toString());

  //       return {'success': true, 'message': 'Login correcto'};
  //     }

  //     return {'success': false, 'message': data['message'] ?? 'Error al iniciar sesión'};
  //   } on SocketException {
  //     return {'success': false, 'message': 'Sin conexión a internet'};
  //   } on TimeoutException {
  //     return {'success': false, 'message': 'Tiempo de espera agotado'};
  //   } catch (e) {
  //     return {'success': false, 'message': 'Error inesperado: $e'};
  //   }
  // }

  /// Obtener token almacenado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario');
    await prefs.remove('userId');
  }
}
