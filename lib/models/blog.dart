class Blog {
  final String id;
  final String userId;
  String content;
  int likes;
  int dislikes;
  bool isCommentsEnabled;
  List<String> comments;
  DateTime timestamp;
  bool isBookmarked;

  Blog({
    required this.id,
    required this.userId,
    required this.content,
    required this.likes,
    required this.dislikes,
    required this.isCommentsEnabled,
    required this.comments,
    required this.timestamp,
    this.isBookmarked = false,
  });
}
