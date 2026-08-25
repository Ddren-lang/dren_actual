import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dren/models/usuarioperfil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({Key? key}) : super(key: key);

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController nombreController;
  late TextEditingController usuarioController;
  late TextEditingController emailController;
  late TextEditingController direccionController;
  late TextEditingController paisController;
  late TextEditingController ciudadController;
  late TextEditingController codigopostalController;
  late TextEditingController descripcionController;

  File? _imagen;
  String? _rutaImagen;
  Usuario? usuario; // Cambié el tipo de Map<String, dynamic> a Usuario

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    usuario = ModalRoute.of(context)!.settings.arguments
        as Usuario?; // Usamos Usuario

    // Ahora, inicializa los controladores con los valores de usuario
    nombreController = TextEditingController(text: usuario?.nombre ?? '');
    usuarioController =
        TextEditingController(text: usuario?.nombreusuario ?? '');
    emailController = TextEditingController(text: usuario?.email ?? '');
    direccionController = TextEditingController(text: usuario?.direccion ?? '');
    paisController = TextEditingController(text: usuario?.pais ?? '');
    ciudadController = TextEditingController(text: usuario?.ciudad ?? '');
    codigopostalController = TextEditingController(
      text: usuario?.codigopostal.toString() ?? '',
    );

    descripcionController =
        TextEditingController(text: usuario?.descripcion ?? '');
    _rutaImagen = usuario?.fotos; // Ruta actual de la imagen
  }

  Future<void> _seleccionarImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagenSeleccionada =
        await picker.pickImage(source: ImageSource.gallery);

    if (imagenSeleccionada != null) {
      setState(() {
        _imagen = File(imagenSeleccionada.path);
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (usuario == null || usuario!.id == null) {
      _mostrarError('No se ha recibido el ID del usuario');
      return;
    }

    final uri = Uri.parse('https://iidlive.com/api/update');
    final request = http.MultipartRequest('POST', uri);
    String sanitizeUtf8(String input) {
      try {
        return utf8.decode(utf8.encode(input));
      } catch (e) {
        return input.replaceAll(
            RegExp(r'[^\x00-\x7F]'), ''); // elimina caracteres no válidos
      }
    }

    // Campos de texto del formulario
    request.fields['id'] = usuario!.id.toString();
    request.fields['nombre'] = sanitizeUtf8(nombreController.text.trim());
    request.fields['nombreusuario'] =
        sanitizeUtf8(usuarioController.text.trim());
    request.fields['direccion'] = sanitizeUtf8(direccionController.text.trim());
    request.fields['pais'] = sanitizeUtf8(paisController.text.trim());
    request.fields['ciudad'] = sanitizeUtf8(ciudadController.text.trim());
    request.fields['codigopostal'] =
        sanitizeUtf8(codigopostalController.text.trim());
    request.fields['descripcion'] =
        sanitizeUtf8(descripcionController.text.trim());
    final codigoPostal = codigopostalController.text.trim();
    if (!RegExp(r'^\d+$').hasMatch(codigoPostal)) {
      _mostrarError('El código postal solo debe contener números.');
      return;
    }
// request.fields['codigopostal'] = codigoPostal;
//   request.fields['descripcion'] = descripcionController.text.trim();

    // Adjuntar imagen si hay, si no enviar la imagen actual
    if (_imagen != null) {
      try {
        final multipartFile =
            await http.MultipartFile.fromPath('fotos', _imagen!.path);
        request.files.add(multipartFile);
      } catch (e) {
        print('Error al adjuntar la imagen: $e');
        _mostrarError('No se pudo adjuntar la imagen seleccionada.');
        return;
      }
    } else if (_rutaImagen != null && _rutaImagen!.isNotEmpty) {
      request.fields['foto_actual'] = _rutaImagen!;
    }

    try {
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      final respStr = await streamedResponse.stream.bytesToString();

      print('Respuesta sin procesar: $respStr');

      // Intenta decodificar como JSON
      dynamic decoded;
      try {
        decoded =
            jsonDecode(utf8.decode(respStr.runes.toList())); // Asegura UTF-8
      } catch (e) {
        _mostrarError(
            'Respuesta inesperada del servidor: no es un JSON válido.');
        print('Error al decodificar JSON: $e');
        return;
      }

      if (decoded is! Map<String, dynamic>) {
        _mostrarError('Respuesta inesperada del servidor: formato incorrecto.');
        print('JSON no es un Map: ${decoded.runtimeType}');
        return;
      }

      final responseData = decoded;

      if (streamedResponse.statusCode == 200 &&
          responseData['status'] == 'success' &&
          responseData.containsKey('usuario')) {
        usuario = Usuario.fromJson(responseData['usuario']);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Perfil actualizado con éxito')),
        // );
        Navigator.pop(context, usuario);
      } else {
        print('Error recibido del servidor: $responseData');
        _mostrarError(responseData['message'] ?? 'Error al guardar datos');
      }
    } on SocketException {
      _mostrarError(
          'No se pudo conectar al servidor. Verifica tu conexión a internet.');
    } on TimeoutException {
      _mostrarError('Tiempo de conexión agotado. Intenta de nuevo más tarde.');
    } catch (e) {
      _mostrarError('Error inesperado al enviar la petición.');
      print('Excepción: $e');
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return; // <-- evita ejecutar si el widget ya fue desmontado
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String getAvatarUrl(String? fileName) {
    const baseUrl = 'https://iidlive.com/';
    if (fileName == null || fileName.isEmpty) {
      return '${baseUrl}plataforma/perfil/avatar.png';
    }
    return fileName.startsWith('uploads/avatars/')
        ? '$baseUrl$fileName'
        : '${baseUrl}uploads/avatars/$fileName';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFFC17C9C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20), // igual que en la otra vista
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _seleccionarImagen,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imagen != null
                      ? FileImage(_imagen!)
                      : (_rutaImagen != null && _rutaImagen!.isNotEmpty)
                          ? NetworkImage(getAvatarUrl(_rutaImagen))
                          : const AssetImage('assets/avatar.png')
                              as ImageProvider,
                  child: _imagen == null &&
                          (_rutaImagen == null || _rutaImagen!.isEmpty)
                      ? const Text(
                          'Añadir Foto',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField('Nombre', nombreController),
            _buildTextField('Nombre de usuario', usuarioController),
            _buildTextField('Correo electrónico', emailController,
                enabled: false), // correo no editable
            _buildTextField('Dirección', direccionController),
            _buildTextField('Ciudad', ciudadController),
            _buildTextField('País', paisController),
            _buildTextField('Código Postal', codigopostalController,
                isNumeric: true),
            _buildTextField('Descripción', descripcionController,
                isMultiline: true),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7f4c51),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Guardar Cambios',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: _guardarCambios,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, bool isNumeric = false, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric
            ? TextInputType.number
            : (isMultiline ? TextInputType.multiline : TextInputType.text),
        maxLines: isMultiline ? null : 1,
        inputFormatters:
            isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        enabled: enabled,
      ),
    );
  }
}
