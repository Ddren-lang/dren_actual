import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dren/utils/link_preview_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace')),
      );
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
                          errorWidget: (context, url, error) => Container(height: 200, color: Colors.grey.shade200),
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
          // error o sin data
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
