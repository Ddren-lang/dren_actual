// import 'package:flutter/material.dart';
// import 'package:iidlive_app/models/usuarioperfil.dart';
// import 'package:iidlive_app/widgets/custom_drawer.dart'; // <-- Aquí el import del drawer
// import '../models/follower.dart';
// import '../services/follower_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class FollowersScreen extends StatefulWidget {
//   final int userId;

//   final Map<String, dynamic> usuario;

//   const FollowersScreen({
//     super.key,
//     required this.userId,
//     this.usuario = const {},
//   });

//   @override
//   State<FollowersScreen> createState() => _FollowersScreenState();
// }

// Future<void> _logout(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.clear();
//   Navigator.pushReplacementNamed(context, '/login');
// }
//  String getUserAvatarUrl(String? fileName) {
//     const baseUrl = 'https://iidlive.com/';
//     if (fileName == null || fileName.isEmpty) {
//       return '${baseUrl}plataforma/perfil/avatar.png'; // avatar por defecto
//     }
//     if (fileName.startsWith('uploads/avatars/')) {
//       return baseUrl + fileName;
//     }
//     return baseUrl + 'uploads/avatars/' + fileName;
//   }

// class _FollowersScreenState extends State<FollowersScreen> {
//   late Future<List<Follower>> _followersFuture;
//   late FollowerService _followerService;

//   @override
//   void initState() {
//     super.initState();
//     _followerService = FollowerService(); // sin parámetros
//     _followersFuture = _followerService.getFollowers(widget.userId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Seguidores')),
//       drawer: CustomDrawer(
//         usuario: Usuario.fromJson(widget.usuario),
//         parentContext: context,
//         onLogout: () => _logout(context),
//       ), // <---- Aquí agregas el Drawer personalizado
//       body: FutureBuilder<List<Follower>>(
//         future: _followersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             final followers = snapshot.data!;
//             if (followers.isEmpty) {
//               return const Center(child: Text('No tienes seguidores todavía.'));
//             }
//             return ListView.builder(
//               itemCount: followers.length,
//               itemBuilder: (context, index) {
//                 final follower = followers[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     radius: 20,
//                     foregroundImage:
//                         NetworkImage(getUserAvatarUrl(follower.userAvatar)),
//                     backgroundColor: Colors.grey[200],
//                   ),
//                   title: Text(follower.name),
//                   subtitle: Text(follower.email),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:dren/models/usuarioperfil.dart';
import 'package:dren/widgets/custom_drawer.dart';
import '../models/follower.dart';
import '../services/follower_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowersScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> usuario;

  const FollowersScreen({
    super.key,
    required this.userId,
    this.usuario = const {},
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
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

class _FollowersScreenState extends State<FollowersScreen> {
  late Future<List<Follower>> _followersFuture;
  late FollowerService _followerService;
  List<Follower> _followers = [];

  @override
  void initState() {
    super.initState();
    _followerService = FollowerService();
    _loadFollowers();
  }

  void _loadFollowers() {
   _followersFuture = _followerService.getFollowers(widget.userId);
  _followersFuture.then((followers) {
    debugPrint('Seguidores recibidos: ${followers.length}');
    setState(() {
      _followers = followers;
    });
  }).catchError((e) {
    debugPrint('Error en _loadFollowers: $e');
  });
}

  Future<void> _toggleFollow(Follower follower) async {
    try {
      setState(() {
        follower.isFollowing = !follower.isFollowing;
      });

      if (follower.isFollowing) {
        await _followerService.followUser(follower.id);
      } else {
        await _followerService.unfollowUser(follower.id);
      }
    } catch (e) {
      setState(() {
        follower.isFollowing =
            !follower.isFollowing; // revertir cambio en caso de error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar seguimiento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguidores')),
      drawer: CustomDrawer(
        usuario: Usuario.fromJson(widget.usuario),
        parentContext: context,
        onLogout: () => _logout(context),
      ),
      body: FutureBuilder<List<Follower>>(
        future: _followersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (_followers.isEmpty) {
            return const Center(child: Text('No tienes seguidores todavía.'));
          } else {
            return ListView.builder(
              itemCount: _followers.length,
              itemBuilder: (context, index) {
                final follower = _followers[index];
                return ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      foregroundImage:
                          NetworkImage(getUserAvatarUrl(follower.userAvatar)),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    title: Text(follower.name),
                    subtitle: Text(follower.email),
                    trailing: ElevatedButton(
                      onPressed: () => _toggleFollow(follower),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: follower.isFollowing
                            ? Colors.red
                            : Colors.green,
                      ),
                      child: Text(
    follower.isFollowing ? 'Siguiendo' : 'Seguir',
    style: TextStyle(
      color: follower.isFollowing ? Colors.white : Colors.white,
    ),
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
