import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//migration service

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //migrating posts to new structure
  //Adds username field to existing posts
  Future<void> migratePostsToNewStructure() async {
    try {
      print(' Starting posts migration...');

      //Get all posts
      final postsSnapshot = await _firestore.collection('Posts').get();

      int updated = 0;
      int skipped = 0;
      int errors = 0;

      for (var postDoc in postsSnapshot.docs) {
        try {
          final postData = postDoc.data();

          //Check if already migrated
          if (postData.containsKey('username') && postData.containsKey('likeCount')) {
            skipped++;
            continue;
          }

          //Get username from user email
          String? userEmail = postData['UserEmail'];
          String username = 'Anonymous';

          if (userEmail != null) {
            //Try to find user document by email (old structure)
            final userQuery = await _firestore
                .collection('Users')
                .where('email', isEqualTo: userEmail)
                .limit(1)
                .get();

            if (userQuery.docs.isNotEmpty) {
              username = userQuery.docs.first.data()['username'] ?? 'Anonymous';
            }
          }

          //Update post with new fields
          await postDoc.reference.update({
            'username': username,
            'likeCount': 0,
            'userId': '', // Empty for now, can't determine old UIDs
          });

          updated++;
          print('Updated post: ${postDoc.id}');
        } catch (e) {
          errors++;
          print('Error updating post ${postDoc.id}: $e');
        }
      }

      print('Migration complete!');
      print('   Updated: $updated');
      print('   Skipped: $skipped');
      print('   Errors: $errors');
    } catch (e) {
      print(' Migration failed: $e');
      rethrow;
    }
  }

  //migrating user to Uid based structure
  // Changes Users collection to use UID as document ID
  Future<void> migrateUsersToUidStructure() async {
    try {
      print('Starting users migration...');

      final usersSnapshot = await _firestore.collection('Users').get();
      final currentUser = _auth.currentUser;

      int updated = 0;
      int skipped = 0;

      for (var userDoc in usersSnapshot.docs) {
        try {
          final userData = userDoc.data();
          final email = userData['email'];

          //Skip if already using UID structure
          if (userData.containsKey('uid')) {
            skipped++;
            continue;
          }

          //For current logged-in user, we can migrate
          if (currentUser != null && currentUser.email == email) {
            //Create new document with UID
            await _firestore.collection('Users').doc(currentUser.uid).set({
              'uid': currentUser.uid,
              'email': email,
              'username': userData['username'] ?? 'user',
              'bio': userData['bio'] ?? '',
              'createdAt': userData['createdAt'] ?? FieldValue.serverTimestamp(),
            });

            //Delete old email-based document
            await userDoc.reference.delete();

            updated++;
            print('Migrated user: $email');
          } else {
            print('Skipping user (not current user): $email');
            skipped++;
          }
        } catch (e) {
          print('Error migrating user ${userDoc.id}: $e');
        }
      }

      print('User migration complete!');
      print('   Updated: $updated');
      print('   Skipped: $skipped');
    } catch (e) {
      print('User migration failed: $e');
      rethrow;
    }
  }

  //migrating likes to subcollection
  //Converts array-based likes to subcollection structure
  Future<void> migrateLikesToSubcollections() async {
    try {
      print(' Starting likes migration...');

      final postsSnapshot = await _firestore.collection('Posts').get();

      int updated = 0;
      int skipped = 0;

      for (var postDoc in postsSnapshot.docs) {
        try {
          final postData = postDoc.data();

          //Check if has old Likes array
          if (!postData.containsKey('Likes')) {
            skipped++;
            continue;
          }

          List<dynamic> likes = postData['Likes'] ?? [];

          if (likes.isEmpty) {
            skipped++;
            continue;
          }

          //Migrate each like to subcollection
          for (String userEmail in likes) {
            // Find user by email
            final userQuery = await _firestore
                .collection('Users')
                .where('email', isEqualTo: userEmail)
                .limit(1)
                .get();

            if (userQuery.docs.isNotEmpty) {
              final userData = userQuery.docs.first.data();
              final userId = userData['uid'] ?? userQuery.docs.first.id;
              final username = userData['username'] ?? 'Anonymous';

              //Create like document in subcollection
              await postDoc.reference.collection('Likes').doc(userId).set({
                'userId': userId,
                'userEmail': userEmail,
                'username': username,
                'timestamp': FieldValue.serverTimestamp(),
              });
            }
          }

          //Update likeCount and remove old Likes array
          await postDoc.reference.update({
            'likeCount': likes.length,
            'Likes': FieldValue.delete(), // Remove old array
          });

          updated++;
          print('Migrated likes for post: ${postDoc.id}');
        } catch (e) {
          print('Error migrating likes for ${postDoc.id}: $e');
        }
      }

      print('Likes migration complete!');
      print('   Updated: $updated');
      print('   Skipped: $skipped');
    } catch (e) {
      print('Likes migration failed: $e');
      rethrow;
    }
  }

  //running all migration
  //Production pattern: Run all migrations in sequence
  Future<void> runAllMigrations() async {
    try {
      print('Starting full database migration...\n');

      await migrateUsersToUidStructure();
      print('\n');

      await migratePostsToNewStructure();
      print('\n');

      await migrateLikesToSubcollections();
      print('\n');

      print('All migrations completed successfully!');
    } catch (e) {
      print('Migration failed: $e');
      rethrow;
    }
  }
}
