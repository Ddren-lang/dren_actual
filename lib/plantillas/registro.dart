//import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dren/services/registro_service.dart';

class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Usuario"),
        backgroundColor: const Color(0xFFE86CA6),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildTextField(_nombreController, "Nombre completo", Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField(_nombreUsuarioController, "Nombre de Usuario", Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildTextField(_correoController, "Correo Electrónico", Icons.email),
                  const SizedBox(height: 10),
                  _buildPasswordField(_passwordController, "Contraseña", Icons.lock, true),
                  const SizedBox(height: 10),
                  _buildPasswordField(_confirmPasswordController, "Confirmar Contraseña", Icons.lock_outline, false),
                  const SizedBox(height: 10),
                  _buildDatePickerField(),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE86CA6),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: registerUser,
                            child: const Text(
                              "Registrarse",
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          icon: Icon(
            isPassword
                ? (_isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                : (_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
            color: Colors.deepPurple,
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _isPasswordVisible = !_isPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return TextField(
      controller: _birthDateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Fecha de Nacimiento",
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }
Future<void> registerUser() async {
  if (!_validateFields()) return;

  setState(() {
    _isLoading = true;
  });

  final registroService = RegistroService();
  final error = await registroService.registrarUsuario(
    nombre: _nombreController.text,
    nombreUsuario: _nombreUsuarioController.text,
    email: _correoController.text,
    password: _passwordController.text,
    fechanac: _birthDateController.text,
  );

  setState(() {
    _isLoading = false;
  });

  if (error == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registro exitoso. Revisa tu correo para verificar tu cuenta.")),
    );

    Navigator.pushReplacementNamed(context, '/login');
  } else {
    _showError(error);
  }
}

  bool _validateFields() {
    if (_nombreController.text.isEmpty ||
        _nombreUsuarioController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _birthDateController.text.isEmpty) {
      _showError("Por favor complete todos los campos");
      return false;
    }

    if (!_isValidEmail(_correoController.text)) {
      _showError("Correo electrónico inválido");
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Las contraseñas no coinciden");
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

  // Future<void> _registerUser() async {
  //   if (!_validateFields()) return;

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final response = await http.post(
  //       Uri.parse("http://192.168.50.54:8080/plataforma/registro.php"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "nombre": _nombreController.text,
  //         "nombreUsuario": _nombreUsuarioController.text,
  //         "password": _passwordController.text,
  //         "email": _correoController.text,
  //         "fechanac": _birthDateController.text,
  //       }),
  //     );

  //     final responseData = jsonDecode(response.body);
  //     if (response.statusCode == 200 && responseData['message'] == 'Registro exitoso') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Registro exitoso")),
  //       );

  //       Navigator.pushReplacementNamed(
  //         context,
  //         '/home',
  //         arguments: {
  //           'nombre': _nombreController.text,
  //           'nombreUsuario': _nombreUsuarioController.text,
  //           'email': _correoController.text,
  //           'fechanac': _birthDateController.text,
  //         },
  //       );
  //     } else {
  //       _showError(responseData['message']);
  //     }
  //   } catch (e) {
  //     _showError("Error al conectar con el servidor");
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }