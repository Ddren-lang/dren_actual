
//   Future<void> _fetchCategorias() async {
//     const String categoriasApiUrl =
//         "http://192.168.50.153:8080/plataforma/get_categorias.php";
//     // "http://169.254.85.101:8080/plataforma/get_categorias.php";

//     try {
//       final response = await http.get(Uri.parse(categoriasApiUrl));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         if (data.containsKey('categorias') && data['categorias'] is List) {
//           setState(() {
//             categorias = ['Todos'];
//             categorias.addAll(List<String>.from(
//                 data['categorias'].map((c) => c['nameCategoria'] as String)));
//             categoriaSeleccionada = 'Todos'; // Selección inicial
//           });
//         } else {
//           throw Exception('La clave "categorias" no contiene una lista');
//         }
//       } else {
//         throw Exception('Error en la respuesta: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error al cargar categorías: $e");
//     }
//   }

//   Future<List<Post>> _fetchPosts() async {
//     String apiUrl =
//         // "http://192.168.50.153:8080/plataforma/get_post.php";
//         "http://192.168.50.153:8080/plataforma/get_post.php";
//     if (categoriaSeleccionada != null && categoriaSeleccionada != 'Todos') {
//       apiUrl += "?categoria=${Uri.encodeComponent(categoriaSeleccionada!)}";
//     }

//     try {
//       final response = await http.get(Uri.parse(apiUrl));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         if (data.containsKey('posts')) {
//           final List<dynamic> postsJson = data['posts'];
//           return postsJson.map((json) => Post.fromJson(json)).toList();
//         } else {
//           throw Exception('El JSON no contiene la clave "posts".');
//         }
//       } else {
//         throw Exception('Error HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error al obtener posts: $e');
//     }
//   }

//   Future<void> fetchComments(int postId) async {
//     try {
//       final response = await http.get(Uri.parse(
//           'http://192.168.50.153:8080/plataforma/comments_post.php?post_id=$postId'));

//       print('Respuesta del servidor: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data is List) {
//           final commentsList =
//               data.map((json) => Comment.fromJson(json)).toList();

//           setState(() {
//             _comments[postId] = commentsList;
//           });
//         } else if (data is Map && data.containsKey('error')) {
//           print('Error del servidor: ${data['error']}');
//         } else {
//           print('Formato de datos inesperado: $data');
//         }
//       } else {
//         print('Error HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error al procesar comentarios: $e');
//     }
//   }

//   Future<Comment?> _submitComment(int postId, String body) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://192.168.50.153:8080/plataforma/comments_post.php'),
//         body: {
//           'user_id': widget.usuario['id'].toString(),
//           'post_id': postId.toString(),
//           'body': body,
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return Comment.fromJson(data);
//       } else {
//         print('Error al enviar comentario: ${response.statusCode}');
//         print('Respuesta del servidor: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Excepción al enviar comentario: $e');
//       return null;
//     }
//   }

// // Future<Comment?> _submitComment(int postId, String body) async {
// //   final response = await http.post(
// //     Uri.parse('https://192.168.50.153:8080/plataforma/comments_post.php'),
// //     body: {
// //       'user_id': widget.usuario['id'].toString(),
// //       'post_id': postId.toString(),
// //       'body': body,
// //     },
// //   );

// //   if (response.statusCode == 200) {
// //     final data = json.decode(response.body);
// //     return Comment.fromJson(data);
// //   } else {
// //     print('Error al enviar comentario: ${response.body}');
// //     return null;
// //   }
// // }

