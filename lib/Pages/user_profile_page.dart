import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/components/my_list_tile.dart';
import 'package:social_app/services/comments_service.dart';

//fetches any user's data by userId
final userProfileProvider = StreamProvider.family<DocumentSnapshot, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('Users')
      .doc(userId)
      .snapshots();
});

final userPostsProvider = StreamProvider.family<QuerySnapshot, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('Posts')
      .where('userId', isEqualTo: userId)
      .orderBy('TimeStamp', descending: true)
      .snapshots();
});

//provider for user stats
final userStatsProvider = StreamProvider.family<Map<String, int>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('Posts')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .asyncMap((postsSnapshot) async {
    int totalPosts = postsSnapshot.docs.length;
    int totalComments = 0;
    int totalLikes = 0;

    //count comments and likes across all user's posts
    for (var post in postsSnapshot.docs) {
      final postData = post.data() as Map<String, dynamic>;
      totalLikes += (postData['likeCount'] ?? 0) as int;

      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(post.id)
          .collection('Comments')
          .get();
      totalComments += commentsSnapshot.docs.length;
    }

    //get followers and following counts
    final userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    final data = userData.data() as Map<String, dynamic>?;
    int followers = (data?['followers'] as List?)?.length ?? 0;
    int following = (data?['following'] as List?)?.length ?? 0;

    return {
      'posts': totalPosts,
      'comments': totalComments,
      'likes': totalLikes,
      'followers': followers,
      'following': following,
    };
  });
});

//provider to check if current user follows this profile
final isFollowingProvider = StreamProvider.family<bool, String>((ref, userId) {
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return false;
    final data = snapshot.data() as Map<String, dynamic>?;
    final following = data?['following'] as List? ?? [];
    return following.contains(userId);
  });
});

