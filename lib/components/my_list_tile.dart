import 'package:social_app/components/who_liked_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/posts_provider.dart';
import 'package:social_app/services/image_service.dart';

import 'comments_sheet.dart';


class MyListTile extends ConsumerWidget {
  final String postId;
  final String title;
  final String username;
  final Timestamp? timestamp;
  final String? profilePicture;
  final List<String>? imageUrls;
  final int likeCount;
  final int commentCount;

  const MyListTile({
    super.key,
    required this.postId,
    required this.title,
    required this.username,
    this.profilePicture,
    this.imageUrls,
    required this.likeCount,
    required this.commentCount,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsService = ref.read(postsServiceProvider);

    // Watch if current user liked this post
    final hasLiked = ref.watch(hasUserLikedProvider(postId));

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
              // Avatar with profile picture
              profilePicture != null && profilePicture!.isNotEmpty
                  ? ClipOval(
                child: CachedImage(
                  imageUrl: profilePicture,
                  width: 36,
                  height: 36,
                ),
              )
                  : CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  username[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Username and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
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

              // More options
              Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Post message
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          // Post images (if any)
          if (imageUrls != null && imageUrls!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPostImages(context),
          ],

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              _buildLikeButton(context, ref, hasLiked, postsService),
              const SizedBox(width: 20),
              _buildCommentButton(context),
              const SizedBox(width: 20),
              _buildActionButton(context, Icons.share_outlined, "Share"),
            ],
          ),
        ],
      ),
    );
  }

  //comment button
  Widget _buildCommentButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => CommentsSheet(postId: postId),
        );
      },
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            commentCount > 0 ? '$commentCount' : 'Comment',
            style: TextStyle(
              fontSize: 13,
              color: commentCount > 0
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).colorScheme.secondary,
              fontWeight: commentCount > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

//like button
  Widget _buildLikeButton(
      BuildContext context,
      WidgetRef ref,
      AsyncValue<bool> hasLiked,
      PostsService postsService,
      ) {
    final isLiked = hasLiked.value ?? false;

    return Row(
      children: [
        // Heart icon
        GestureDetector(
          onTap: () async {
            try {
              await postsService.toggleLike(postId);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isLiked ? Colors.red : Theme.of(context).colorScheme.secondary,
          ),
        ),

        const SizedBox(width: 4),

        //Like count ~ tappable to see who liked
        GestureDetector(
          onTap: () {
            if (likeCount > 0) {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => WhoLikedSheet(postId: postId),
              );
            }
          },
          child: Text(
            likeCount > 0 ? '$likeCount' : 'Like',
            style: TextStyle(
              fontSize: 13,
              color: likeCount > 0
                  ? Theme.of(context).colorScheme.inversePrimary
                  : Theme.of(context).colorScheme.secondary,
              fontWeight: likeCount > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
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

//build post images
  Widget _buildPostImages(BuildContext context) {
    if (imageUrls == null || imageUrls!.isEmpty) return const SizedBox();

    // Single image
    if (imageUrls!.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedImage(
          imageUrl: imageUrls![0],
          width: double.infinity,
          height: 300,
        ),
      );
    }

    //Multiple images [ Grid layout  ]
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: imageUrls!.length == 2 ? 2 : 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: imageUrls!.length.clamp(0, 4),
        itemBuilder: (context, index) {
          return CachedImage(
            imageUrl: imageUrls![index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}