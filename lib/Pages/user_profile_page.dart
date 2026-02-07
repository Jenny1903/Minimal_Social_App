import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/components/my_list_tile.dart';


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


//production-ready profile with stats


class UserProfilePage extends ConsumerWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider(userId));
    final userPosts = ref.watch(userPostsProvider(userId));
    final currentUser = ref.watch(authStateProvider).value;

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
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit profile
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

          return CustomScrollView(
            slivers: [
              //profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(
                  context,
                  username,
                  bio,
                  email,
                  isOwnProfile,
                ),
              ),

              //posts Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Posts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
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
                        child: Text(
                          isOwnProfile ? 'No posts yet' : 'No posts',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = posts[index];
                        final postData = post.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MyListTile(
                            postId: post.id,
                            title: postData['PostMessage'] ?? '',
                            username: username,
                            timestamp: postData['TimeStamp'],
                            likeCount: postData['likeCount'] ?? 0,
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
      String username,
      String bio,
      String email,
      bool isOwnProfile,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
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

          //stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(context, '0', 'Posts'),
              _buildStatItem(context, '0', 'Followers'),
              _buildStatItem(context, '0', 'Following'),
            ],
          ),

          if (!isOwnProfile) ...[
            const SizedBox(height: 20),

            //follow Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement follow/unfollow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Follow'),
              ),
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