//   Future<bool> postComment({
//     required int userId,
//     required int postId,
//     String? body,
//     int? parentId,
//   }) async {
//     final response = await http.post(
//       Uri.parse('http://192.168.50.153:8080/plataforma/comments_post.php'),
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {
//         'user_id': widget.usuario['id'].toString(),
//         'post_id': postId.toString(),
//         'body': body,
//       },
//     );

//     return json.decode(response.body)['success'] ?? false;
//   }

//   Future<void> _sendReaction({
//     required int userId,
//     required int postId,
//     required int likes,
//   }) async {
//     final url = Uri.parse(
//         // "http://192.168.50.153:8080/plataforma/guardar_reaccion.php"
//         "http://192.168.50.153:8080/plataforma/guardar_reaccion.php");

//     try {
//       final response = await http.post(
//         url,
//         body: {
//           'user_id': userId.toString(),
//           'post_id': postId.toString(),
//           'likes': likes.toString(),
//           'likeable_type': 'App\\Models\\Post',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           print('✅ Reacción guardada: ${data['message']}');
//         } else {
//           print('⚠️ Error desde el servidor: ${data['error']}');
//         }
//       } else {
//         print('❌ Error HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❗ Error en reacción: $e');
//     }
//   }

//   Future<void> _loadPostsAndLikes() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final posts = await _fetchPosts();
//       final prefs = await SharedPreferences.getInstance();
//       final userId = int.parse(widget.usuario['id'].toString());

//       Map<int, bool> likedMap = {};
//       Map<int, TextEditingController> newControllers = {};

//       for (var post in posts) {
//         bool liked = prefs.getBool('like_post_${post.id}_$userId') ?? false;
//         likedMap[post.id] = liked;

//         // Asegúrate de que cada post tenga un controlador de comentarios
//         newControllers[post.id] = TextEditingController();
//       }

//       setState(() {
//         _posts = posts;
//         _likedPosts = likedMap;
//         _isLoading = false;
//         _commentControllers = newControllers; // ✅ se actualizan aquí
//       });
//     } catch (e) {
//       print('Error cargando posts y likes: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Future<void> _loadPostsAndLikes() async {
//   //   setState(() {
//   //     _isLoading = true;
//   //   });

//   //   try {
//   //     final posts = await _fetchPosts();
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final userId = int.parse(widget.usuario['id'].toString());

//   //     Map<int, bool> likedMap = {};
//   //     for (var post in posts) {
//   //       bool liked = prefs.getBool('like_post_${post.id}_$userId') ?? false;
//   //       likedMap[post.id] = liked;
//   //     }

//   //     setState(() {
//   //       _posts = posts;
//   //       _likedPosts = likedMap;
//   //       _isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     print('Error cargando posts y likes: $e');
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   void _onCategoriaChanged(String? newCategoria) {
//     setState(() {
//       categoriaSeleccionada = newCategoria;
//     });
//     _loadPostsAndLikes();
//   }

//   Future<String?> _getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('usuario');
//   }

//   Future<void> _logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   // //imagen del post
//   // String getImageUrl(String imagePath) {
//   //   const baseUrl = "http://192.168.50.153:8080/plataforma/";
//   //   //'http://169.254.191.190:8080/plataforma/';
//   //   return baseUrl + imagePath.replaceFirst('plataforma/', '');
//   // }

//   // String getUserAvatarUrl(String? fileName) {
//   //   const baseUrl = 'http://192.168.50.153:8080/';
//   //   //'http://169.254.191.190:8080/'; // tu IP y puerto
//   //   if (fileName == null || fileName.isEmpty) {
//   //     return 'http://192.168.50.153:8080/plataforma/perfil/avatar.png';
//   //     //'http://169.254.191.190:8080/plataforma/perfil/avatar.png';
//   //   }
//   //   return baseUrl + fileName; // Concatenamos la ruta completa
//   // }




  // Likes y botón de comentarios
                                                     /** Row(
                                                        children: [
                                                          IconButton(
                                                            icon: Icon(
                                                              isLiked
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,
                                                              color: isLiked
                                                                  ? Colors.red
                                                                  : Colors.grey,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              final prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              setState(() {
                                                                if (isLiked) {
                                                                  post.likesCount--;
                                                                  _likedPosts[post
                                                                          .id] =
                                                                      false;
                                                                  prefs.remove(
                                                                      'like_post_${post.id}_${widget.usuario['id']}');
                                                                  _sendReaction(
                                                                    userId: int.parse(widget
                                                                        .usuario[
                                                                            'id']
                                                                        .toString()),
                                                                    postId:
                                                                        post.id,
                                                                    likes: 0,
                                                                  );
                                                                } else {
                                                                  post.likesCount++;
                                                                  _likedPosts[post
                                                                          .id] =
                                                                      true;
                                                                  prefs.setBool(
                                                                      'like_post_${post.id}_${widget.usuario['id']}',
                                                                      true);
                                                                  _sendReaction(
                                                                    userId: int.parse(widget
                                                                        .usuario[
                                                                            'id']
                                                                        .toString()),
                                                                    postId:
                                                                        post.id,
                                                                    likes: 1,
                                                                  );
                                                                }
                                                              });
                                                            },
                                                          ),
                                                          Text(
                                                              '${post.likesCount} Likes'),
                                                          const SizedBox(
                                                              width: 10),
                                                          IconButton(
                                                            icon: const Icon(
                                                                Icons.comment,
                                                                color: Colors
                                                                    .grey),
                                                            onPressed:
                                                                () async {
                                                              final show =
                                                                  _showComments[
                                                                          post.id] ??
                                                                      false;
                                                              if (!show) {
                                                                await fetchComments(
                                                                    post.id);
                                                              }
                                                              setState(() {
                                                                _showComments[
                                                                        post.id] =
                                                                    !show;
                                                              });
                                                            },
                                                          ),
                                                          const Text(
                                                              ' Comentarios'),
                                                        ],
                                                      ),  */

                                                     /**  if (_showComments[
                                                              post.id] ==
                                                          true) ...[
                                                        const SizedBox(
                                                            height: 10),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            for (final comment
                                                                in _comments[post
                                                                        .id] ??
                                                                    [])
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        4.0),
                                                                child: Text(
                                                                  '${comment.userName}: ${comment.body}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      TextField(
                                                                    controller:
                                                                        _commentControllers[
                                                                            post.id],
                                                                    decoration:
                                                                        const InputDecoration(
                                                                      hintText:
                                                                          'Escribe un comentario...',
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                      contentPadding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8,
                                                                          vertical:
                                                                              4),
                                                                    ),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .send),
                                                                    onPressed:
                                                                        () async {
                                                                      final text =
                                                                          _commentControllers[post.id]?.text ??
                                                                              '';
                                                                      if (text
                                                                          .isEmpty)
                                                                        return;

                                                                      print(
                                                                          'Enviando comentario: $text');

                                                                      final newComment = await _submitComment(
                                                                          post.id,
                                                                          text);

                                                                      if (newComment !=
                                                                          null) {
                                                                        setState(
                                                                            () {
                                                                          _comments[post.id] = (_comments[post.id] ??
                                                                              [])
                                                                            ..add(newComment);
                                                                          _commentControllers[post.id]
                                                                              ?.clear();
                                                                        });
                                                                      } else {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text('Error al enviar comentario')),
                                                                        );
                                                                      }
                                                                    })
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],*/
/* Future<void> _subirImagen() async {
//   if (_imagen == null) return;

//   final request = http.MultipartRequest(
//     'POST',
//     Uri.parse('http://iidlive.com/api/perfil/editar'),
//   );

//   request.files.add(await http.MultipartFile.fromPath('imagen', _imagen!.path));
//   request.fields['id'] = usuario!.id.toString();

//   try {
//     final response = await request.send();
//     final responseData = jsonDecode(await response.stream.bytesToString());

//     if (response.statusCode == 200 && responseData['status'] == 'success') {
//       setState(() {
//         _rutaImagen = responseData['url']; // Aquí recibes la URL completa
//       });
//     } else {
//       _mostrarError(responseData['message'] ?? 'Error al subir la imagen');
//     }
//   } catch (e) {
//     _mostrarError('No se pudo conectar al servidor');
//   }
// }
// Widget _buildImage() {
//   // Si hay una imagen seleccionada desde la galería
//   if (_imagen != null) {
//     return Image.file(_imagen!); // Mostrar imagen local
//   } 
//   // Si la ruta de la imagen es válida y comienza con "http"
//   else if (_rutaImagen != null && _rutaImagen!.isNotEmpty && _rutaImagen!.startsWith('http')) {
//     return Image.network(_rutaImagen!); // Mostrar imagen desde la URL
//   } 
//   // Si no hay imagen seleccionada ni URL válida
//   else {
//     return Image.asset('assets/default_profile.png'); // Imagen por defecto
//   }
// }


// Future<void> _guardarCambios() async {
//   if (usuario == null || usuario!.id == null) {
//     _mostrarError('No se ha recibido el ID del usuario');
//     return;
//   }

//   await _subirImagen(); // Subimos la imagen antes de guardar los cambios

//   final usuarioActualizado = {
//     'id': usuario!.id, // Aseguramos que tenemos el ID correcto
//     'nombre': nombreController.text,
//     'nombreusuario': usuarioController.text,
//     'direccion': direccionController.text,
//     'pais': paisController.text,
//     'ciudad': ciudadController.text,
//     'codigopostal': codigopostalController.text,
//     'descripcion': descripcionController.text,
//     'fotos': _rutaImagen ?? usuario!.fotos, // Aseguramos que la imagen esté incluida
//   };

//   print("Datos enviados: $usuarioActualizado"); // Agrega esto para verificar los datos enviados

//   try {
//     final response = await http.post(
//       Uri.parse('http://iidlive.com/api/perfil/editar'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(usuarioActualizado),
//     );

//     final responseData = jsonDecode(response.body);

//     print("Respuesta del servidor: $responseData"); // Agrega esto para ver la respuesta

//     if (response.statusCode == 200 && responseData['status'] == 'success') {
//       // Mostrar mensaje de éxito en un SnackBar
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Perfil actualizado con éxito')),
//       );
//       Navigator.pop(context, usuario); // Navegamos con el objeto Usuario
//     } else {
//       _mostrarError(responseData['message'] ?? 'Error al guardar datos');
//     }
//   } catch (e) {
//     _mostrarError('No se pudo conectar al servidor');
//   }
// }
 */



// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:iidlive_app/plantillas/home.dart';
// import 'package:iidlive_app/plantillas/login.dart';
// import 'package:iidlive_app/plantillas/registro.dart';
// import 'package:iidlive_app/plantillas/reels.dart'; // Asegúrate de importar la página de SubirReel
// import 'package:iidlive_app/plantillas/post.dart';
// import 'package:iidlive_app/plantillas/categorias.dart';
// import 'package:iidlive_app/plantillas/lives.dart';
// import 'package:iidlive_app/plantillas/todo_lives.dart';
// import 'package:iidlive_app/plantillas/reelss.dart';
// import 'package:iidlive_app/plantillas/Perfil_user.dart';
// import 'package:iidlive_app/plantillas/editar_perfil.dart';
// import 'package:iidlive_app/plantillas/followers_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('es', 'ES'), // Español
//       ],
//       locale: const Locale('es', 'ES'),
//       routes: {
//         'login': (context) => Login(),
//         '/home': (context) => FutureBuilder<Map<String, dynamic>>(
//               future:
//                   _getUserData(), // Cargar datos del usuario desde SharedPreferences
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError || !snapshot.hasData) {
//                   return const Center(child: Text('Error al cargar los datos'));
//                 } else {
//                   try {
//                     final usuario = snapshot
//                         .data!; // Asegúrate de que los datos sean válidos
//                     return Home(usuario: usuario); // Pasa los datos a Home
//                   } catch (e) {
//                     return const Center(
//                         child: Text('Error al parsear los datos del usuario'));
//                   }
//                 }
//               },
//             ),

//         'registro': (context) => Registro(),
//         '/lives': (context) => LiveStreamingPage(),
//         '/salas': (context) => LiveStreamingPages(),
//         '/perfil': (context) =>
//             PerfilScreen(), // Asegúrate de pasar el userId aquí
//         '/editar': (context) => EditarPerfilScreen(),
//         '/vistaReels': (context) =>
//             ReelsScreen(), // Agrega la pantalla de reels
//         '/login': (context) => Login(), // Ruta para el login
//         '/reels': (context) => FutureBuilder<Map<String, dynamic>>(
//               future:
//                   _getUserData(), // Cargar los datos del usuario desde SharedPreferences
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                       child:
//                           CircularProgressIndicator()); // Mientras se cargan los datos
//                 } else if (snapshot.hasError || !snapshot.hasData) {
//                   return const Center(
//                       child: Text('Error al cargar los datos del usuario'));
//                 } else {
//                   final usuario = snapshot.data!; // Datos del usuario cargados
//                   return SubirReelPage(userId: usuario['id'], usuario: usuario);
//                 }
//               },
//             ),
//         // Cambié de SubirReelPag a SubirReelPage
//         '/post': (context) => FutureBuilder<Map<String, dynamic>>(
//               future:
//                   _getUserData(), // Cargar los datos del usuario desde SharedPreferences
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                       child:
//                           CircularProgressIndicator()); // Mientras se cargan los datos
//                 } else if (snapshot.hasError || !snapshot.hasData) {
//                   return const Center(
//                       child: Text('Error al cargar los datos del usuario'));
//                 } else {
//                   final usuario = snapshot.data!; // Datos del usuario cargados
//                   return CreatePostPage(
//                       userId: usuario['id'], usuario: usuario);
//                 }
//               },
//             ),

//         '/followers': (context) => FutureBuilder<Map<String, dynamic>>(
//               future:
//                   _getUserData(), // Cargar datos del usuario desde SharedPreferences
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   ); // Mientras se cargan los datos
//                 } else if (snapshot.hasError || !snapshot.hasData) {
//                   return const Scaffold(
//                     body: Center(
//                         child: Text('Error al cargar los datos del usuario')),
//                   );
//                 } else {
//                   final usuario = snapshot.data!;
//                   return FollowersScreen(
//                     userId: usuario['id'],
//                     token: usuario['token'],
//                     baseUrl: 'https://iidlive.com', // Ajusta tu dominio aquí
//                   );
//                 }
//               },
//             ),

//         '/crear_categoria': (context) => FutureBuilder<Map<String, dynamic>>(
//               future:
//                   _getUserData(), // Cargar los datos del usuario desde SharedPreferences
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                       child:
//                           CircularProgressIndicator()); // Mientras se cargan los datos
//                 } else if (snapshot.hasError || !snapshot.hasData) {
//                   return const Center(
//                       child: Text('Error al cargar los datos del usuario'));
//                 } else {
//                   final usuario = snapshot.data!; // Datos del usuario cargados
//                   return CrearCategoriaScreen(
//                       userId: usuario['id'], usuario: usuario);
//                 }
//               },
//             ),
//       },
//       initialRoute: 'login',
//     );
//   }

//   Future<Map<String, dynamic>> _getUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userData =
//           prefs.getString('usuario'); // Cargar los datos del usuario guardados

//       if (userData != null) {
//         return jsonDecode(
//             userData); // Decodificar los datos guardados en formato JSON
//       } else {
//         throw Exception("No se encontraron datos del usuario");
//       }
//     } catch (e) {
//       throw Exception("Error al obtener los datos del usuario: $e");
//     }
//   }
// }

<!-- seccion de amigos -->
    <div class="row mt-4">
      <div class="col-lg-7 mb-lg-0 mb-4">
        <div class="card w-auto">
         
            <h6 class="text-capitalize center">Sugerencia de amigos</h6>
            <p class="text-sm mb-0">
              <span class="font-weight-bold"></span>
            </p>
          
          <div class="card-body p-md-3 p-1 w-auto md-3" style="height: 400px; overflow-y: auto;">
            <div class="row row-cols-1 row-cols-md-3 g-4" style="gap: 30px; padding: 0 15px;">
              @foreach ($users as $user)
              <div class="col">
                <div class="card h-100 mb-3" style="width: 18rem;">
                  <img src="{{ asset('uploads/avatars/'.$user->fotos) }}" class="card-img-top mx-auto" alt="avatar" style="width: 80px; height: 80px; object-fit: cover; border-radius: 50%;">
                  <div class="card-body">
                    <a href="{{ route('perfilusuarios', $user->id) }}" class="card-title">
                      <h5>{{$user->nombre }}</h5>
                    </a>
                    <p class="card-text">{{$user->descripcion}}</p>
                  </div>
                  <div class="card-footer">
                    @if(auth()->user()->isFollowing($user))
                    <form method="post" action="{{ route('unfollow', $user) }}">
                      @csrf
                      <button class="btn btn-sm btn-danger" type="submit">
                        <i>
                          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-add" viewBox="0 0 16 16">
                            <path d="M12.5 16a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7m.5-5v1h1a.5.5 0 0 1 0 1h-1v1a.5.5 0 0 1-1 0v-1h-1a.5.5 0 0 1 0-1h1v-1a.5.5 0 0 1 1 0m-2-6a3 3 0 1 1-6 0 3 3 0 0 1 6 0M8 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4" />
                            <path d="M8.256 14a4.5 4.5 0 0 1-.229-1.004H3c.001-.246.154-.986.832-1.664C4.484 10.68 5.711 10 8 10q.39 0 .74.025c.226-.341.496-.65.804-.918Q8.844 9.002 8 9c-5 0-6 3-6 4s1 1 1 1z" />
                          </svg>
                        </i> Dejar de seguir
                      </button>
                    </form>
                    @else
                    <form method="post" action="{{ route('follow', $user) }}">
                      @csrf
                      <button class="btn btn-sm btn-success" type="submit">
                        <i>
                          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-add" viewBox="0 0 16 16">
                            <path d="M12.5 16a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7m.5-5v1h1a.5.5 0 0 1 0 1h-1v1a.5.5 0 0 1-1 0v-1h-1a.5.5 0 0 1 0-1h1v-1a.5.5 0 0 1 1 0m-2-6a3 3 0 1 1-6 0 3 3 0 0 1 6 0M8 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4" />
                            <path d="M8.256 14a4.5 4.5 0 0 1-.229-1.004H3c.001-.246.154-.986.832-1.664C4.484 10.68 5.711 10 8 10q.39 0 .74.025c.226-.341.496-.65.804-.918Q8.844 9.002 8 9c-5 0-6 3-6 4s1 1 1 1z" />
                          </svg>
                        </i> Seguir
                      </button>
                    </form>
                    @endif
                  </div>
                </div>

              </div>
              @endforeach
            </div>
          </div>
        </div>
    </div>
</div>
        

    <div class="col-lg-12 mb-4">
    <div class="card w-auto">
      <div class="card-header pb-0 p-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0">Post</h6>
      </div>
            @php
            use Illuminate\Support\Str;


            // Definir los colores personalizados para cada categoría
            $categoryColors = [
            'drensport' => ['#008000', 'fas fa-futbol'], // Verde, ícono de fútbol
            'drengeek' => ['#17a2b8', 'fas fa-laptop'], // Azul claro, ícono de computadora
            'drenpolitico' => ['#ffc107', 'fas fa-gavel'], // Amarillo, ícono de martillo (política)
            'drensocial' => ['#007bff', 'fas fa-users'], // Azul, ícono de usuarios
            'drenanime' => ['#6f42c1', 'fas fa-tv'], // Morado, ícono de televisión
            'drenmovie' => ['#8B0000', 'fas fa-film'], // Rojo oscuro, ícono de película
            'drenfun' => ['#fd7e14', 'fas fa-cogs'], // Naranja, ícono de diversión (engranaje)
            'ocio' => ['#17a2b8', 'fas fa-cocktail'], // Azul claro, ícono de ocio (cóctel)
            'drenbusiness' => ['#343a40', 'fas fa-briefcase'], // Gris oscuro, ícono de maletín
            'drendays' => ['#28a745', 'fas fa-sun'], // Verde claro, ícono de sol
            'drenworld' => ['#6c3f2f', 'fas fa-globe'], // Marrón, ícono de globo
            'educacion' => ['#003366', 'fas fa-book'], // Azul oscuro, ícono de libro
            'drengamer' => ['#00FF00', 'fas fa-gamepad'], // Verde neón, ícono de gamepad
            '+18' => ['f235fa', 'fas fa-lock'] // Rojo, ícono de candado para contenido restringido
            ];
            // Calcular el nivel de influencia del usuario actual
            $userId = auth()->id();
            $seguidoress = Follower::where('following_id', $userId)->count();
            $seguidos = Follower::where('follower_id', $userId)->count();
            $postess = Post::where('user_id', $userId)->count();
            $videos = Video::where('user_id', $userId)->count();

            $influencer = $seguidoress + $seguidos + $postess + $videos;
            @endphp
            <div class="col-10 col-md-12">
              <nav class="text-center my-5">
                <button class="btn btn-light me-2" onclick="window.location.href='{{ route('creador.publicacion.posts') }}'">Mis posts</button>
                <a href="{{ route('creadores') }}" class="btn btn-warning"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-list-task" viewBox="0 0 16 16">
                    <path fill-rule="evenodd" d="M2 2.5a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5V3a.5.5 0 0 0-.5-.5zM3 3H2v1h1z" />
                    <path d="M5 3.5a.5.5 0 0 1 .5-.5h9a.5.5 0 0 1 0 1h-9a.5.5 0 0 1-.5-.5M5.5 7a.5.5 0 0 0 0 1h9a.5.5 0 0 0 0-1zm0 4a.5.5 0 0 0 0 1h9a.5.5 0 0 0 0-1z" />
                    <path fill-rule="evenodd" d="M1.5 7a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5H2a.5.5 0 0 1-.5-.5zM2 7h1v1H2zm0 3.5a.5.5 0 0 0-.5.5v1a.5.5 0 0 0 .5.5h1a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5zm1 .5H2v1h1z" />
                  </svg> Dren</a>
                @foreach ($categories as $category)
                @php
                // Normalizar el nombre de la categoría para la comparación
                $normalizedCategory = Str::lower(Str::ascii($category->nameCategoria));

                // Obtener el color según la clave normalizada
                $categoryData = $categoryColors[$normalizedCategory] ?? ['#6c757d', 'fas fa-question']; // Color predeterminado y ícono por defecto
                $color = $categoryData[0];
                $icon = $categoryData[1];

                // Verificar si la categoría está seleccionada
                $isActive = request('category') == $category->nameCategoria ? 'active' : '';
                @endphp

                {{-- Restringir la categoría +18 si el usuario tiene menos de 300 puntos --}}
                @if($normalizedCategory === '+18' && $influencer < 300)
                  @continue
                  @endif
                  <form action="{{ route('creadores') }}" method="GET" class="d-inline-block">
                  <input type="hidden" name="category" value="{{ $category->nameCategoria }}">
                  <button class="btn text-white category-filter {{ $isActive }}" style="background-color: {{ $color }}">
                    <i class="{{ $icon }}" style="margin-right: 5px;"></i>
                    {{ $category->nameCategoria }}
                  </button>
                  </form>
                  @endforeach
              </nav>
            
          </div>
                <div class="card-responsive w-auto" id="post-list">

            @foreach ($posts as $poste)
            <div class="card w-auto">
              <div class="card-body pt-2 w-auto">
                <span class="text-gradient text-primary text-uppercase text-xs font-weight-bold my-2">{{ $poste->category->nameCategoria }}</span>

                <!-- T铆tulo del post -->
                <h7 class="card-title w-auto" style="font-family:monospace;">
<?php
$postContent = $poste->content;
$postImage = $poste->image; // Imagen extra de la base de datos

// 1️⃣ Procesar videos de YouTube
$postContentWithLinks = preg_replace_callback(
    '/https?:\/\/(?:www\.)?(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)/',
    function ($matches) {
        $youtubeId = $matches[1];
        return '<div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; background: #000; margin-top: 10px;">
                    <iframe src="https://www.youtube.com/embed/' . $youtubeId . '" 
                            style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;" 
                            frameborder="0" 
                            allow="autoplay; encrypted-media" 
                            allowfullscreen>
                    </iframe>
                </div>';
    },
    $postContent
);

// 2️⃣ Procesar videos de TikTok (enlace normal)
$postContentWithLinks = preg_replace_callback(
    '/https?:\/\/www\.tiktok\.com\/@[\w.-]+\/video\/(\d+)/',
    function ($matches) {
        $tiktokId = $matches[1];
        return '<blockquote class="tiktok-embed" cite="https://www.tiktok.com/@tiktok/video/' . $tiktokId . '" data-video-id="' . $tiktokId . '" style="max-width: 100%;">
                    <section>Ver en <a href="https://www.tiktok.com/@tiktok/video/' . $tiktokId . '" target="_blank">TikTok</a></section>
                </blockquote>
                <script async src="https://www.tiktok.com/embed.js"></script>';
    },
    $postContentWithLinks
);

// 2.1️⃣ Procesar enlaces cortos de TikTok (vm.tiktok.com)
$postContentWithLinks = preg_replace_callback(
    '/https?:\/\/vm\.tiktok\.com\/([\w.-]+)\/?/',
    function ($matches) {
        $url = $matches[0];
        return '<blockquote class="tiktok-embed" cite="' . htmlspecialchars($url, ENT_QUOTES, 'UTF-8') . '" style="max-width: 100%;">
                    <section>Ver en <a href="' . htmlspecialchars($url, ENT_QUOTES, 'UTF-8') . '" target="_blank">TikTok</a></section>
                </blockquote>
                <script async src="https://www.tiktok.com/embed.js"></script>';
    },
    $postContentWithLinks
);

// 3️⃣ Verificar si ya hay imágenes en el contenido (ya procesado para videos)
if (!preg_match('/<img[^>]+src=["\'](https?:\/\/\S+\.(jpg|jpeg|png|gif|webp))["\']/i', $postContentWithLinks)) {
    // 4️⃣ Reemplazar URLs de imágenes planas por etiquetas <img>
    $postContentWithLinks = preg_replace_callback(
        '/(https?:\/\/\S+\.(jpg|jpeg|png|gif|webp))/i',
        function ($matches) {
            $url = preg_replace('/^http:\/\//i', 'https://', $matches[1]);
            return '<img src="' . htmlspecialchars($url, ENT_QUOTES, 'UTF-8') . '" alt="Imagen" 
                    style="max-width: 100%; height: auto; margin-top: 10px; border-radius: 8px;">';
        },
        $postContentWithLinks
    );
}

// 6️⃣ Mostrar contenido procesado
echo '<div class="post-content">' . $postContentWithLinks . '</div>';

// 7️⃣ Mostrar imagen extra si existe
if (!empty($postImage)) {
    // Ajusta la ruta según donde almacenes tus imágenes
    $rutaImagen = '/uploads/posts/' . $postImage;
    echo '<div class="post-image" style="margin-top: 10px;">
            <img src="' . htmlspecialchars($rutaImagen, ENT_QUOTES, 'UTF-8') . '" 
                 alt="Imagen adicional del post" 
                 style="max-width: 100%; height: auto; border-radius: 8px;">
          </div>';
}
?>


                </h7>

                <!-- Imagen del Post -->
                <p class="card-description mb-4">

                </p>
                <div class="author align-items-center">
                  <!-- <img src="{{ auth()->user()->fotos ? asset('uploads/avatars/'.Auth::user()->fotos) :  asset('uploads/avatars/avatar.jpg') }}"  class="avatar shadow" alt="sin imagen" /> -->

                  <img src="{{ asset('uploads/avatars/'.$poste->user->fotos) }}" alt="..." class="avatar shadow">
                  <div class="name ps-3">
                    @if ($poste->owner->id === auth()->id())
                    <a href="{{ route('perfil') }}" class="card-title"><span>{{ $poste->owner->nombre }}</span></a>
                    @else
                    <a href="{{ route('perfilusuarios', $poste->owner->id) }}" class="card-title"><small>{{ $poste->owner->nombre }}</small></a>
                    @endif
                    <div class="stats">
                      <small>{{ $poste->published_at->format('d/M/Y')}}</small>
                    </div>
                    <!-- <span>{{$poste->owner->nombre}}</span>
                    <div class="stats">
                        <small>{{ $poste->published_at->format('d/M/Y')}}</small>
                    </div> -->
                  </div>
                </div>
                <div class="name ps-3">
                  {{ $poste->likes()->sum('count') }} star
                </div>
                <form action="{{ route('posts.like', $poste->id) }}" method="POST" id="formularios">
                  @csrf

                  <!-- Range para seleccionar la cantidad de likes -->
                  <label for="like-range">Selecciona hasta 5 star:</label>
                  <!-- Obtener el conteo de likes del usuario autenticado espec铆ficamente para el post actual -->
                  @php
                  $userLikeCount = $poste->likes()->where('user_id', auth()->id())->sum('count');
                  $remainingLikes = max(0, 5 - $userLikeCount);
                  @endphp
                  <input type="range" id="like-range" name="likesp" min="0" max="{{ $remainingLikes }}" value="0">
                  <output for="like-range">{{ $userLikeCount }}</output> <!-- Mostrar el valor seleccionado -->

                  <!-- Agregar un campo oculto para enviar el valor de $remainingLikes al controlador -->
                  <input type="hidden" name="remainingLikes" value="{{ $remainingLikes }}">

                  <!-- Verificar si el usuario ya ha dado sus 5 likes en este post -->
                  @if ($userLikeCount >= 5)
                  <!-- Si el usuario ya ha dado sus 5 likes, deshabilitar el bot贸n -->
                  <button type="button" class="btn btn-danger" disabled><i><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-star-half" viewBox="0 0 16 16">
                        <path d="M5.354 5.119 7.538.792A.52.52 0 0 1 8 .5c.183 0 .366.097.465.292l2.184 4.327 4.898.696A.54.54 0 0 1 16 6.32a.55.55 0 0 1-.17.445l-3.523 3.356.83 4.73c.078.443-.36.79-.746.592L8 13.187l-4.389 2.256a.5.5 0 0 1-.146.05c-.342.06-.668-.254-.6-.642l.83-4.73L.173 6.765a.55.55 0 0 1-.172-.403.6.6 0 0 1 .085-.302.51.51 0 0 1 .37-.245zM8 12.027a.5.5 0 0 1 .232.056l3.686 1.894-.694-3.957a.56.56 0 0 1 .162-.505l2.907-2.77-4.052-.576a.53.53 0 0 1-.393-.288L8.001 2.223 8 2.226z" />
                      </svg></i> Sin star</button>
                  @else
                  <!-- Si no, permitir al usuario dar like -->
                  <button type="submit" data-post-id="{{ $poste->id }}" class="btn btn-success"><i><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-star-fill" viewBox="0 0 16 16">
                        <path d="M3.612 15.443c-.386.198-.824-.149-.746-.592l.83-4.73L.173 6.765c-.329-.314-.158-.888.283-.95l4.898-.696L7.538.792c.197-.39.73-.39.927 0l2.184 4.327 4.898.696c.441.062.612.636.282.95l-3.522 3.356.83 4.73c.078.443-.36.79-.746.592L8 13.187l-4.389 2.256z" />
                      </svg></i> Dar {{ $remainingLikes > 1 ? 'likes' : 'like' }}</button>
                  @endif
                </form>

                <div class="dropdown">
                  <button class="btn btn-primary dropdown-toggle" type="button" id="shareDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <i><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-share-fill" viewBox="0 0 16 16">
                        <path d="M11 2.5a2.5 2.5 0 1 1 .603 1.628l-6.718 3.12a2.5 2.5 0 0 1 0 1.504l6.718 3.12a2.5 2.5 0 1 1-.488.876l-6.718-3.12a2.5 2.5 0 1 1 0-3.256l6.718-3.12A2.5 2.5 0 0 1 11 2.5" />
                      </svg></i>
                    Compartir
                  </button>
                  <ul class="dropdown-menu" aria-labelledby="shareDropdown">
                    <li>
                      <a class="dropdown-item" href="#" onclick="shareOnWhatsApp('{{ route('post.public', $poste->id) }}')">
                        <i><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-whatsapp" viewBox="0 0 16 16">
                            <path d="M13.601 2.326A7.85 7.85 0 0 0 7.994 0C3.627 0 .068 3.558.064 7.926c0 1.399.366 2.76 1.057 3.965L0 16l4.204-1.102a7.9 7.9 0 0 0 3.79.965h.004c4.368 0 7.926-3.558 7.93-7.93A7.9 7.9 0 0 0 13.6 2.326zM7.994 14.521a6.6 6.6 0 0 1-3.356-.92l-.24-.144-2.494.654.666-2.433-.156-.251a6.56 6.56 0 0 1-1.007-3.505c0-3.626 2.957-6.584 6.591-6.584a6.56 6.56 0 0 1 4.66 1.931 6.56 6.56 0 0 1 1.928 4.66c-.004 3.639-2.961 6.592-6.592 6.592m3.615-4.934c-.197-.099-1.17-.578-1.353-.646-.182-.065-.315-.099-.445.099-.133.197-.513.646-.627.775-.114.133-.232.148-.43.05-.197-.1-.836-.308-1.592-.985-.59-.525-.985-1.175-1.103-1.372-.114-.198-.011-.304.088-.403.087-.088.197-.232.296-.346.1-.114.133-.198.198-.33.065-.134.034-.248-.015-.347-.05-.099-.445-1.076-.612-1.47-.16-.389-.323-.335-.445-.34-.114-.007-.247-.007-.38-.007a.73.73 0 0 0-.529.247c-.182.198-.691.677-.691 1.654s.71 1.916.81 2.049c.098.133 1.394 2.132 3.383 2.992.47.205.84.326 1.129.418.475.152.904.129 1.246.08.38-.058 1.171-.48 1.338-.943.164-.464.164-.86.114-.943-.049-.084-.182-.133-.38-.232" />
                          </svg></i> <!-- Icono de WhatsApp -->
                        WhatsApp
                      </a>
                    </li>
                    <li>
                      <a class="dropdown-item" href="#" onclick="copyLink('{{route('post.public', $poste->id) }}', event)">
                        <i><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-copy" viewBox="0 0 16 16">
                            <path fill-rule="evenodd" d="M4 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2zm2-1a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1zM2 5a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1v-1h1v1a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h1v1z" />
                          </svg></i>
                        Copiar enlace
                      </a>
                    </li>
                  </ul>
                </div>

                <h6>Sala de Comentarios</h6>
                @include('posts.commentsDisplay', ['comments' => $poste->comments, 'post_id' => $poste->id])
                <hr />
                <h6>Agregar Comentario</h6>
                <form method="post" action="{{ route('comments.store') }}">
                  @csrf
                  <div class="input-group mb-3">
                    <input type="hidden" name="post_id" value="{{ $poste->id }}" />
                    <input type="text" name="body" class="form-control" placeholder="Agregar comentario" aria-label="Recipient's username" aria-describedby="button-addon2">
                    <button class="btn btn-success" type="submit" id="button-addon2" value="Agrega"><i><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-send-fill" viewBox="0 0 16 16">
                          <path d="M15.964.686a.5.5 0 0 0-.65-.65L.767 5.855H.766l-.452.18a.5.5 0 0 0-.082.887l.41.26.001.002 4.995 3.178 3.178 4.995.002.002.26.41a.5.5 0 0 0 .886-.083zm-1.833 1.89L6.637 10.07l-.215-.338a.5.5 0 0 0-.154-.154l-.338-.215 7.494-7.494 1.178-.471z" />
                        </svg></i> Enviar</button>
                  </div>

                </form>
              </div>
            </div>
            @endforeach
          </div>
          
        </div>
      </div>

      <!-- lista usuarios -->
           <div class="col-lg-4">
    <div class="card w-auto">
       <div class="card">
    <div class="card-header pb-0 p-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0">Reels</h6>
        <div>
            <button class="btn btn-light me-2" onclick="window.location.href='{{ route('creador.publicacion.reels') }}'">
                Mis reels
            </button>
        </div>
    </div>

    <div class="card-body p-3">
        @foreach ($video as $videos)
            <div class="card w-auto mb-3">
                <div class="card-body">
                    <h6 class="card-title d-flex align-items-center">
                        <img src="{{ asset('uploads/avatars/'.$videos->user->fotos) }}" class="img-fluid avatar-lg me-2">
                        @if ($videos->owner->id === auth()->id())
                            <a href="{{ route('perfil') }}" class="text-decoration-none">
                                <h8>{{ $videos->owner->nombre }}</h8>
                            </a>
                        @else
                            <a href="{{ route('perfilusuarios', $videos->owner->id) }}" class="text-decoration-none">
                                <h8>{{ $videos->owner->nombre }}</h8>
                            </a>
                        @endif
                        <span class="ms-2">- {{ $videos->created_at->format('d/M/Y')}}</span>
                    </h6>

                    <p class="card-text">
                        <strong>{{ $videos->descripcion }}</strong> / {{ $videos->likes()->sum('count') }} star
                    </p>

                    <div class="d-flex justify-content-center">
                        <video id="videoPlayer" class="embed-responsive-item video-player w-100" controls preload="metadata">
                            <source src="{{ asset('rels/'.$videos->nombre) }}" type="video/mp4">
                        </video>
                    </div>

                    <form action="{{ route('videos.like', $videos->id) }}" method="POST" class="mt-3">
                        @csrf
                        <label for="like-range">Selecciona hasta 5 star:</label>
                        <input type="range" id="like-range" name="likes" min="0" max="{{ 5 - $videos->likes()->where('user_id', auth()->id())->sum('count') }}" value="0">
                        <output>{{ 5 - $videos->likes()->where('user_id', auth()->id())->sum('count') }}</output>
                        <button type="submit" class="btn {{ $videos->likes()->where('user_id', auth()->id())->sum('count') >= 5 ? 'btn-danger' : 'btn-success' }}" {{ $videos->likes()->where('user_id', auth()->id())->sum('count') >= 5 ? 'disabled' : '' }}>
                            <i class="bi {{ $videos->likes()->where('user_id', auth()->id())->sum('count') >= 5 ? 'bi-star-half' : 'bi-star-fill' }}"></i> 
                            {{ $videos->likes()->where('user_id', auth()->id())->sum('count') >= 5 ? 'Sin star' : 'Star' }}
                        </button>
                    </form>

                    <div class="dropdown mt-3">
                        <button class="btn btn-primary dropdown-toggle" type="button" id="shareDropdown" data-bs-toggle="dropdown">
                            <i class="bi bi-share-fill"></i> Compartir
                        </button>
                        <ul class="dropdown-menu" aria-labelledby="shareDropdown">
                            <li>
                                <a class="dropdown-item" href="#" onclick="shareReelOnWhatsApp(
                                    '{{ asset('rels/'.$videos->nombre) }}',
                                    '{{ $videos->descripcion }}',
                                    '{{ $videos->user->nombre }}',
                                    '{{ $videos->created_at->format('d M Y') }}'
                                )">
                                    <i class="bi bi-whatsapp"></i> WhatsApp
                                </a>
                            </li>
                        </ul>
                    </div>

                    @foreach ($videos->comments as $comment)
                        <div class="mt-3">
                            <h6 class="card-title d-flex align-items-center">
                                <img src="{{ asset('uploads/avatars/'.$comment->user->fotos) }}" class="img-fluid avatar-lg me-2">
                                @if ($comment->user->id === auth()->id())
                                    <a href="{{ route('perfil') }}" class="text-decoration-none">
                                        <strong>{{ $comment->user->nombre }}</strong>
                                    </a>
                                @else
                                    <a href="{{ route('perfilusuarios', $comment->user->id) }}" class="text-decoration-none">
                                        <strong>{{ $comment->user->nombre }}</strong>
                                    </a>
                                @endif
                            </h6>
                            <div class="alert alert-light mt-1">
                                {{ $comment->comment }}
                            </div>
                        </div>
                    @endforeach

                    @if (session('comentario'))
                        <div class="alert alert-success mt-3">
                            {{ session('comentario') }}
                        </div>
                    @endif

                    <form action="{{ route('video-comments.store') }}" method="POST" class="mt-3">
                        @csrf
                        <div class="input-group">
                            <input type="hidden" name="video_id" value="{{ $videos->id }}">
                            <input type="text" class="form-control" name="comment" placeholder="Agregar comentario">
                            <button class="btn btn-success" type="submit">
                                <i class="bi bi-send-fill"></i> Enviar
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        @endforeach
    </div>
