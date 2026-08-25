// import 'package:flutter/material.dart';
// import '../models/users.dart';
// import '../services/sugerencias_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SugerenciasScreen extends StatefulWidget {
//   const SugerenciasScreen({super.key});

//   @override
//   State<SugerenciasScreen> createState() => _SugerenciasScreenState();
// }

// class _SugerenciasScreenState extends State<SugerenciasScreen> {
//   final UserService _service = UserService();
//   late Future<List<User>> _futureSugerencias;

//   // 💡 Idealmente recupera el token desde SharedPreferences o tu login flow
//   //final String _token = 'tu-token-aqui'; 

//   @override
//   void initState() {
//     super.initState();
//     _cargarSugerencias();
//     _loadTokenAndFetch();
// }

// void _loadTokenAndFetch() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token') ?? '';
//   print('Token en initState: $token');
//   setState(() {
//     _futureSugerencias = _service.obtenerSugerencias(token);
//   });
// }

//   void _cargarSugerencias() async {
//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token') ?? '';

//   if (token.isEmpty) {
//     print('Token vacío, no se pueden cargar sugerencias');
//     return;
//   }

//   setState(() {
//     _futureSugerencias = _service.obtenerSugerencias(token);
//   });
// }
// Future<void> seguirUsuario(int userId, String token) async {
//   final url = Uri.parse('$baseUrl/api/follow/$userId');
//   final response = await http.post(
//     url,
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Accept': 'application/json',
//     },
//   );

//   if (response.statusCode != 200) {
//     throw Exception('Error al seguir al usuario: ${response.body}');
//   }
// }

//   // void _seguirUsuario(int userId) async {
//   //   try {
//   //     await _service.seguirUsuario(userId);
//   //     setState(() {
//   //       _cargarSugerencias(); // recarga la lista tras seguir a alguien
//   //     });
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context)
//   //         .showSnackBar(const SnackBar(content: Text('Error al seguir usuario')));
//   //   }
//   // }
// String getUserAvatarUrl(String? fileName) {
//   const baseUrl = 'https://iidlive.com/';
//   if (fileName == null || fileName.isEmpty) {
//     return '${baseUrl}plataforma/perfil/avatar.png';
//   }
//   if (fileName.startsWith('uploads/avatars/')) {
//     return baseUrl + fileName;
//   }
//   return baseUrl + 'uploads/avatars/' + fileName;
// }

//   @override
//   Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       backgroundColor: const Color(0xFFC17C9C),
//       title: const Text(
//         'Sugerencias de amigos',
//         style: TextStyle(color: Colors.white),
//       ),
//       iconTheme: const IconThemeData(color: Colors.white),
//     ),
//     body: FutureBuilder<List<User>>(
//       future: _futureSugerencias,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return const Center(child: Text('Error al cargar sugerencias'));
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('No hay usuarios sugeridos.'));
//         } else {
//           final usuarios = snapshot.data!;
//           return Padding(
//             padding: const EdgeInsets.all(10),
//             child: ListView.separated(
//               itemCount: usuarios.length,
//               separatorBuilder: (context, index) =>
//                   const SizedBox(height: 10),
//               itemBuilder: (context, index) {
//                 final user = usuarios[index];
//                 return Card(
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   color: Colors.white,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 30,
//                           backgroundImage:
//                               NetworkImage(getUserAvatarUrl(user.fotos)),
//                           backgroundColor: Colors.grey[200],
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 user.nombre,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               // Text(
//                               //   user.descripcion ?? '',
//                               //   style: const TextStyle(
//                               //     fontSize: 13,
//                               //     color: Colors.grey,
//                               //   ),
//                               //   maxLines: 2,
//                               //   overflow: TextOverflow.ellipsis,
//                               // ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 8),
//                           ),
//                           onPressed: () => _seguirUsuario(user.id),
//                           icon: const Icon(Icons.person_add),
//                           label: const Text('Seguir'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//       },
//     ),
//   );
// }

// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/users.dart';
import '../services/sugerencias_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SugerenciasScreen extends StatefulWidget {
  const SugerenciasScreen({super.key});

  @override
  State<SugerenciasScreen> createState() => _SugerenciasScreenState();
}

class _SugerenciasScreenState extends State<SugerenciasScreen> {
  final UserService _service = UserService();

  // Inicializamos con lista vacía para evitar error LateInitializationError
  late Future<List<User>> _futureSugerencias = Future.value([]);

  @override
  void initState() {
    super.initState();
    _cargarSugerencias();
  }

  void _cargarSugerencias() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      print('Token vacío, no se pueden cargar sugerencias');
      return;
    }

    setState(() {
      _futureSugerencias = _service.obtenerSugerencias(token);
    });
  }

  void _seguirUsuario(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      await _service.seguirUsuario(userId, token);

      _cargarSugerencias(); // recargar sugerencias después de seguir
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seguir usuario')),
      );
    }
  } 
  Future<void> seguirUsuario(int userId, String token) async {
     const baseUrl = 'https://iidlive.com/';
  final url = Uri.parse('$baseUrl/api/follow/$userId');
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al seguir al usuario: ${response.body}');
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC17C9C),
        title: const Text(
          'Sugerencias de amigos',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<User>>(
        future: _futureSugerencias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar sugerencias'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay usuarios sugeridos.'));
          } else {
            final usuarios = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.separated(
                itemCount: usuarios.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = usuarios[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(getUserAvatarUrl(user.fotos)),
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.nombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => _seguirUsuario(user.id),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Seguir'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
