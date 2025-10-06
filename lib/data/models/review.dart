class Review {
  final String author;          
  final String authorName;       
  final String authorUsername;  
  final String? authorAvatarPath;
  final double? rating;    
  final String content;
  final String createdAt;
  final String updatedAt;
  final String url;
  final String reviewID;

  Review({
    required this.author,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatarPath,
    required this.rating,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
    required this.reviewID,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] ?? {};
    String? avatar = authorDetails['avatar_path'];
    if (avatar != null && avatar.startsWith('/')) {
      avatar = 'https://image.tmdb.org/t/p/w45$avatar';
    }

    return Review(
      author: json['author'] ?? '',
      authorName: authorDetails['name'] ?? '',
      authorUsername: authorDetails['username'] ?? '',
      authorAvatarPath: avatar,
      rating: (authorDetails['rating'] as num?)?.toDouble(),
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      url: json['url'] ?? '',
      reviewID: json['id'] ?? '',
    );
  }
}
