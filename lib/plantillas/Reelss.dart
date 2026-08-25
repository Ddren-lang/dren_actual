import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/reels.dart';
import '../services/reels_services.dart';
import 'package:dren/models/comments.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ReelsScreen extends StatefulWidget {
  @override
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late Future<List<Reel>> _reelsFuture;

  @override
  void initState() {
    super.initState();
    _reelsFuture = _loadUserReels();
  }

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

  Future<List<Reel>> _loadUserReels() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 1;
    return await ReelService().fetchReels(userId);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 165, 144, 200),
        title: const Text('Reels', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.post_add, color: Colors.white),
            tooltip: 'Post',
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo morado en la parte superior 40%
          Container(
            color: const Color(0xFFD04284),
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
          ),

          // FutureBuilder que carga los reels
          FutureBuilder<List<Reel>>(
            future: _reelsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final reels = snapshot.data!;
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: reels.length,
                  itemBuilder: (context, index) {
                    return ReelPlayer(reel: reels[index]);
                  },
                );
              } else {
                return const Center(child: Text('No hay reels disponibles.'));
              }
            },
          ),
        ],
      ),
    );
  }
}

class ReelPlayer extends StatefulWidget {
  final Reel reel;

  const ReelPlayer({Key? key, required this.reel}) : super(key: key);