</div>

    </div>
</div>

//home
// import 'package:flutter/material.dart';
// import 'package:iidlive_app/models/post.dart';
// import 'package:iidlive_app/models/reels.dart';

// import 'package:iidlive_app/models/usuarioperfil.dart';
// import 'package:iidlive_app/plantillas/following_screen.dart';
// import 'package:iidlive_app/plantillas/post_card.dart';
// import 'package:iidlive_app/plantillas/sugerencias_screen.dart';
// import 'package:iidlive_app/services/home_services.dart';
// import 'package:iidlive_app/services/post_service.dart';

// import 'package:iidlive_app/widgets/InfluenzometroView.dart';

// import 'package:iidlive_app/widgets/custom_drawer.dart';
// import 'package:iidlive_app/widgets/YoutubePlayerWidget.dart';
// import 'package:intl/intl.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class Home extends StatefulWidget {
//   final Map<String, dynamic> usuario;

//   const Home({Key? key, required this.usuario}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }
// class _HomeState extends State<Home> {
//   final PostService postService = PostService(ApiService());
//   List<Post> _posts = [];
//   List<String> categorias = ['Todos'];
//   String categoriaSeleccionada = 'Todos';
//   int currentPage = 1;
//   bool isLoading = false;
//   bool hasMore = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadCategorias();
//     _loadMorePosts();
//   }

