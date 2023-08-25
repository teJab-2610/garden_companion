class PostImage {
  final String title;
  final String imageUrl;

  PostImage({
    required this.title,
    required this.imageUrl,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      title: json['title'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'imageUrl': imageUrl,
    };
  }
}
