import 'package:flutter/material.dart';
import '../models/usuarioperfil.dart';

class CustomDrawer extends StatelessWidget {
  final Usuario usuario;
  final BuildContext parentContext;
  final VoidCallback onLogout;

  const CustomDrawer({
    Key? key,
    required this.usuario,
    required this.parentContext,
    required this.onLogout,
  }) : super(key: key);

  // Función para obtener URL completa del avatar del usuario
  String getAvatarUrl(String? fileName) {
    const baseUrl = 'https://iidlive.com/';
    if (fileName == null || fileName.isEmpty) {
      return '${baseUrl}plataforma/perfil/avatar.png'; // avatar por defecto
    }
    if (fileName.startsWith('uploads/avatars/')) {
      return baseUrl + fileName;
    }
    return baseUrl + 'uploads/avatars/' + fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFC17C9C)),
              accountName: Text(usuario.nombre),
              accountEmail: Text(usuario.email),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(parentContext, '/perfil');
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (usuario.fotos.isNotEmpty)
                      ? NetworkImage(getAvatarUrl(usuario.fotos))
                      : null,
                  child: (usuario.fotos.isEmpty)
                      ? Text(
                          (usuario.nombre.isNotEmpty)
                              ? usuario.nombre[0].toUpperCase()
                              : 'N',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Página de Inicio', context, '/home'),
            _buildDrawerItem(
                Icons.video_collection, 'Página de Reels', context, '/reels'),
            _buildDrawerItem(
                Icons.post_add, 'Página de Post', context, '/post'),
            _buildDrawerItem(Icons.follow_the_signs,'Segidores', context, '/followers'),
            _buildDrawerItem(Icons.people, 'Seguidos', context, '/following'),
            _buildDrawerItem(
                Icons.settings, 'Configuraciones', context, '/settings'),
            _buildDrawerItem(Icons.help, 'Ayuda', context, '/help'),
            ListTile(
              tileColor: Colors.grey[100],
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(
      IconData icon, String title, BuildContext context, String routeName) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}
