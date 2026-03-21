import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/Pages/user_profile_page.dart';

//shows all users who follow this user
class FollowersPage extends ConsumerWidget {
  final String userId;
  final String username;

  const FollowersPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text('$username\'s Followers'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        //listen to the user document to get followers list
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          //get the followers array from the user document
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final followerIds = List<String>.from(userData['followers'] ?? []);

          print('Found ${followerIds.length} followers for $username');

          if (followerIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No followers yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          //fetch full user data for each follower
          //this is a FutureBuilder because we need to fetch multiple users
          return FutureBuilder<List<DocumentSnapshot>>(
            future: _fetchUsersByIds(followerIds),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!usersSnapshot.hasData || usersSnapshot.data!.isEmpty) {
                return const Center(child: Text('No followers found'));
              }

              final users = usersSnapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userData = user.data() as Map<String, dynamic>;

                  final username = userData['username'] ?? 'Anonymous';
                  final bio = userData['bio'] ?? '';
                  final profilePicture = userData['profilePicture'];

                  return _buildUserTile(
                    context,
                    userId: user.id,
                    username: username,
                    bio: bio,
                    profilePicture: profilePicture,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Fetch multiple users by their IDs

  //takes: List of user IDs
  //returns: List of user documents
  Future<List<DocumentSnapshot>> _fetchUsersByIds(List<String> userIds) async {
    print('Fetching ${userIds.length} users...');


    //need to batch the requests if there are more than 10
    final List<DocumentSnapshot> users = [];

    //split into batches of 10
    for (int i = 0; i < userIds.length; i += 10) {
      final batch = userIds.skip(i).take(10).toList();

      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      users.addAll(snapshot.docs);
    }

    print('Fetched ${users.length} users');
    return users;
  }

  //build a user tile widget
  //this is the item shown for each user in the list
  Widget _buildUserTile(
      BuildContext context, {
        required String userId,
        required String username,
        required String bio,
        String? profilePicture,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        //when tapped, navigate to their profile
        onTap: () {
          print('Tapped on user: $username');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(userId: userId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              //profile picture
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                backgroundImage: profilePicture != null
                    ? NetworkImage(profilePicture)
                    : null,
                child: profilePicture == null
                    ? Text(
                  username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),

              const SizedBox(width: 12),

              //user info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$username',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bio,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              //arrow icon
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