//   Future<void> _loadCategorias() async {
//     try {
//       final cats = await postService.fetchCategorias();
//       setState(() {
//         categorias = ['Todos', ...cats];
//       });
//     } catch (e) {}
//   }

//   Future<void> _loadMorePosts() async {
//     if (isLoading || !hasMore) return;
//     setState(() => isLoading = true);

//     final newPosts = await postService.fetchPosts(widget.usuario['id'],
//       category: categoriaSeleccionada != 'Todos' ? categoriaSeleccionada : null,
//       page: currentPage,
//     );

//     setState(() {
//       _posts.addAll(newPosts);
//       isLoading = false;
//       currentPage++;
//       if (newPosts.isEmpty) {
//         hasMore = false;
//       }
//     });
//   }

//   void _onCategoriaChanged(String? newCategoria) {
//     setState(() {
//       categoriaSeleccionada = newCategoria ?? 'Todos';
//       currentPage = 1;
//       _posts.clear();
//       hasMore = true;
//     });
//     _loadMorePosts();
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: _getUserData(widget.usuario['id']),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError || !snapshot.hasData) {
//           return const Center(child: Text('Error al cargar datos'));
//         } else {
//           final usuario = Usuario.fromJson(snapshot.data!);
//  print('usuario: $usuario');
//           return Scaffold(
//             backgroundColor: Colors.grey[10],
//             appBar: AppBar(
//               backgroundColor: const Color(0xFFC17C9C),
//               title: const Text('Bienvenido a tu muro',
//                   style: TextStyle(color: Colors.white)),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.video_collection,
//                       size: 30, color: Colors.white),
//                   onPressed: () {
//                     final myReel = Reel(
//                       id: 1,
//                       nombre: 'video.mp4',
//                       descripcion: 'Descripción del video',
//                       createdAt: DateTime.now(),
//                       userName: 'Usuario',
//                       userAvatar: 'url_avatar',
//                     );

//                     Navigator.pushNamed(context, '/vistaReels',
//                         arguments: myReel);
//                   },
//                 )
//               ],
//             ),
//             drawer: CustomDrawer(
//               usuario: usuario,
//               parentContext: context,
//               onLogout: () => _logout(context),
//             ),
//             body: Stack(
//               children: [
//                 Container(
//                   color: const Color(0xFFC17C9C),
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   width: double.infinity,
//                 ),
//                 SafeArea(
//                   child: ListView(
//                     padding: EdgeInsets.zero,
//                     children: [
//                       const SizedBox(height: 10),
//                       const SizedBox(
//                           height: 190, child: InfluenzometroContainer()),
//                       const SizedBox(height: 10),
//                       const SizedBox(height: 190, child: SugerenciasScreen()),
//                       const SizedBox(height: 10),
//                       if (categorias.isNotEmpty)
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Row(
//                             children: categorias.map((cat) {
//                               final isSelected = cat == categoriaSeleccionada;
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 4),
//                                 child: ElevatedButton(
//                                   onPressed: () => _onCategoriaChanged(cat),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: isSelected
//                                         ? Colors.deepPurple
//                                         : Colors.grey[300],
//                                     foregroundColor: isSelected
//                                         ? Colors.white
//                                         : Colors.black,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(20)),
//                                   ),
//                                   child: Text(cat),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       const SizedBox(height: 10),
//                       _isLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : _posts.isEmpty
//                               ? const Center(
//                                   child: Text('No hay posts disponibles.'))
//                               : ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: _posts.length,
//                                   itemBuilder: (context, index) {
//                                     final post = _posts[index];

//                                     return Card(
//                                       margin: const EdgeInsets.symmetric(
//                                           horizontal: 12, vertical: 8),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(20)),
//                                       color: Colors.white,
//                                       elevation: 5,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(12),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 CircleAvatar(
//                                                   radius: 20,
//                                                   foregroundImage: NetworkImage(
//                                                       getUserAvatarUrl(
//                                                           post.userAvatar)),
//                                                   backgroundColor:
//                                                       Colors.grey[200],
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         post.userName,
//                                                         style: const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                       const SizedBox(height: 2),
//                                                       Text(
//                                                         formatDate(
//                                                             post.createdAt),
//                                                         style: const TextStyle(
//                                                           color: Color.fromARGB(
//                                                               255, 1, 1, 1),
//                                                           fontSize: 12,
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 2),
//                                                       if (post.nameCategoria
//                                                           .isNotEmpty)
//                                                         Text(
//                                                           post.nameCategoria,
//                                                           style:
//                                                               const TextStyle(
//                                                             color:
//                                                                 Color.fromARGB(
//                                                                     255,
//                                                                     175,
//                                                                     132,
//                                                                     132),
//                                                             fontSize: 12,
//                                                             fontStyle: FontStyle
//                                                                 .italic,
//                                                           ),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 10),
//                                             _buildPostContent(post.content),
//                                             if (post.imageUrl != null &&
//                                                 post.imageUrl!.isNotEmpty)
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 10),
//                                                 child: Image.network(
//                                                 ApiService.getImageUrl(
//                                                       post.imageUrl!),
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                             const Divider(),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 // Like
//                                                 Row(
//                                                   children: [
//                                                     IconButton(
//                                                       icon: Icon(
//                                                         Icons.favorite,
//                                                         color: Colors
//                                                             .red, // Puedes cambiar según el estado de like
//                                                       ),
//                                                       onPressed: () {
//                                                         // Lógica para dar like
//                                                       },
//                                                     ),
//                                                     Text(
//                                                       '${post.likes}',
//                                                       style: const TextStyle(
//                                                           fontSize: 14),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 // Comentarios
//                                                 IconButton(
//                                                   icon:
//                                                       const Icon(Icons.comment),
//                                                   onPressed: () {
//                                                     // Lógica para abrir sección de comentarios
//                                                   },
//                                                 ),
//                                                 // Compartir
//                                                 IconButton(
//                                                   icon: const Icon(Icons.share),
//                                                   onPressed: () {
//                                                     // Lógica para compartir
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//    }
// }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     // AppBar, drawer, etc...

  //     body: Column(
  //       children: [
  //         // Widget para categorías en scroll horizontal
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: Row(
  //             children: categorias.map((cat) {
  //               final isSelected = cat == categoriaSeleccionada;
  //               return ElevatedButton(
  //                 onPressed: () => _onCategoriaChanged(cat),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[300],
  //                   foregroundColor: isSelected ? Colors.white : Colors.black,
  //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //                 ),
  //                 child: Text(cat),
  //               );
  //             }).toList(),
  //           ),
  //         ),

  //         Expanded(
  //           child: NotificationListener<ScrollNotification>(
  //             onNotification: (scrollNotification) {
  //               if (scrollNotification.metrics.pixels >=
  //                   scrollNotification.metrics.maxScrollExtent * 0.9) {
  //                 _loadMorePosts();
  //               }
  //               return false;
  //             },
  //             child: ListView.builder(
  //               itemCount: _posts.length + (hasMore ? 1 : 0),
  //               itemBuilder: (context, index) {
  //                 if (index == _posts.length) {
  //                   // Mostrar indicador de carga cuando cargue más
  //                   return Center(child: CircularProgressIndicator());
  //                 }
  //                 final post = _posts[index];
  //                 return PostCard(
  //                   post: post,
  //                   commentController: TextEditingController(),
  //                 );
  //               },
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

// class _HomeState extends State<Home> {
//   List<Post> _posts = [];
//   bool _isLoading = false;

//   List<String> categorias = ['Todos'];
//   String categoriaSeleccionada = 'Todos';

//   Map<int, TextEditingController> _commentControllers = {};
//   final ApiService apiService = ApiService();
//   @override
//   void initState() {
//     super.initState();
//     _loadCategorias();
//     _loadPosts();
//   }

//   Future<void> _loadPosts() async {
//     if (!mounted)
//       return; // Verificar que el widget esté montado antes de iniciar

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final apiService = ApiService();
//       final posts = await apiService.fetchPosts(
//         widget.usuario['id'],
//         category:
//             categoriaSeleccionada != 'Todos' ? categoriaSeleccionada : null, page: 1,
//       );

//       if (!mounted) return; // Verificar nuevamente antes de llamar setState

//       setState(() {
//         _posts = posts;
//         _isLoading = false;

//         _commentControllers.clear();
//         for (var post in _posts) {
//           _commentControllers[post.id] = TextEditingController();
//         }
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       // Aquí puedes manejar el error, por ejemplo con un snackbar o log
//       // print('Error cargando posts: $e');
//     }
//   }

//   Future<void> _loadCategorias() async {
//     try {
//       final apiService = ApiService();
//       final categoriasApi = await apiService.fetchCategorias();
//       setState(() {
//         categorias = ['Todos', ...categoriasApi];
//         categoriaSeleccionada = 'Todos';
//       });
//     } catch (e) {
//       //print('Error cargando categorías: $e');
//     }
//   }

//   void _onCategoriaChanged(String? newCategoria) {
//     setState(() {
//       categoriaSeleccionada = newCategoria ?? 'Todos';
//     });
//     _loadPosts();
//   }

//   @override
//   void dispose() {
//     // Liberar los controladores de texto
//     for (var controller in _commentControllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   Future<Widget> _buildLinkPreview(String url,
//       {bool fallbackWebView = false}) async {
//     try {
//       final data = await LinkUtils.fetchMetadata(url);

//       if (data != null && (data.image != null || data.title != null)) {
//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 8.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8.0),
//             color: Colors.white,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (data.image != null)
//                 ClipRRect(
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(8.0)),
//                   child: Image.network(
//                     data.image!,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: 200,
//                     errorBuilder: (context, error, stackTrace) =>
//                         Container(height: 200, color: Colors.grey.shade200),
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   data.title ?? url,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 16.0),
//                 ),
//               ),
//               if (data.description != null)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Text(
//                     data.description!,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: GestureDetector(
//                   onTap: () => LinkUtils.openUrl(url),
//                   child: Text(
//                     url,
//                     style: const TextStyle(color: Colors.blue),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       } else if (fallbackWebView) {
//         return SizedBox(
//           height: 400,
//           child: InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(url)),
//           ),
//         );
//       } else {
//         return Text(url);
//       }
//     } catch (e) {
//       // En caso de error, mostrar simplemente el link
//       return Text(url);
//     }
//   }