class UserProfilePage extends ConsumerWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  Future<void> _toggleFollow(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    final isFollowing = await ref.read(isFollowingProvider(userId).future);

    try {
      final currentUserRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid);
      final targetUserRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userId);

      if (isFollowing) {
        // Unfollow
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([userId])
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayRemove([currentUser.uid])
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unfollowed')),
          );
        }
      } else {
        //follow
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([userId])
        });
        await targetUserRef.update({
          'followers': FieldValue.arrayUnion([currentUser.uid])
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Following!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showCommentsBottomSheet(
      BuildContext context,
      WidgetRef ref,
      String postId,
      String postMessage,
      String username,
      ) async {
    final TextEditingController commentController = TextEditingController();
    final commentsService = ref.read(commentsServiceProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              //handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              //post preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          child: Text(
                            username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '@$username',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                    if (postMessage.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        postMessage,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              //comments header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, child) {
                        final commentsAsync = ref.watch(commentsStreamProvider(postId));
                        return commentsAsync.when(
                          data: (snapshot) => Text(
                            '${snapshot.docs.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              //comments list
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final commentsAsync = ref.watch(commentsStreamProvider(postId));

                    return commentsAsync.when(
                      data: (snapshot) {
                        if (snapshot.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to comment!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: snapshot.docs.length,
                          itemBuilder: (context, index) {
                            final comment = snapshot.docs[index];
                            final commentData = comment.data() as Map<String, dynamic>;
                            final currentUser = ref.watch(authStateProvider).value;
                            final isOwnComment = currentUser?.uid == commentData['userId'];

                            return _buildCommentItem(
                              context,
                              ref,
                              commentData,
                              comment.id,
                              postId,
                              isOwnComment,
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(
                        child: Text(
                          'Error loading comments',
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    );
                  },
                ),
              ),

              //comment input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        if (commentController.text.trim().isEmpty) return;

                        try {
                          await commentsService.addComment(
                            postId,
                            commentController.text.trim(),
                          );
                          commentController.clear();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(
      BuildContext context,
      WidgetRef ref,
      Map<String, dynamic> commentData,
      String commentId,
      String postId,
      bool isOwnComment,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Text(
                  (commentData['username'] ?? 'A')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${commentData['username'] ?? 'Anonymous'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Text(
                      _formatTimestamp(commentData['timestamp']),
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwnComment)
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red[400],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red[400]),
                          ),
                        ],
                      ),
                      onTap: () async {
                        try {
                          final commentsService = ref.read(commentsServiceProvider);
                          await commentsService.deleteComment(postId, commentId);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment deleted')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            commentData['text'] ?? '',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    final DateTime dateTime = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.parse(timestamp.toString());

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider(userId));
    final userPosts = ref.watch(userPostsProvider(userId));
    final userStats = ref.watch(userStatsProvider(userId));
    final currentUser = ref.watch(authStateProvider).value;
    final isFollowing = ref.watch(isFollowingProvider(userId));

    final isOwnProfile = currentUser?.uid == userId;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to settings
              },
            ),
        ],
      ),
      body: userProfile.when(
        data: (snapshot) {
          if (!snapshot.exists) {
            return const Center(child: Text('User not found'));
          }

          final userData = snapshot.data() as Map<String, dynamic>;
          final username = userData['username'] ?? 'Anonymous';
          final bio = userData['bio'] ?? '';
          final email = userData['email'] ?? '';
          final profilePicture = userData['profilePicture'];

          return CustomScrollView(
            slivers: [
              //profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(
                  context,
                  ref,
                  username,
                  bio,
                  email,
                  profilePicture,
                  isOwnProfile,
                  userStats,
                  isFollowing,
                ),
              ),

              //posts Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      const Spacer(),
                      userStats.when(
                        data: (stats) => Text(
                          '${stats['posts']} ${stats['posts'] == 1 ? 'post' : 'posts'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              //user's Posts
              userPosts.when(
                data: (postsSnapshot) {
                  final posts = postsSnapshot.docs;

                  if (posts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.post_add,
                              size: 60,
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isOwnProfile ? 'No posts yet' : 'No posts',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            if (isOwnProfile) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Share your first post!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = posts[index];
                        final postData = post.data() as Map<String, dynamic>;

                        //extract all post data
                        String message = postData['PostMessage'] ?? '';
                        Timestamp? timestamp = postData['TimeStamp'];
                        int likeCount = postData['likeCount'] ?? 0;
                        int commentCount = postData['commentCount'] ?? 0;
                        List<String>? imageUrls = postData['images'] != null
                            ? List<String>.from(postData['images'])
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                          child: GestureDetector(
                            onTap: () => _showCommentsBottomSheet(
                              context,
                              ref,
                              post.id,
                              message,
                              username,
                            ),
                            child: MyListTile(
                              postId: post.id,
                              title: message,
                              username: username,
                              profilePicture: profilePicture,
                              imageUrls: imageUrls,
                              timestamp: timestamp,
                              likeCount: likeCount,
                              commentCount: commentCount,
                            ),
                          ),
                        );
                      },
                      childCount: posts.length,
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context,
      WidgetRef ref,
      String username,
      String bio,
      String email,
      String? profilePicture,
      bool isOwnProfile,
      AsyncValue<Map<String, int>> userStats,
      AsyncValue<bool> isFollowing,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          //profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: profilePicture == null
                  ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                ],
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: profilePicture != null
                ? ClipOval(
              child: Image.network(
                profilePicture,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
                : Center(
              child: Text(
                username[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          //username
          Text(
            '@$username',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          const SizedBox(height: 8),

          //email
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),

          if (bio.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              bio,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ],

          const SizedBox(height: 20),

          //stats row
          userStats.when(
            data: (stats) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(context, stats['posts'].toString(), 'Posts'),
                _buildStatItem(context, stats['likes'].toString(), 'Likes'),
                _buildStatItem(context, stats['followers'].toString(), 'Followers'),
                _buildStatItem(context, stats['following'].toString(), 'Following'),
              ],
            ),
            loading: () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(context, '...', 'Posts'),
                _buildStatItem(context, '...', 'Likes'),
                _buildStatItem(context, '...', 'Followers'),
                _buildStatItem(context, '...', 'Following'),
              ],
            ),
            error: (_, __) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(context, '0', 'Posts'),
                _buildStatItem(context, '0', 'Likes'),
                _buildStatItem(context, '0', 'Followers'),
                _buildStatItem(context, '0', 'Following'),
              ],
            ),
          ),

          if (!isOwnProfile) ...[
            const SizedBox(height: 20),

            //follow button
            isFollowing.when(
              data: (following) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _toggleFollow(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: following
                        ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                        : Theme.of(context).colorScheme.secondary,
                    foregroundColor: following
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: following
                          ? BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      )
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(following ? 'Following' : 'Follow'),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}