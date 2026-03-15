import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/components/my_list_tile.dart';
import 'package:social_app/services/saved_posts_service.dart';

class SavedPostsPage extends ConsumerWidget {
  const SavedPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedPostsAsync = ref.watch(savedPostsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Saved Posts'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: savedPostsAsync.when(
        data: (snapshot) {
          final posts = snapshot.docs;

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved posts yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save posts to view them later',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postData = post.data() as Map<String, dynamic>;

              String postId = post.id;
              String message = postData['PostMessage'] ?? '';
              String username = postData['username'] ?? 'Anonymous';
              Timestamp? timestamp = postData['TimeStamp'];
              int likeCount = postData['likeCount'] ?? 0;
              int commentCount = postData['commentCount'] ?? 0;

              List<String>? imageUrls = postData['images'] != null
                  ? List<String>.from(postData['images'])
                  : null;
              String? profilePicture = postData['profilePicture'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MyListTile(
                  postId: postId,
                  title: message,
                  username: username,
                  profilePicture: profilePicture,
                  imageUrls: imageUrls,
                  timestamp: timestamp,
                  likeCount: likeCount,
                  commentCount: commentCount,
                  onCommentTap: () {
                    // TODO: Open comments
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading saved posts',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}