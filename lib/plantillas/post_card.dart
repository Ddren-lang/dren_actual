// import 'package:flutter/material.dart';
// import 'package:iidlive_app/models/post.dart';
// import 'package:iidlive_app/services/home_services.dart';

// class PostCard extends StatelessWidget {
//   final Post post;
//   final TextEditingController commentController;

//   const PostCard({required this.post, required this.commentController, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final apiService = ApiService();
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       color: Colors.white,
//       elevation: 5,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             //... aquí pones la estructura del post con avatar, nombre, fecha, etc
//             Text(post.userName),
//             // contenido
//             Text(post.content),
//             // imagen si hay
//             if (post.imageUrl != null)
//               Image.network(apiService.getImageUrl(post.imageUrl!)),
//             // botones etc
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../utils/link_preview_utils.dart';


class PostWidget extends StatelessWidget {
  final String content;

  const PostWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return buildPostContentWithPreviews(content);
    //return buildPostContent(content);
  }
}