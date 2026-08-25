import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/usuarioperfil.dart';
import 'package:dren/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late Future<String?> _usuarioFuture;

  @override
  void initState() {
    super.initState();
    _usuarioFuture = _getUserData();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _usuarioFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Error al cargar los datos'));
        }

        final usuario = Usuario.fromJson(jsonDecode(snapshot.data!));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil de Usuario'),
            backgroundColor: const Color(0xFFC17C9C),
          ),
          drawer: CustomDrawer(
            usuario: usuario,
            parentContext: context,
            onLogout: () => _logout(context),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFc17c9c), Color(0xFF7f4c51)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Avatar con sombra y borde blanco
                    CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 85,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: usuario.fotos.isNotEmpty
                            ? NetworkImage(getAvatarUrl(usuario.fotos))
                            : null,
                        child: usuario.fotos.isEmpty
                            ? Text(
                                usuario.nombre.isNotEmpty
                                    ? usuario.nombre[0].toUpperCase()
                                    : 'N',
                                style: const TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7f4c51),
                                ),
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Tarjeta con info
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuario.nombre,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7f4c51),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '@${usuario.nombreusuario}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Divider(height: 30, thickness: 1),
                          infoRow(Icons.email, 'Correo:', usuario.email),
                          infoRow(
                              Icons.location_city, 'Ciudad:', usuario.ciudad),
                          infoRow(Icons.flag, 'País:', usuario.pais),
                          infoRow(Icons.home, 'Dirección:', usuario.direccion),
                          infoRow(
                            Icons.location_on,
                            'Código Postal:',
                            usuario.codigopostal != null
                                ? usuario.codigopostal.toString()
                                : 'Sin especificar',
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Descripción',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            usuario.descripcion,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7f4c51),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                'Editar Perfil',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/editar',
                                  arguments: usuario,
                                );

                                if (result != null && result is Usuario) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'usuario', jsonEncode(result.toJson()));

                                  setState(() {
                                    _usuarioFuture = Future.value(
                                        jsonEncode(result.toJson()));
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Widget auxiliar para mostrar icono y texto alineado
  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7f4c51)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.normal),
              softWrap: true, // permite salto de línea
              maxLines: null, // sin límite de líneas
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usuario');
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    Navigator.pushReplacementNamed(context, '/login');
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
}
