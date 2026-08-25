import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecuperarContrasena extends StatefulWidget {
  const RecuperarContrasena({super.key});

  @override
  State<RecuperarContrasena> createState() => _RecuperarContrasenaState();
}

class _RecuperarContrasenaState extends State<RecuperarContrasena> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _enviarCorreoRecuperacion() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !_isValidEmail(email)) {
      _mostrarError("Ingresa un correo electrónico válido.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
          Uri.parse("https://iidlive.com/api/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _mostrarMensaje("Correo de recuperación enviado.");
      } else {
        _mostrarError(data['message'] ?? "No se pudo enviar el correo.");
      }
    } catch (e) {
      _mostrarError("Error de conexión con el servidor.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(email);
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.green),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar Contraseña"),
        backgroundColor: const Color(0xFFE86CA6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Introduce tu correo electrónico para enviarte un enlace de recuperación.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                prefixIcon: const Icon(Icons.email, color: Color(0xFF673AB7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _enviarCorreoRecuperacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE86CA6),
                         foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Enviar correo",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "Volver al login",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
