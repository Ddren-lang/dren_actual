import 'package:flutter/material.dart';
import 'package:dren/models/post.dart';
import 'package:dren/models/comment.dart';
import 'package:dren/models/reels.dart';
import 'package:dren/models/usuarioperfil.dart';
import 'package:dren/plantillas/following_screen.dart';
import 'package:dren/plantillas/post_card.dart';
import 'package:dren/plantillas/sugerencias_screen.dart';
import 'package:dren/services/home_services.dart';
import 'package:dren/services/post_service.dart';
import 'package:dren/widgets/InfluenzometroView.dart';
import 'package:dren/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const Home({Key? key, required this.usuario}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PostService postService = PostService(ApiService());

  Map<String, dynamic>? _usuarioData;
  bool _loadingUsuario = true;
  bool _errorUsuario = false;
  Map<int?, List<Comment>> agruparSubcomentarios(List<Comment> comentarios) {
    final Map<int?, List<Comment>> mapa = {};

    void recorrer(Comment comment) {
      mapa.putIfAbsent(comment.parentId, () => []).add(comment);
      for (var reply in comment.replies) {
        recorrer(reply);
      }
    }

    for (var comment in comentarios) {
      recorrer(comment);
    }

    return mapa;
  }

  List<Comment> parseComentarios(dynamic jsonList) {
    if (jsonList == null) return [];

    List<Comment> todos = [];

    for (var json in jsonList) {
      Comment principal = Comment.fromJson(json);
      todos.add(principal);

      // Agregar subcomentarios si existen
      if (principal.replies.isNotEmpty) {
        todos.addAll(principal.replies);
      }
    }

    print('Cantidad de comentarios parseados: ${todos.length}');
    return todos;
  }

  List<Post> _posts = [];
  List<String> categorias = ['Todos'];
  String categoriaSeleccionada = 'Todos';
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  int? _comentarioIdRespondiendo;
  final Map<String, String> emojiToNombre = {
    '🔥': 'me_prendio',
    '😂': 'me_hizo_reir',
    '😱': 'que_fuerte',
    '💀': 'me_mori',
    '👀': 'estoy_viendo',
    '💔': 'me_dolio',
    '🤡': 'payasada',
    '🤯': 'mind_blown',
    '🗑️': 'basura',
    '🌟': 'inspirador',
  };

  late final Map<String, String> nombreToEmoji = {
    for (var entry in emojiToNombre.entries) entry.value: entry.key
  };

  final homeService = ApiService();

  final TextEditingController _commentController = TextEditingController();
  int? _postIdEnComentario;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = widget.usuario['id'] as int?;
      if (userId == null) {
        setState(() {
          _errorUsuario = true;
          _loadingUsuario = false;
        });
        return;
      }
      try {
        final data = await homeService.fetchUserData(userId);
        setState(() {
          _usuarioData = data;
          _loadingUsuario = false;
        });
        await _loadCategorias();
        await _loadMorePosts();
      } catch (e) {
        setState(() {
          _errorUsuario = true;
          _loadingUsuario = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _mostrarSoloEmojis(BuildContext context, Function(String) onSelect) {
    final emojis = [
      '🔥',
      '😂',
      '😱',
      '💀',
      '👀',
      '💔',
      '🤡',
      '🤯',
      '🗑️',
      '🌟'
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: emojis.map((emoji) {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onSelect(emoji);
              },
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _loadCategorias() async {
    try {
      final cats = await postService.fetchCategorias();
      setState(() {
        categorias = ['Todos', ...cats];
      });
    } catch (e) {}
  }

  Future<void> _loadMorePosts() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    try {
      final newPosts = await postService.fetchAllPosts(
        page: currentPage,
        category:
            categoriaSeleccionada != 'Todos' ? categoriaSeleccionada : null,
      );

      setState(() {
        _posts.addAll(newPosts);
        currentPage++;
        if (newPosts.isEmpty) {
          hasMore = false;
        }
      });
    } catch (e) {
      print('Error al cargar posts: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onCategoriaChanged(String? newCategoria) {
    setState(() {
      categoriaSeleccionada = newCategoria ?? 'Todos';
      currentPage = 1;
      _posts.clear();
      hasMore = true;
    });
    _loadMorePosts();
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _enviarComentario(Post post) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      await postService.enviarComentario(
        postId: post.id,
        body: text,
        parentId: _comentarioIdRespondiendo,
      );

      _commentController.clear();
      _comentarioIdRespondiendo = null;
      _postIdEnComentario = null;

      await _recargarComentarios(post); // recarga comentarios actualizados
    } catch (e) {
      print('Error al enviar comentario: $e');
    }
  }

  Future<void> _recargarComentarios(Post post) async {
    try {
      final response = await postService.apiService
          .fetchPostById(post.id); // <- necesitas este método
      setState(() {
        post.comentarios = parseComentarios(response['comentarios']);
      });
    } catch (e) {
      print('Error al recargar comentarios: $e');
    }
  }

  // Future<void> _enviarComentario(Post post) async {
  //   final body = _commentController.text.trim();
  //   if (body.isEmpty) return;

  //   try {
  //     await postService.enviarComentario(
  //       postId: post.id,
  //       body: body,
  //       tipo: 'App\\Models\\Post',
  //     );

  //     setState(() {
  //       (post.comentarios ??= []).add(Comment(
  //         id: DateTime.now().millisecondsSinceEpoch,
  //         body: body,
  //         userName: _usuarioData?['nombre'] ?? 'Tú',
  //         userAvatar: _usuarioData?['avatar'] ?? '',
  //         createdAt: DateTime.now().toIso8601String(),
  //         parentId: null,
  //       ));
  //     });

  //     _commentController.clear();
  //     _postIdEnComentario = null;
  //   } catch (e) {
  //     print('Error al enviar comentario: $e');
  //   }
  // }
  Map<int?, List<Comment>> construirMapaSubcomentarios(
      List<Comment> comentarios) {
    Map<int?, List<Comment>> map = {};

    for (var comment in comentarios) {
      final key = comment.parentId; // puede ser null para comentarios padre
      if (map.containsKey(key)) {
        map[key]!.add(comment);
      } else {
        map[key] = [comment];
      }
    }

    return map;
  }
String formatFechaComentario(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  } catch (_) {
    return '';
  }
}
  // --- Función para agrupar subcomentarios ---
  // Map<int, List<Comment>> agruparSubcomentarios(List<Comment> comentarios) {
  //   Map<int, List<Comment>> mapa = {};

  //   for (var comment in comentarios) {
  //     if (comment.parentId != null) {
  //       mapa.putIfAbsent(comment.parentId!, () => []).add(comment);
  //     }
  //   }

  //   return mapa;
  // }

  Widget construirComentariosRecursivo(
      Map<int?, List<Comment>> subcomentariosMap, int postId,
      [int? parentId]) {
    final comentarios = subcomentariosMap[parentId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comentarios.map((comment) {
        return Padding(
          padding: EdgeInsets.only(left: parentId == null ? 0 : 40, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      NetworkImage(getUserAvatarUrl(comment.userAvatar)),
                  backgroundColor: Colors.grey[300],
                ),
                title: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      comment.userName,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black,
      ),
    ),
    if (comment.createdAt != null)
      Text(
        formatFechaComentario(comment.createdAt!),
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
  ],
),
subtitle: Text(
  comment.body,
  style: const TextStyle(
    fontSize: 13,
    color: Colors.black87,
  ),
),
              ),

              // Botón Responder
              Padding(
                padding: const EdgeInsets.only(left: 50, bottom: 4),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _postIdEnComentario = postId;
                      _comentarioIdRespondiendo = comment.id;
                      _commentController.clear();
                    });
                  },
                  child: const Text(
                    'Responder',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ),

              // Campo para escribir la respuesta si se seleccionó este comentario
              if (_postIdEnComentario == postId &&
                  _comentarioIdRespondiendo == comment.id)
                Padding(
                  padding: const EdgeInsets.only(left: 50, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Responder a ${comment.userName}...',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: () async {
                          await _enviarComentario(
                            _posts.firstWhere((p) => p.id == postId),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              // Recursividad para subcomentarios
              construirComentariosRecursivo(
                  subcomentariosMap, postId, comment.id),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showComentariosModal(BuildContext context, Post post) {
    _commentController.clear();
    _postIdEnComentario = post.id;
    _comentarioIdRespondiendo = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // para que el modal sea alto y permita teclado
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Mapa de subcomentarios para el post actual
        final subcomentariosMap = agruparSubcomentarios(post.comentarios ?? []);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          'Comentarios',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Mostrar los comentarios recursivamente
                        if ((post.comentarios ?? []).isNotEmpty)
                          construirComentariosRecursivo(
                              subcomentariosMap, post.id)
                        else
                          const Center(
                              child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No hay comentarios aún.'),
                          )),
                      ],
                    ),
                  ),

                  // Campo para agregar comentario o respuesta
                  if (_postIdEnComentario == post.id)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: _comentarioIdRespondiendo == null
                                    ? 'Escribe un comentario...'
                                    : 'Respondiendo...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: Colors.deepPurple),
                            onPressed: () async {
                              await _enviarComentario(post);
                              // Opcional: cerrar el teclado
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      // Al cerrar el modal, limpiar estado
      setState(() {
        _postIdEnComentario = null;
        _comentarioIdRespondiendo = null;
        _commentController.clear();
      });
    });
  }

  int contarComentariosConSub(List<Comment> comentarios) {
    int total = 0;

    for (var comment in comentarios) {
      total++; // comentario principal
      total += comment.replies.length; // subcomentarios
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUsuario) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorUsuario || _usuarioData == null) {
      return const Scaffold(
        body: Center(child: Text('Error al cargar datos')),
      );
    }

    final usuario = Usuario.fromJson(_usuarioData!);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFC17C9C),
        title: const Text('Bienvenido a tu muro',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_collection,
                size: 30, color: Colors.white),
            onPressed: () {
              final myReel = Reel(
                id: 1,
                nombre: 'video.mp4',
                descripcion: 'Descripción del video',
                createdAt: DateTime.now(),
                userName: 'Usuario',
                userAvatar: 'url_avatar',
                likes: 0,
                commentsCount: 0,
              );

              Navigator.pushNamed(context, '/vistaReels', arguments: myReel);
            },
          )
        ],
      ),
      drawer: CustomDrawer(
        usuario: usuario,
        parentContext: context,
        onLogout: () => _logout(context),
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFC17C9C),
            height: MediaQuery.of(context).size.height * 0.6,
            width: double.infinity,
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 10),
                const SizedBox(height: 190, child: InfluenzometroContainer()),
                const SizedBox(height: 10),
                const SizedBox(height: 190, child: SugerenciasScreen()),
                const SizedBox(height: 10),
                if (categorias.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: categorias.map((cat) {
                        final isSelected = cat == categoriaSeleccionada;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => _onCategoriaChanged(cat),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey[300],
                              foregroundColor:
                                  isSelected ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 10),
                if (isLoading && _posts.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (_posts.isEmpty)
                  const Center(child: Text('No hay posts disponibles'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _posts.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _posts.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final post = _posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.white,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Encabezado del post (usuario, fecha, categoría)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    foregroundImage: NetworkImage(
                                        getUserAvatarUrl(post.userAvatar)),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatDate(
                                              DateTime.parse(post.createdAt)),
                                          style: const TextStyle(
                                            color: Color.fromARGB(255, 1, 1, 1),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        if (post.nameCategoria.isNotEmpty)
                                          Text(
                                            post.nameCategoria,
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 175, 132, 132),
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Contenido del post (texto)
                              PostWidget(content: post.content),

                              // Imagen si existe
                              if (post.imageUrl != null &&
                                  post.imageUrl!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Image.network(
                                    postService.apiService
                                        .getImageUrl(post.imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              const Divider(),

                              // Reacciones y comentarios
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Botón para seleccionar reacción con emojis
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Text(
                                          post.reaccionUsuario != null
                                              ? emojiToNombre.entries
                                                  .firstWhere(
                                                      (e) =>
                                                          e.value ==
                                                          post.reaccionUsuario,
                                                      orElse: () =>
                                                          const MapEntry(
                                                              '😊', ''))
                                                  .key
                                              : '😊',
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        onPressed: () {
                                          _mostrarSoloEmojis(context,
                                              (emoji) async {
                                            final tipo = emojiToNombre[emoji];
                                            if (tipo == null) {
                                              print('❌ Reacción inválida');
                                              return;
                                            }

                                            await postService.enviarReaccion(
                                                post.id.toString(), tipo);
                                            setState(() {
                                              post.reaccionUsuario = tipo;
                                              post.reaccionesTotales ??= {};
                                              post.reaccionesTotales![tipo] =
                                                  (post.reaccionesTotales![
                                                              tipo] ??
                                                          0) +
                                                      1;
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  // Mostrar conteo de reacciones en chips
                                  if (post.reaccionesTotales != null &&
                                      post.reaccionesTotales!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: post
                                            .reaccionesTotales!.entries
                                            .map((entry) {
                                          final emoji =
                                              nombreToEmoji[entry.key] ?? '';
                                          final count_tipo = entry.value;
                                          return Chip(
                                            backgroundColor: Colors.grey[200],
                                            label: Text('$emoji $count_tipo'),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              ),

                              // Mostrar comentarios con subcomentarios anidados
                              const SizedBox(height: 10),
                              TextButton.icon(
                                onPressed: () {
                                  _showComentariosModal(context, post);
                                },
                                icon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.comment,
                                        color: Colors.deepPurple),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${contarComentariosConSub(post.comentarios ?? [])}',
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                label: const Text(
                                  'Ver comentarios',
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                              ),


                              const SizedBox(height: 10),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
