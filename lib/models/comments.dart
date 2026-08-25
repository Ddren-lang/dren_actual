class Comment {
  final int id;
  
  final String comment;
  final String userName;
  final String userAvatar;
  final String? createdAt;
  final  int? postId;
final int? parentId;
final List<Comment> replies;
  Comment({
    required this.id,
    
    required this.comment,
    required this.userName,
    required this.userAvatar,
    this.parentId,
    this.createdAt,
    this.postId,
    this.replies = const [],
  });

 factory Comment.fromJson(Map<String, dynamic> json) {
  return Comment(
    id: json['id'],
    comment: json['comment'] ?? json['body'] ?? '',
    userName: json['userName'] ?? 'Anon',
    userAvatar: json['userAvatar'] ?? 'avatar.png',
    createdAt: json['created_at'],
    parentId: (json['parent_id'] == null || json['parent_id'] == 0) 
        ? null 
        : json['parent_id'], // <-- esto es importante
         postId: json['post_id'], 
         replies: json['replies'] != null
        ? (json['replies'] as List)
            .map((reply) => Comment.fromJson(reply))
            .toList()
        : [],
  );
}

}
