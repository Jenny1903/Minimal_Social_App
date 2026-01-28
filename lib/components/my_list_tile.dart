import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/posts_provider.dart';

class MyListTile extends ConsumerWidget {
  final String postId;
  final String title;
  final String subTitle;
  final Timestamp? timestamp;
  final List<dynamic> likes;

  const MyListTile({
    super.key,
    required this.postId,
    required this.title,
    required this.subTitle,
    required this.likes,
    this.timestamp,

  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final postsService = ref.read(postsServiceProvider);

    //check if current user liked this post
    final isLiked = postsService.hasUserLiked(likes);
    final likeCount = likes.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(width: 10),

              //user email and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    if (timestamp != null) ...[
                      const SizedBox(height: 2),

                      Text(
                        _formatTime(timestamp!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              //more options
              Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          //post message
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          const SizedBox(height: 12),

          //action buttons
          Row(
            children: [
              _buildActionButton(context, Icons.favorite_border, "Like"),
              const SizedBox(width: 20),
              _buildActionButton(context, Icons.chat_bubble_outline, "Comment"),
              const SizedBox(width: 20),
              _buildActionButton(context, Icons.share_outlined, "Share"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton(
      BuildContext context,
      WidgetRef ref,
      bool isLiked,
      int likeCount,
      String postId,
      PostsService postsService,
      ) {
    return GestureDetector(
      onTap: () async {
        // Toggle like
        try {
          await postsService.toggleLike(postId);
        } catch (e) {
          // Show error if something goes wrong
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Row(
        children: [
          //heart icon - filled if liked, outline if not
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isLiked
                ? Colors.red  // Red if liked
                : Theme.of(context).colorScheme.secondary,  // Gray if not
          ),
          const SizedBox(width: 4),
          Text(
            likeCount > 0 ? '$likeCount' : 'Like',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}