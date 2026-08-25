import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dren/models/usuarioperfil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dren/widgets/custom_drawer.dart';

class CreatePostPage extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> usuario;

  const CreatePostPage({
    Key? key,
    required this.userId,
    this.usuario = const {},
  }) : super(key: key);

  static CreatePostPage fromArguments(Map<String, dynamic> args) {
    return CreatePostPage(
      userId: args['userId'] ?? 0,
      usuario: args['usuario'] ?? {},
    );
  }

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostPage> {
  final TextEditingController _descripcionController = TextEditingController();
  File? _image;
  int? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("Usuario recibido: ${widget.usuario}");
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse("https://iidlive.com/api/categorias"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['data'] != null) {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          throw Exception("La respuesta no contiene categorías.");
        }
      } else {
        throw Exception("Error al obtener las categorías. Código: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al obtener categorías: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

 Future<void> createPost({
  required BuildContext context,
  required String descripcion,
  required int categoriaId,
  File? image,
}) async {
  final uri = Uri.parse("https://iidlive.com/api/posts/store");

  var request = http.MultipartRequest('POST', uri)
  
    ..fields['content'] = descripcion
    ..fields['user_id'] = widget.userId.toString()
    ..fields['category'] = categoriaId.toString()
    ..fields['published_at'] = DateTime.now().toIso8601String()
    ..headers['Accept'] = 'application/json';

  if (image != null) {
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
  }

  try {
    final streamedResponse = await request.send();
    final responseString = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
      final result = jsonDecode(responseString);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['mensaje'] ?? 'Post creado con éxito')),
      );
    } else {
      print("❌ Error al crear post: $responseString");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al crear post: $responseString")),
      );
    }
  } catch (e) {
    print('❌ Error al crear el post: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear el post: $e')),
    );
  }
}

  Future<void> _handleCreatePost() async {
    final descripcion = _descripcionController.text.trim();

    if (descripcion.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    await createPost(
  context: context,
  descripcion: descripcion,
  categoriaId: _selectedCategory!,
  image: _image,
);

    setState(() {
      _isLoading = false;
      _descripcionController.clear();
      _selectedCategory = null;
      _image = null;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }


  Future<Map<String, dynamic>?> _getUserData(int userId) async {
    final response = await http.get(Uri.parse('https://iidlive.com/api/usuario/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['usuario'];
    } else {
      print("❌ Error al obtener usuario $userId");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Post"),
        backgroundColor: const Color(0xFFC17C9C),
      ),
      drawer: CustomDrawer(
        usuario: Usuario.fromJson(widget.usuario),
        parentContext: context,
        onLogout: () => _logout(context),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.teal.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  hintText: 'Escribe algo interesante...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              const Text("Selecciona una categoría", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _categories.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFC17C9C)),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedCategory,
                        decoration: const InputDecoration.collapsed(hintText: ""),
                        hint: const Text("Selecciona una categoría"),
                        onChanged: (value) => setState(() => _selectedCategory = value),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: int.parse(cat["id"].toString()),
                            child: Text(cat["nameCategoria"]),
                          );
                        }).toList(),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: _image == null
                    ? const Text("No se ha seleccionado ninguna imagen.")
                    : Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Seleccionar Imagen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC17C9C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _handleCreatePost,
                        icon: const Icon(Icons.send),
                        label: const Text("Crear Post"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC17C9C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
