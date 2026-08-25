import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dren/models/usuarioperfil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:dren/widgets/custom_drawer.dart';

// ignore: must_be_immutable
class SubirReelPage extends StatefulWidget {
  int userId;
  final Map<String, dynamic> usuario;

  SubirReelPage({required this.userId, required this.usuario});

  @override
  _SubirReelPageState createState() => _SubirReelPageState();
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userData = prefs.getString('usuario');

  if (userData != null) {
    final userMap = jsonDecode(userData);
    return userMap['id'].toString();
  }
  return null;
}

class _SubirReelPageState extends State<SubirReelPage> {
  final _formKey = GlobalKey<FormState>();
  XFile? _reelFile;
  final _descripcionController = TextEditingController();
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Widget _buildVideoPreview() {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: VideoPlayer(_videoPlayerController!),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  Future<void> _selectFile() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      _videoPlayerController?.dispose();
      setState(() {
        _reelFile = pickedFile;
        _videoPlayerController =
            VideoPlayerController.file(File(_reelFile!.path))
              ..initialize().then((_) {
                setState(() {});
                _videoPlayerController!.play();
              });
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final descripcion = _descripcionController.text;

      if (_reelFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecciona un archivo para subir')),
        );
        return;
      }

      final userId = await getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encuentra el ID de usuario')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      Navigator.pop(context);

      final uri = Uri.parse("http://iidlive.com/api/reel/store");

      final request = http.MultipartRequest('POST', uri)
        ..fields['descripcion'] = descripcion
        ..fields['user_id'] = userId.toString()
        ..files.add(await http.MultipartFile.fromPath('video', _reelFile!.path));

      try {
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(responseBody);
          final mensaje = data['message'] ?? 'Reel subido exitosamente';

          setState(() {
            _descripcionController.clear();
            _reelFile = null;
            _videoPlayerController?.dispose();
            _videoPlayerController = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje)),
          );
        } else {
          final errorData = json.decode(responseBody);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error: ${errorData['message'] ?? responseBody}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con el servidor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subir Reels"),
        backgroundColor: const Color(0xFFC17C9C),
      ),
      drawer: CustomDrawer(
        usuario: Usuario.fromJson(widget.usuario),
        parentContext: context,
        onLogout: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Descripción",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    hintText: 'Escribe algo sobre el reel...',
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'La descripción no puede estar vacía' : null,
                ),
                const SizedBox(height: 20),
                Center(
                  child: _reelFile != null
                      ? _buildVideoPreview()
                      : const Text('No se ha seleccionado un video'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _selectFile,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Seleccionar Reel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC17C9C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Subir Reel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC17C9C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