//   Widget _buildPostContent(String content) {
//     final youtubeRegex =
//         RegExp(r'(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/[^\s]+');
//     final tiktokRegex =
//         RegExp(r'(https?:\/\/)?(www\.)?(tiktok\.com|vm\.tiktok\.com)\/[^\s]+');
//     final linkRegex = RegExp(r'https?:\/\/[^\s]+');

//     final youtubeMatch = youtubeRegex.firstMatch(content);
//     final tiktokMatch = tiktokRegex.firstMatch(content);
//     final linkMatch = linkRegex.firstMatch(content);

//     if (youtubeMatch != null) {
//       final videoUrl = youtubeMatch.group(0)!;
//       final videoId = LinkUtils.extractYouTubeId(videoUrl);
//       return GestureDetector(
//         onTap: () => LinkUtils.openUrl(videoUrl),
//         child: YoutubePlayerWidget(videoId: videoId),
//       );
//     } else if (tiktokMatch != null) {
//       final tiktokUrl = tiktokMatch.group(0)!;
//       return GestureDetector(
//         onTap: () => LinkUtils.openUrl(tiktokUrl),
//         child: SizedBox(
//           height: 400,
//           child: InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(tiktokUrl)),
//           ),
//         ),
//       );
//     } else if (linkMatch != null) {
//       final linkUrl = linkMatch.group(0)!;
//       return FutureBuilder<Widget>(
//         future: _buildLinkPreview(linkUrl),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const CircularProgressIndicator();
//           } else if (snapshot.hasData) {
//             return GestureDetector(
//               onTap: () => LinkUtils.openUrl(linkUrl),
//               child: snapshot.data!,
//             );
//           } else {
//             return Text(content);
//           }
//         },
//       );
//     } else {
//       return Text(content);
//     }
//   }

