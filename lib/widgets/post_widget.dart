import 'package:flutter/material.dart';
import '../models/posts.dart';
import '../utils/time_formatter.dart';


class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late bool isLiked;
  late int likesCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    likesCount = widget.post.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.author.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      TimeFormatter.formatTimeAgo(widget.post.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Quote
          if (widget.post.type == PostType.quote) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Colors.blue, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${widget.post.quoteText}"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- ${widget.post.quoteAuthor}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],

          /// Image
          if (widget.post.type == PostType.image) ...[
            Container(
              width: double.infinity,
              height: widget.post.imageUrl == 'coffee_shop' ? 300 : 200,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.post.imageUrl == 'sunset_photo'
                      ? 'Sunset Photo'
                      : 'Coffee Shop Vertical Photo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],

          /// Text Content
          if (widget.post.content.isNotEmpty) ...[
            Text(
              widget.post.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
          ],

          /// Actions
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLiked = !isLiked;
                    likesCount += isLiked ? 1 : -1;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$likesCount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(width: 20),

              Row(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.post.commentsCount}',
                    style:
                    TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              if (widget.post.sharesCount > 0) ...[
                const SizedBox(width: 20),
                Row(
                  children: [
                    Icon(Icons.repeat,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.post.sharesCount}',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}