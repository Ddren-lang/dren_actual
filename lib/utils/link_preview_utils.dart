

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:metadata_fetch/metadata_fetch.dart' as metadata_fetch;

class Metadata {
  final String? image;
  final String? title;
  final String? description;
  Metadata({this.image, this.title, this.description});
}

class LinkUtils {
 static Future<Metadata?> fetchMetadata(String url) async {
  try {
    // Agregamos un Timeout para que no se quede cargando infinito
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      final data = await metadata_fetch.MetadataFetch.extract(response.body);
      if (data != null) {
        return Metadata(
          title: data.title,
          description: data.description,
          image: data.image,
        );
      }
    }
  } catch (e) {
    print('Error al obtener metadata: $e');
  }
  return null; // IMPORTANTE: Retornar null para que el widget sepa que falló la preview
}


  static String extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return "";
    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : "";
    }
    if (uri.host.contains("youtube.com")) {
      return uri.queryParameters["v"] ?? "";
    }
    return "";
  }

  static bool isTikTokUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host.contains("tiktok.com");
  }

  static void openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class LinkPreviewWidget extends StatefulWidget {
  final String url;
  final bool fallbackWebView;

  const LinkPreviewWidget({Key? key, required this.url, this.fallbackWebView = false}) : super(key: key);

  @override
  _LinkPreviewWidgetState createState() => _LinkPreviewWidgetState();
}

class _LinkPreviewWidgetState extends State<LinkPreviewWidget> {
  late Future<Metadata?> _metadataFuture;

  @override
  void initState() {
    super.initState();
    _metadataFuture = LinkUtils.fetchMetadata(widget.url);
  }

  void _openUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Metadata?>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          if ((data.image != null || data.title != null)) {
            return GestureDetector(
              onTap: _openUrl,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.image != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                        child: CachedNetworkImage(
                          imageUrl: data.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data.title ?? widget.url,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                    ),
                    if (data.description != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          data.description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.url,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (widget.fallbackWebView) {
            return SizedBox(
              height: 400,
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              ),
            );
          } else {
            return GestureDetector(
              onTap: _openUrl,
              child: Text(
                widget.url,
                style: const TextStyle(color: Colors.blue),
              ),
            );
          }
        } else {
          return GestureDetector(
            onTap: _openUrl,
            child: Text(
              widget.url,
              style: const TextStyle(color: Colors.blue),
            ),
          );
        }
      },
    );
  }
}

class YoutubePlayerWidget extends StatefulWidget {
  final String videoId;

  const YoutubePlayerWidget({Key? key, required this.videoId}) : super(key: key);

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
    );
  }
}

// Este widget detecta y muestra el contenido embebido adecuado
Widget buildEmbeddedContent(String url) {
  final youtubeId = LinkUtils.extractYouTubeId(url);

  if (youtubeId.isNotEmpty) {
    return YoutubePlayerWidget(videoId: youtubeId);
  } else if (LinkUtils.isTikTokUrl(url)) {
    return SizedBox(
      height: 300,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  } else {
    return LinkPreviewWidget(url: url);
  }
}

// Función para construir el contenido del post con links y previews embebidos
Widget buildPostContentWithPreviews(String content) {
  final linkRegex = RegExp(r'https?:\/\/[^\s]+');
  final matches = linkRegex.allMatches(content);

  if (matches.isEmpty) return Text(content);

  List<Widget> widgets = [];
  int lastEnd = 0;

  for (final match in matches) {
    final link = content.substring(match.start, match.end);

    if (match.start > lastEnd) {
      widgets.add(Text(content.substring(lastEnd, match.start)));
    }

    // Texto clickeable del link
    widgets.add(
      GestureDetector(
        onTap: () => LinkUtils.openUrl(link),
        child: Text(link, style: const TextStyle(color: Colors.blue)),
      ),
    );

    // Vista previa o video embebido debajo
    widgets.add(buildEmbeddedContent(link));

    lastEnd = match.end;
  }

  if (lastEnd < content.length) {
    widgets.add(Text(content.substring(lastEnd)));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}