//   Future<Map<String, dynamic>?> _getUserData(int userId) async {
//     final apiService = ApiService();
//     return await apiService.fetchUserData(userId);
//   }

//   Future<void> _logout(BuildContext context) async {
//     final apiService = ApiService();
//     await apiService.logout();
//     Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//   }

//   String formatDate(String dateString) {
//     DateTime dateTime = DateTime.parse(dateString);
//     return DateFormat('yyyy/MM/dd kk:mm a').format(dateTime);
//   }

  
//   @override
//   Widget build(BuildContext context) {
    
//     return FutureBuilder<Map<String, dynamic>?>(
//       future: _getUserData(widget.usuario['id']),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError || !snapshot.hasData) {
//           return const Center(child: Text('Error al cargar datos'));
//         } else {
//           final usuario = Usuario.fromJson(snapshot.data!);
//  print('usuario: $usuario');
//           return Scaffold(
//             backgroundColor: Colors.grey[10],
//             appBar: AppBar(
//               backgroundColor: const Color(0xFFC17C9C),
//               title: const Text('Bienvenido a tu muro',
//                   style: TextStyle(color: Colors.white)),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.video_collection,
//                       size: 30, color: Colors.white),
//                   onPressed: () {
//                     final myReel = Reel(
//                       id: 1,
//                       nombre: 'video.mp4',
//                       descripcion: 'Descripción del video',
//                       createdAt: DateTime.now(),
//                       userName: 'Usuario',
//                       userAvatar: 'url_avatar',
//                     );

//                     Navigator.pushNamed(context, '/vistaReels',
//                         arguments: myReel);
//                   },
//                 )
//               ],
//             ),
//             drawer: CustomDrawer(
//               usuario: usuario,
//               parentContext: context,
//               onLogout: () => _logout(context),
//             ),
//             body: Stack(
//               children: [
//                 Container(
//                   color: const Color(0xFFC17C9C),
//                   height: MediaQuery.of(context).size.height * 0.6,
//                   width: double.infinity,
//                 ),
//                 SafeArea(
//                   child: ListView(
//                     padding: EdgeInsets.zero,
//                     children: [
//                       const SizedBox(height: 10),
//                       const SizedBox(
//                           height: 190, child: InfluenzometroContainer()),
//                       const SizedBox(height: 10),
//                       const SizedBox(height: 190, child: SugerenciasScreen()),
//                       const SizedBox(height: 10),
//                       if (categorias.isNotEmpty)
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Row(
//                             children: categorias.map((cat) {
//                               final isSelected = cat == categoriaSeleccionada;
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 4),
//                                 child: ElevatedButton(
//                                   onPressed: () => _onCategoriaChanged(cat),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: isSelected
//                                         ? Colors.deepPurple
//                                         : Colors.grey[300],
//                                     foregroundColor: isSelected
//                                         ? Colors.white
//                                         : Colors.black,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(20)),
//                                   ),
//                                   child: Text(cat),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       const SizedBox(height: 10),
//                       _isLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : _posts.isEmpty
//                               ? const Center(
//                                   child: Text('No hay posts disponibles.'))
//                               : ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: _posts.length,
//                                   itemBuilder: (context, index) {
//                                     final post = _posts[index];

//                                     return Card(
//                                       margin: const EdgeInsets.symmetric(
//                                           horizontal: 12, vertical: 8),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(20)),
//                                       color: Colors.white,
//                                       elevation: 5,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(12),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 CircleAvatar(
//                                                   radius: 20,
//                                                   foregroundImage: NetworkImage(
//                                                       getUserAvatarUrl(
//                                                           post.userAvatar)),
//                                                   backgroundColor:
//                                                       Colors.grey[200],
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .start,
//                                                     children: [
//                                                       Text(
//                                                         post.userName,
//                                                         style: const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                       const SizedBox(height: 2),
//                                                       Text(
//                                                         formatDate(
//                                                             post.createdAt),
//                                                         style: const TextStyle(
//                                                           color: Color.fromARGB(
//                                                               255, 1, 1, 1),
//                                                           fontSize: 12,
//                                                         ),
//                                                       ),
//                                                       const SizedBox(height: 2),
//                                                       if (post.nameCategoria
//                                                           .isNotEmpty)
//                                                         Text(
//                                                           post.nameCategoria,
//                                                           style:
//                                                               const TextStyle(
//                                                             color:
//                                                                 Color.fromARGB(
//                                                                     255,
//                                                                     175,
//                                                                     132,
//                                                                     132),
//                                                             fontSize: 12,
//                                                             fontStyle: FontStyle
//                                                                 .italic,
//                                                           ),
//                                                         ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             const SizedBox(height: 10),
//                                             _buildPostContent(post.content),
//                                             if (post.imageUrl != null &&
//                                                 post.imageUrl!.isNotEmpty)
//                                               Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 10),
//                                                 child: Image.network(
//                                                   apiService.getImageUrl(
//                                                       post.imageUrl!),
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                             const Divider(),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 // Like
//                                                 Row(
//                                                   children: [
//                                                     IconButton(
//                                                       icon: Icon(
//                                                         Icons.favorite,
//                                                         color: Colors
//                                                             .red, // Puedes cambiar según el estado de like
//                                                       ),
//                                                       onPressed: () {
//                                                         // Lógica para dar like
//                                                       },
//                                                     ),
//                                                     Text(
//                                                       '${post.likes}',
//                                                       style: const TextStyle(
//                                                           fontSize: 14),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 // Comentarios
//                                                 IconButton(
//                                                   icon:
//                                                       const Icon(Icons.comment),
//                                                   onPressed: () {
//                                                     // Lógica para abrir sección de comentarios
//                                                   },
//                                                 ),
//                                                 // Compartir
//                                                 IconButton(
//                                                   icon: const Icon(Icons.share),
//                                                   onPressed: () {
//                                                     // Lógica para compartir
//                                                   },
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }
  // Future<void> loadUserReels(int userId) async {
  //   try {
  //     // Llamas a fetchReels con el userId del usuario logueado o deseado
  //     List<Reel> reels = await ReelService.fetchReels(userId: userId);

  //     // Aquí haces lo que quieras con los reels, por ejemplo guardarlos en estado
  //     setState(() {
  //       _reels = reels; // _reels es una lista de tipo List<Reel> en tu widget
  //     });
  //   } catch (e) {
  //     //print('Error al cargar reels: $e');
  //   }
  // }
//   static Future<List<Reel>> fetchReels({
//   required int userId,
//   String? selectedCategory,
// }) async {
//   const String baseUrl = "https://iidlive.com";

//   // Construir URL dependiendo si hay categoría o no
//   final String apiUrl = selectedCategory == null
//       ? "$baseUrl/api/reel?user_id=$userId"
//       : "$baseUrl/api/reel?user_id=$userId&category=$selectedCategory";

//   final token = await _getTokenFromStorage();

//   final response = await http.get(
//     Uri.parse(apiUrl),
//     headers: {
//       'Accept': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     },
//   );

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     List<Reel> reels = [];

//     if (data['reels'] != null) {
//       for (var item in data['reels']) {
//         reels.add(Reel.fromJson(item));
//       }
//     }

//     return reels;
//   } else {
//     throw Exception('Fallo al cargar los reels');
//   }
// }


  /// ✅ Agregar o quitar reacción (LIKE, LOVE, HAPPY)
//  static Future<bool> updateReaction(int videoId, String reaction, bool isAdding) async {
//   final url = Uri.parse(baseUrl);