  @override
  _ReelPlayerState createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer> {
  bool _isLoading = false;
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  // Emoji to nombre mapping for reactions
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

  // Nombre to emoji mapping for displaying reactions
  late final Map<String, String> nombreToEmoji = {
    for (var entry in emojiToNombre.entries) entry.value: entry.key
  };

  // Add this method to make _mostrarSoloEmojis available in this class
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

  @override
  void initState() {
    super.initState();
    String videoUrl = getVideoUrl(widget.reel.nombre);
    // ignore: deprecated_member_use
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
        });
      }).catchError((error) {
        //('Error al cargar el video: $error');
      });
    _controller.setLooping(true);
  }

  void _togglePlayPause() {
    if (!_controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El video no está listo aún.")),
      );
      return;
    }
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  String getVideoUrl(String videoPath) {
    const baseUrl = 'https://iidlive.com/rels/';
    if (videoPath.startsWith('/rels/')) {
      videoPath = videoPath.replaceFirst('/rels/', '');
    } else if (videoPath.startsWith('/')) {
      videoPath = videoPath.substring(1);
    }
    return baseUrl + videoPath;
  }

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

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')} - "
        "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year}";
  }

  void _sendReaction(String tipo) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await ReelService().enviarReaccionReel(widget.reel.id, tipo);

    // Simulamos que el usuario ha reaccionado
    setState(() {
      widget.reel.reaccionUsuario = tipo;

      // Si quieres actualizar también el conteo de reacciones:
      widget.reel.reaccionesTotales ??= {};
      widget.reel.reaccionesTotales![tipo] =
          (widget.reel.reaccionesTotales![tipo] ?? 0) + 1;
    });

    setState(() => _isLoading = false);
  }

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

  int? _replyingToCommentId;

  void _mostrarFormularioRespuesta(int commentId) {
    setState(() {
      _replyingToCommentId = commentId;
    });
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

  Widget _commentForm({int? parentId}) {
    // Puedes personalizar este formulario según tus necesidades
    final TextEditingController _controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Escribe una respuesta...',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () async {
              final texto = _controller.text.trim();
              if (texto.isEmpty) return;

              await ReelService().enviarComentarioReel(
                videoId: widget.reel.id,
                comentario: texto,
                parentId: parentId,
              );

              setState(() {
                _replyingToCommentId = null;
                _controller.clear();
              });

              // Opcional: refrescar UI o comentarios
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentWithReplies(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(getAvatarUrl(comment.userAvatar)),
              ),
              const SizedBox(width: 8),
              Text(comment.userName,
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.comment,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 2),
                Text(
                  formatDate(comment.createdAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    _mostrarFormularioRespuesta(comment.id!);
                  },
                  child: const Text("Responder",
                      style: TextStyle(color: Colors.blueAccent)),
                ),
                if (_replyingToCommentId == comment.id)
                  _commentForm(parentId: comment.id),

                // Recursividad para subcomentarios
                ...comment.replies
                    .map((reply) => _buildCommentWithReplies(reply))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarComentariosModal(BuildContext context) {
    final TextEditingController _comentarioController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.drag_handle, color: Colors.grey),
              ),
              Text(
                'Comentarios (${widget.reel.commentsCount})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: widget.reel.comentarios != null &&
                        widget.reel.comentarios!.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        itemCount: widget.reel.comentarios!.length,
                        itemBuilder: (context, index) {
                          final comentario = widget.reel.comentarios![index];
                          return _buildCommentWithReplies(comentario);
                        },
                      )
                    : const Center(
                        child: Text(
                          'No hay comentarios aún.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comentarioController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      final texto = _comentarioController.text.trim();
                      if (texto.isEmpty) return;

                      await ReelService().enviarComentarioReel(
                        videoId: widget.reel.id,
                        comentario: texto,
                      );

                      _comentarioController.clear();

                      // 🔁 Recargar reels del usuario
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('user_id') ?? 1;

                      final reelsActualizados =
                          await ReelService().fetchReels(userId);

                      final reelActualizado = reelsActualizados
                          .firstWhere((r) => r.id == widget.reel.id);
                      final userAvatar =
                          prefs.getString('user_avatar') ?? 'avatar.png';
                      final userName = prefs.getString('user_name') ?? 'Tú';
                      setState(() {
                        widget.reel.comentarios ??= [];
                        widget.reel.comentarios!.add(Comment(
                          id: DateTime.now().millisecondsSinceEpoch,
                          comment: texto,
                          userName: userName,
                          userAvatar: getAvatarUrl(
                              userAvatar), // opcional: usa el avatar del usuario autenticado si lo tienes
                          createdAt: DateTime.now().toIso8601String(),
                          parentId: null,
                          replies: [],
                        ));
                        widget.reel.commentsCount += 1;
                      });

                      // setState(() {
                      //   widget.reel.comentarios = reelActualizado.comentarios;
                      //   widget.reel.commentsCount =
                      //       reelActualizado.commentsCount;
                      // });

                      Navigator.pop(
                          context); // Cierra el modal después de actualizar
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        children: [
          // Video player fullscreen con aspect ratio
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

          // Botón flotante para reaccionar con emoji
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.emoji_emotions,
                  color: Colors.white, size: 30),
              onPressed: () {
                _mostrarSoloEmojis(context, (emoji) {
                  final tipo = emojiToNombre[emoji]!;
                  _sendReaction(
                      tipo); // Asegúrate de tener esta función implementada
                });
              },
            ),
          ),

          // Descripción y avatar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        NetworkImage(getAvatarUrl(widget.reel.userAvatar)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reel.userName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.reel.descripcion,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatDateTime(widget.reel.createdAt),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 8),

                        // Likes y comentarios
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            // Reacciones personalizadas con emojis
                            if (widget.reel.reaccionesTotales != null &&
                                widget.reel.reaccionesTotales!.isNotEmpty)
                              Wrap(
                                spacing: 10,
                                children: widget.reel.reaccionesTotales!.entries
                                    .map((entry) {
                                  final emoji = nombreToEmoji[entry.key] ?? '';
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(emoji,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                      const SizedBox(width: 2),
                                      Text(entry.value.toString(),
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ],
                                  );
                                }).toList(),
                              )
                            else
                              const Text(
                                'No hay reacciones',
                                style: TextStyle(color: Colors.white),
                              ),

                            const SizedBox(height: 7),

// Botón para mostrar comentarios en modal
                            TextButton.icon(
                              onPressed: () =>
                                  _mostrarComentariosModal(context),
                              icon: const Icon(Icons.comment,
                                  color: Colors.white),
                              label: Text(
                                '${widget.reel.commentsCount} ${widget.reel.commentsCount == 1 ? 'Comentario' : 'Comentarios'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),
                        // Reacción del usuario (opcional)
                        if (widget.reel.reaccionUsuario != null)
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'Tú reaccionaste con ${nombreToEmoji[widget.reel.reaccionUsuario!] ?? ''}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.pause(); // Pausar el video
    _controller.dispose(); // Liberar el controlador
    super.dispose();
  }
}
