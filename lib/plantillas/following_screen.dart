import 'package:flutter/material.dart';
import 'package:dren/models/following.dart';
import 'package:dren/models/usuarioperfil.dart';
import 'package:dren/widgets/custom_drawer.dart';

import '../services/following_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowingScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> usuario;

  const FollowingScreen({
    super.key,
    required this.userId,
    this.usuario = const {},
  });

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushReplacementNamed(context, '/login');
}

String getUserAvatarUrl(String? fileName) {
  const baseUrl = 'https://iidlive.com/';
  if (fileName == null || fileName.isEmpty) {
    return '${baseUrl}plataforma/perfil/avatar.png';
  }
  if (fileName.startsWith('uploads/avatars/')) {
    return baseUrl + fileName;
  }
  return baseUrl + 'uploads/avatars/' + fileName;
}

class _FollowingScreenState extends State<FollowingScreen> {
  late Future<List<Following>> _followingFuture;
  late FollowingService _followingService;

  @override
  void initState() {
    super.initState();
    _followingService = FollowingService();
    _followingFuture = _followingService.getFollowing(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguidos')),
      drawer: CustomDrawer(
        usuario: Usuario.fromJson(widget.usuario),
        parentContext: context,
        onLogout: () => _logout(context),
      ),
      body: FutureBuilder<List<Following>>(
        future: _followingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final following = snapshot.data!;
            if (following.isEmpty) {
              return const Center(child: Text('No sigues a nadie todavía.'));
            }
            return ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                final user = following[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    foregroundImage:
                        NetworkImage(getUserAvatarUrl(user.userAvatar)),
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        user.isFollowing = !user.isFollowing;
                        // Aquí deberías llamar a la API para seguir/dejar de seguir
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          user.isFollowing ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    child: Text(
                      user.isFollowing ? 'Siguiendo' : 'Seguir',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