//   final response = isAdding
//       ? await http.post(
//           url,
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode({
//             "video_id": videoId,
//             "reaction": reaction,
//           }),
//         )
//       : await http.delete(
//           url,
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode({
//             "video_id": videoId,
//             "reaction": reaction,
//           }),
//         );

//   if (response.statusCode == 200) {
//     final result = jsonDecode(response.body);
//     return result['success'] ?? false;
//   }
//   return false;
// }

//   /// ✅ Obtener reacciones de un video específico
//   static Future<Map<String, int>> getReactions(int videoId) async {
//     final url = Uri.parse("$baseUrl?video_id=$videoId");
//     final response = await http.get(url);

//     print("Respuesta API: ${response.body}"); // 👀 Depuración

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data == null || !data.containsKey("reels")) {
//         throw Exception("La respuesta no contiene datos de reacciones");
//       }

//       final reel = data['reels'].firstWhere(
//         (r) => r['video_id'].toString() == videoId.toString(),
//         orElse: () => null,
//       );

//       if (reel == null) throw Exception("No se encontró el video");

//       return {
//         "likes": reel['likes'] ?? 0,
        
//       };
//     } else {
//       throw Exception("Error al obtener reacciones");
//     }
//   }

//   /// ✅ Guardar reacción (LIKE, LOVE, HAPPY)
//   static Future<void> saveReaction(int videoId, String reaction) async {
//     await updateReaction(videoId, reaction, true);
//   }

//   /// ✅ Eliminar reacción (LIKE, LOVE, HAPPY)
//   static Future<void> removeReaction(int videoId, String reaction) async {
//     await updateReaction(videoId, reaction, false);
//   }
//}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/reels.dart';

// class ReelService {
//    //static const String baseUrl = 'http://172.20.10.2:8080/plataforma/get_reels.php';
//   static const String baseUrl = 'http://192.168.50.54:8080/plataforma/get_reels.php';

//   static Future<List<Reel>> fetchReels() async {
//     final url = Uri.parse(baseUrl);
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final List<dynamic> reelsJson = data['reels'];
//       return reelsJson.map((json) => Reel.fromJson(json)).toList();
//     } else {
//       throw Exception('Error al cargar los reels');
//     }
//   }
//    Future<bool> updateReaction(String videoId, String reaction, bool isAdding) async {
//    final url = Uri.parse('http://192.168.50.54:8080/plataforma/get_reels.php');
//    final response = await http.post(
//      url,
//      headers: {"Content-Type": "application/json"},
//      body: jsonEncode({
//        "video_id": videoId,
//        "reaction": reaction,
//      }),
//    );

//    if (response.statusCode == 200) {
//      return jsonDecode(response.body)['success'] ?? false;
//    }
//    return false;
//  }

//   static Future<Map<String, dynamic>> getReactions(int videoId) async {
//   final response = await http.get(
//         Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),

//     // Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),
//   );

//   print("Respuesta API: ${response.body}"); // 👀 Depuración

//   if (response.statusCode == 200) {
//     if (response.body.isEmpty) {
//       throw Exception("La respuesta está vacía");
//     }

//     var data = jsonDecode(response.body);
//     if (data == null) {
//       throw Exception("La respuesta es nula");
//     }

//     return data;
//   } else {
//     throw Exception("Error al obtener reacciones");
//   }
// }

// // static Future<Map<String, dynamic>> getReactions(int videoId) async {
// //   final response = await http.get(
// //         Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),

// //     // Uri.parse("http://172.20.10.2:8080/plataforma/get_reels.php?video_id=$videoId"),
// //   );

// //   if (response.statusCode == 200) {
// //     if (response.body.isEmpty) {
// //       throw Exception("La respuesta está vacía");
// //     }

// //     var data = jsonDecode(response.body);
// //     if (data == null) {
// //       throw Exception("La respuesta es nula");
// //     }

// //     return data;
// //   } else {
// //     throw Exception("Error al obtener reacciones");
// //   }
// // }


//   static Future<void> saveReaction(int videoId, String reaction) async {
//     final response = await http.post(
//       Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php"),
//       // Uri.parse("http://172.20.10.2:8080/plataforma/get_reels.php"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "video_id": videoId,
//         "reaction": reaction,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception("Error al guardar la reacción: ${response.body}");
//     }
//   }
// static Future<void> removeReaction(int videoId, String reaction) async {
//   final response = await http.delete(
//     Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId&reaction=$reaction"),

// // Uri.parse("http://172.20.10.2:8080/plataforma/get_reels.php?video_id=$videoId&reaction=$reaction"),
//     headers: {"Content-Type": "application/json"},
//   );

//   if (response.statusCode == 200) {
//     print("Reacción eliminada correctamente");
//   } else {
//     print("Error al eliminar la reacción: ${response.body}");
//   }
// }
// }
  // static Future<void> removeReaction(int videoId, String reaction) async {
  //   final response = await http.delete(
  //     Uri.parse("http://192.168.50.54:8080/plataforma/likes.php"),
  //     // Uri.parse("http://172.20.10.2:8080/plataforma/likes.php"),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "video_id": videoId,
  //       "reaction": reaction,
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception("Error al eliminar la reacción");
  //   }
  // }
//}
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/reels.dart';

// class ReelService {
//   static Future<List<Reel>> fetchReels() async {
//     final response = await http.get(Uri.parse('http://192.168.50.54:8080/plataforma/get_reels.php'));

//     print('🔹 Respuesta del servidor: ${response.body}');

//     if (response.statusCode == 200) {
//       try {
//         final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

//         if (data.containsKey('reels') && data['reels'] is List) {
//           return (data['reels'] as List).map((item) => Reel.fromJson(item)).toList();
//         } else {
//           print('⚠️ No hay reels en la respuesta.');
//           return [];
//         }
//       } catch (e) {
//         print('❌ Error al decodificar JSON: $e');
//         return [];
//       }
//     } else {
//       throw Exception('⚠️ Error al cargar reels: ${response.statusCode}');
//     }
//   }
// }

// reels_services.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/reels.dart';

// class ReelService {
//   static const String baseUrl = 'http://192.168.50.54:8080/plataforma/get_reels.php';
//   //static const String baseUrl ="http://172.20.10.2:8080/plataforma/get_reels.php";
//   static Future<List<Reel>> fetchReels() async {
//     final url = Uri.parse(baseUrl);
//     // final url = Uri.parse('$baseUrl/get_reels.php');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final List<dynamic> reelsJson = data['reels'];
//       return reelsJson.map((json) => Reel.fromJson(json)).toList();
//     } else {
//       throw Exception('Error al cargar los reels');
//     }
//   }
//   static Future<Map<String, dynamic>> getReactions(int videoId) async {
//   final response = await http.get(
//     Uri.parse("http://192.168.50.54:8080/plataforma/likes.php?video_id=$videoId"),
//   );

//   if (response.statusCode == 200) {
//     return jsonDecode(response.body);
//   } else {
//     throw Exception("Error al obtener reacciones");
//   }
// }

// static Future<void> saveReaction(int videoId, String reaction) async {
//   final response = await http.post(
//     Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php"),
//     headers: {"Content-Type": "application/json"},
//     body: jsonEncode({
//       "video_id": videoId,
//       "reaction": reaction,
//     }),
//   );

//   if (response.statusCode != 200) {
//     throw Exception("Error al guardar la reacción: ${response.body}");
//   }
// }

// static Future<void> removeReaction(int videoId, String reaction) async {
//   final response = await http.delete(
//     Uri.parse("http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId"),
//   );

//   if (response.statusCode != 200) {
//     throw Exception("Error al eliminar la reacción: ${response.body}");
//   }
// }


//   // static Future<void> saveReaction(int videoId, String reaction) async {
//   //   final response = await http.post(
//   //     Uri.parse(baseUrl),
//   //     headers: {"Content-Type": "application/json"},
//   //     body: jsonEncode({
//   //       "video_id": videoId,
//   //       "reaction": reaction,
//   //     }),
//   //   );

//   //   if (response.statusCode != 200) {
//   //     throw Exception("Error al guardar la reacción: ${response.body}");
//   //   }
//   // }

//   // static Future<void> removeReaction(int videoId, String reaction) async {
//   //   final response = await http.delete(
//   //     Uri.parse(baseUrl),
//   //     headers: {"Content-Type": "application/json"},
//   //     body: jsonEncode({
//   //       "video_id": videoId,
//   //       "reaction": reaction,
//   //     }),
//   //   );

//   //   if (response.statusCode != 200) {
//   //     throw Exception("Error al eliminar la reacción: ${response.body}");
//   //   }
//   // }
//   static Future<Map<String, dynamic>> getUserReaction(int videoId) async {
//    final response = await http.get(
//      Uri.parse('http://192.168.50.54:8080/plataforma/get_reels.php?video_id=$videoId'),
//    );

//    if (response.statusCode == 200) {
//      final data = jsonDecode(response.body);
//      return {
//        "userReaction": data['user_reaction'], 
//        "reactionsCount": data['reactions_count']
//      };
//    } else {
//      throw Exception("Error al obtener las reacciones del usuario");
//    }
//  }


  
// }

  // // Implementación para guardar o actualizar la reacción
  // static Future<void> saveReaction(dynamic videoId, String reaction) async {
  //   final url = Uri.parse('$baseUrl/save_reaction.php');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'video_id': videoId,
  //       'reaction': reaction,
  //       // Puedes incluir otros datos, por ejemplo, el ID del usuario
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Error al guardar la reacción. Código: ${response.statusCode}');
  //   }
  // }

  // // Implementación para eliminar la reacción del usuario para un video
  // static Future<void> removeReaction(dynamic videoId) async {
  //   final url = Uri.parse('$baseUrl/remove_reaction.php');
  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({
  //       'video_id': videoId,
  //       // Si es necesario, puedes enviar otros parámetros (como el ID del usuario)
  //     }),
  //   );

  //   if (response.statusCode != 200) {
  //     throw Exception('Error al eliminar la reacción. Código: ${response.statusCode}');
  //   }
  // }

  // import 'package:flutter/material.dart';
// import 'package:iidlive_app/models/post.dart';
// import 'package:iidlive_app/models/reels.dart';
// import 'package:iidlive_app/models/comment.dart';
// import 'package:iidlive_app/models/usuarioperfil.dart';
// import 'package:iidlive_app/plantillas/following_screen.dart';
// import 'package:iidlive_app/plantillas/post_card.dart';
// import 'package:iidlive_app/plantillas/sugerencias_screen.dart';
// import 'package:iidlive_app/services/home_services.dart';
// import 'package:iidlive_app/services/post_service.dart';
// import 'package:iidlive_app/widgets/InfluenzometroView.dart';
// import 'package:iidlive_app/widgets/custom_drawer.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:intl/intl.dart';

// class Home extends StatefulWidget {
//   final Map<String, dynamic> usuario;

//   const Home({Key? key, required this.usuario}) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final PostService postService = PostService(ApiService());

//   Map<String, dynamic>? _usuarioData;
//   bool _loadingUsuario = true;
//   bool _errorUsuario = false;

//   List<Post> _posts = [];
//   List<String> categorias = ['Todos'];
//   String categoriaSeleccionada = 'Todos';
//   int currentPage = 1;
//   bool isLoading = false;
//   bool hasMore = true;
//   final Map<String, String> emojiToNombre = {
//     '🔥': 'me_prendio',
//     '😂': 'me_hizo_reir',
//     '😱': 'que_fuerte',
//     '💀': 'me_mori',
//     '👀': 'estoy_viendo',
//     '💔': 'me_dolio',
//     '🤡': 'payasada',
//     '🤯': 'mind_blown',
//     '🗑️': 'basura',
//     '🌟': 'inspirador',
    
//   };

//   // Inverse map for nombre to emoji
//   late final Map<String, String> nombreToEmoji = {
//     for (var entry in emojiToNombre.entries) entry.value: entry.key
    
//   };

//   final homeService = ApiService();
//   @override
//   void initState() {
//     super.initState();

//     // await _loadCategorias();
//     //await _loadMorePosts();Cargar datos de usuario fuera del build con post frame callback
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final userId = widget.usuario['id'] as int?;
//       if (userId == null) {
//         setState(() {
//           _errorUsuario = true;
//           _loadingUsuario = false;
//         });
//         return;
//       }
//       try {
//         final data = await homeService.fetchUserData(userId);
//         setState(() {
//           _usuarioData = data;
//           _loadingUsuario = false;
//         });
//         await _loadCategorias();
//         await _loadMorePosts();
//       } catch (e) {
//         setState(() {
//           _errorUsuario = true;
//           _loadingUsuario = false;
//         });
//       }
//     });
//   }

//   void _mostrarSoloEmojis(BuildContext context, Function(String) onSelect) {
//     final emojis = [
//       '🔥',
//       '😂',
//       '😱',
//       '💀',
//       '👀',
//       '💔',
//       '🤡',
//       '🤯',
//       '🗑️',
//       '🌟'
//     ];

//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       builder: (_) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: emojis.map((emoji) {
//             return GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pop();
//                 onSelect(emoji);
//               },
//               child: Text(emoji, style: const TextStyle(fontSize: 30)),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }


//   Future<void> _loadCategorias() async {
//     try {
//       final cats = await postService.fetchCategorias();
//       setState(() {
//         categorias = ['Todos', ...cats];
//       });
//     } catch (e) {
//       // Puedes manejar el error si quieres
//     }
//   }

//   Future<void> _loadMsync {
//     if (isLoading || !hasMore) return;
//     setState(() => isLoading = true);

//     try {
//       final newPosts = await postService.fetchAllPosts(
//         page: currentPage,
//         category:
//             categoriaSeleccionada != 'Todos' ? categoriaSeleccionada : null,
//       );

//       setState(() {
//         _posts.addAll(newPosts);
//         currentPage++;
//         if (newPosts.isEmpty) {
//           hasMore = false;
//         }
//       });
//     } catch (e) {
//       print('Error al cargar posts: $e');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _onCategoriaChanged(String? newCategoria) {
//     setState(() {
//       categoriaSeleccionada = newCategoria ?? 'Todos';
//       currentPage = 1;
//       _posts.clear();
//       hasMore = true;
//     });
//     _loadMorePosts();
//   }

//   String formatDate(DateTime dateTime) {
//     return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
//   }

//   Future<void> _logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('usuario');
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loadingUsuario) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_errorUsuario || _usuarioData == null) {
//       return const Scaffold(
//         body: Center(child: Text('Error al cargar datos')),
//       );
//     }

//     final usuario = Usuario.fromJson(_usuarioData!);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFC17C9C),
//         title: const Text('Bienvenido a tu muro',
//             style: TextStyle(color: Colors.white)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.video_collection,
//                 size: 30, color: Colors.white),
//             onPressed: () {
//               final myReel = Reel(
//                 id: 1,
//                 nombre: 'video.mp4',
//                 descripcion: 'Descripción del video',
//                 createdAt: DateTime.now(),
//                 userName: 'Usuario',
//                 userAvatar: 'url_avatar',
//                 likes: 0,
//                 commentsCount: 0,
//               );

//               Navigator.pushNamed(context, '/vistaReels', arguments: myReel);
//             },
//           )
//         ],
//       ),
//       drawer: CustomDrawer(
//         usuario: usuario,
//         parentContext: context,
//         onLogout: () => _logout(context),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             color: const Color(0xFFC17C9C),
//             height: MediaQuery.of(context).size.height * 0.6,
//             width: double.infinity,
//           ),
//           SafeArea(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 const SizedBox(height: 10),
//                 const SizedBox(height: 190, child: InfluenzometroContainer()),
//                 const SizedBox(height: 10),
//                 const SizedBox(height: 190, child: SugerenciasScreen()),
//                 const SizedBox(height: 10),
//                 if (categorias.isNotEmpty)
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Row(
//                       children: categorias.map((cat) {
//                         final isSelected = cat == categoriaSeleccionada;
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 4),
//                           child: ElevatedButton(
//                             onPressed: () => _onCategoriaChanged(cat),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: isSelected
//                                   ? Colors.deepPurple
//                                   : Colors.grey[300],
//                               foregroundColor:
//                                   isSelected ? Colors.white : Colors.black,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                             child: Text(cat),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 const SizedBox(height: 10),
//                 if (isLoading && _posts.isEmpty)
//                   const Center(child: CircularProgressIndicator())
//                 else if (_posts.isEmpty)
//                   const Center(child: Text('No hay posts disponibles'))
//                 else
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: _posts.length + (hasMore ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (index == _posts.length) {
//                         // Indicador de carga al final para paginación
//                         // _loadMorePosts();
//                         return const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 10),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }

//                       final post = _posts[index];
//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20)),
//                         color: Colors.white,
//                         elevation: 5,
//                         child: Padding(
//                           padding: const EdgeInsets.all(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 20,
//                                     foregroundImage: NetworkImage(
//                                         getUserAvatarUrl(post.userAvatar)),
//                                     backgroundColor: Colors.grey[200],
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           post.userName,
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.bold),
//                                         ),
//                                         const SizedBox(height: 2),
//                                         Text(
//                                           formatDate(
//                                               DateTime.parse(post.createdAt)),
//                                           style: const TextStyle(
//                                             color: Color.fromARGB(255, 1, 1, 1),
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 2),
//                                         if (post.nameCategoria.isNotEmpty)
//                                           Text(
//                                             post.nameCategoria,
//                                             style: const TextStyle(
//                                               color: Color.fromARGB(
//                                                   255, 175, 132, 132),
//                                               fontSize: 12,
//                                               fontStyle: FontStyle.italic,
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 10),
//                               PostWidget(content: post.content),
//                               if (post.imageUrl != null &&
//                                   post.imageUrl!.isNotEmpty)
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 10),
//                                   child: Image.network(
//                                     postService.apiService
//                                         .getImageUrl(post.imageUrl!),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               const Divider(),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//        children: [
//     Row(
//       children: [
//         IconButton(
//           icon: Text(
//             post.reaccionUsuario != null
//                 ? emojiToNombre.entries
//                     .firstWhere(
//                         (e) => e.value == post.reaccionUsuario,
//                         orElse: () => const MapEntry('😊', ''))
//                     .key
//                 : '😊',
//             style: const TextStyle(fontSize: 24),
//           ),
//           onPressed: () {
//             _mostrarSoloEmojis(context, (emoji) async {
//               final tipo = emojiToNombre[emoji];
//               if (tipo == null) {
//                 print('❌ Reacción inválida');
//                 return;
//               }

//               await postService.enviarReaccion(post.id.toString(), tipo);
//               setState(() {
//                 post.reaccionUsuario = tipo;
//                 post.reaccionesTotales ??= {};
//                 post.reaccionesTotales![tipo] =
//                     (post.reaccionesTotales![tipo] ?? 0) + 1;
//               });
//             });
//           },
//         ),
//       ],
//     ),
//     if (post.reaccionesTotales != null &&
//         post.reaccionesTotales!.isNotEmpty)
//       Padding(
//         padding: const EdgeInsets.only(top: 6),
//         child: Wrap(
//           spacing: 8,
//           runSpacing: 4,
//           children: post.reaccionesTotales!.entries.map((entry) {
//             final emoji = nombreToEmoji[entry.key] ?? '';
//             final count = entry.value;
//             return Chip(
//               backgroundColor: Colors.grey[200],
//               label: Text('$emoji $count'),
//             );
//           }).toList(),
//         ),
//       ),


//                                   // Comentarios
//                                   // parte del widget debajo de cada post en home.dart
// Column(
//   children: [
//     // Mostrar comentarios
//     if (post.comentarios != null && post.comentarios.isNotEmpty)
//       ...post.comentarios.map((comment) {
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundImage: NetworkImage(getUserAvatarUrl(comment.userAvatar)),
//             radius: 16,
//           ),
//           title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: Text(comment.body),
//         );
//       }).toList(),

//     // Formulario para enviar nuevo comentario
//     Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _commentController,
//               decoration: const InputDecoration(
//                 hintText: 'Escribe un comentario...',
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send),
//             onPressed: () async {
//               final body = _commentController.text.trim();
//               if (body.isNotEmpty) {
//                 await postService.enviarComentario(
//                   postId: post.id,
//                   body: body,
//                   tipo: 'App\\Models\\Post',
//                 );
//                 _commentController.clear();
//                 setState(() {}); // Refrescar si quieres mostrar el nuevo comentario
//               }
//             },
//           ),
//         ],
//       ),
//     ),
//   ],
// )
//                                   // Compartir
//                                   // IconButton(
//                                   //   icon: const Icon(Icons.share),
//                                   //   onPressed: () {
//                                   //     // Lógica para compartir
//                                   //   },
//                                   // ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// class Reel {
//   final String videoId;
//   final String videoName;
//   final String videoDescription;
//   final String videoUserId;
//   final DateTime videoCreatedAt;
//   final Map<String, int> reactions;
//   final String userName;
//   final String userAvatar;

//   Reel({
//     required this.videoId,
//     required this.videoName,
//     required this.videoDescription,
//     required this.videoUserId,
//     required this.videoCreatedAt,
//     required this.reactions,
//     required this.userName,
//     required this.userAvatar,
//   });

//   factory Reel.fromJson(Map<String, dynamic> json) {
//   return Reel(
//     videoId: json['video_id'] ?? '',
//     videoName: json['video_name'] ?? '',
//     videoDescription: json['video_description'] ?? '',
//     videoUserId: json['video_user_id'] ?? '',
//     videoCreatedAt: json['video_created_at'] != null
//         ? DateTime.parse(json['video_created_at'])
//         : DateTime.now(),
//     userName: json['user_name'] ?? '',
//     userAvatar: json['user_avatar'] ?? '',
//     reactions: {
//       "likes": json['likes'] ?? 0,
//       "love": json['love'] ?? 0,
//       "happy": json['happy'] ?? 0,
//     },
//   );
// }

// }


// class Reel {
//   final String videoId;
//   final String videoName;
//   final String videoDescription;
//   final String videoUserId;
//   final DateTime videoCreatedAt;
//   final Map<String, dynamic>? likes; // ✅ Ahora es un Mapa en vez de un String
//   final String userName;
//   final String userAvatar;

//   // Constructor de la clase Reel
//   Reel({
//     required this.videoId,
//     required this.videoName,
//     required this.videoDescription,
//     required this.videoUserId,
//     required this.videoCreatedAt,
//     this.likes,
//     required this.userName,
//     required this.userAvatar,
//   });

//   factory Reel.fromJson(Map<String, dynamic> json) {
//     return Reel(
//       videoId: json['video_id'] as String? ?? '', // Si es null, usa un valor vacío
//       videoName: json['video_name'] as String? ?? '', // Si es null, usa un valor vacío
//       videoDescription: json['video_description'] as String? ?? '', // Si es null, usa un valor vacío
//       videoUserId: json['video_user_id'] as String? ?? '', // Si es null, usa un valor vacío
//       videoCreatedAt: json['video_created_at'] != null
//           ? DateTime.parse(json['video_created_at'] as String)
//           : DateTime.now(), // Si es null, usa la fecha actual
//       userName: json['user_name'] as String? ?? '', // Si es null, usa un valor vacío
//       likes: json['likes'] as Map<String, dynamic>?, // ✅ Se asigna correctamente como Mapa
//       userAvatar: json['user_avatar'] as String? ?? '', // Si es null, usa un valor vacío
//     );
//   }
// }

// // class Reel {
// //   final int id;
// //   final String title;
// //   final String videoUrl;
// //   final String thumbnail;
// //   final String createdAt;

// //   Reel({
// //     required this.id,
// //     required this.title,
// //     required this.videoUrl,
// //     required this.thumbnail,
// //     required this.createdAt,
// //   });

// //   factory Reel.fromJson(Map<String, dynamic> json) {
// //     return Reel(
// //       id: json['id'],
// //       title: json['title'],
// //       videoUrl: json['video_url'],
// //       thumbnail: json['thumbnail'],
// //       createdAt: json['created_at'],
// //     );
// //   }
// // }
// /uniimarecursoshumanos@gmail.com


  // Mostrar comentarios con subcomentarios anidados
                        // const SizedBox(height: 10),

                        // if (widget.reel.comentarios != null &&
                        //     widget.reel.comentarios!.isNotEmpty)
                        //   Column(
                        //     children: widget.reel.comentarios!
                        //         .map((comentarios) =>
                        //             _buildCommentWithReplies(comentarios))
                        //         .toList(),
                        //   )
                        // else
                        //   const Padding(
                        //     padding: EdgeInsets.symmetric(
                        //         horizontal: 12.0, vertical: 4),
                        //     child: Text(
                        //       'No hay comentarios aún.',
                        //       style: TextStyle(color: Colors.grey),
                        //     ),
                        //   ),


                            // Text(
                            //   widget.reel.likes.toString(),
                            //   style: const TextStyle(color: Colors.white),
                            // ),
                            // const SizedBox(width: 16),

                            // const SizedBox(width: 4),
                            // Este bloque reemplaza el bloque de comentarios que tenías

                            /*este el comentario bueno por si no se ven los comentarios sin fecha*/
  // Widget _buildCommentWithReplies(Comment comment) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 14,
  //               backgroundImage: NetworkImage(getAvatarUrl(comment.userAvatar)),
  //             ),
  //             const SizedBox(width: 8),
  //             Text(comment.userName,
  //                 style: const TextStyle(color: Colors.white)),
  //           ],
  //         ),
  //         const SizedBox(height: 4),
  //         Padding(
  //           padding: const EdgeInsets.only(left: 36),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(comment.body,
  //                   style: const TextStyle(color: Colors.white70)),
  //               const SizedBox(height: 4),
  //               GestureDetector(
  //                 onTap: () {
  //                   _mostrarFormularioRespuesta(comment.id!);
  //                 },
  //                 child: const Text("Responder",
  //                     style: TextStyle(color: Colors.blueAccent)),
  //               ),
  //               if (_replyingToCommentId == comment.id)
  //                 _commentForm(parentId: comment.id),

  //               // ✅ Llamada recursiva para mostrar subcomentarios
  //               ...comment.replies
  //                   .map((reply) => _buildCommentWithReplies(reply))
  //                   .toList(),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }