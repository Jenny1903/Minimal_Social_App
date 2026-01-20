import 'user.dart';

enum PostType { text, image, quote }

class Post {
  final String id;
  final User author;
  final String content;
  final PostType type;
  final String? imageUrl;
  final String? quoteText;
  final String? quoteAuthor;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;

  Post({

    required this.id,
    required this.author,
    required this.content,
    required this.type,
    this.imageUrl,
    this.quoteText,
    this.quoteAuthor,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    this.sharesCount = 0,
    this.isLiked = false,
});
}