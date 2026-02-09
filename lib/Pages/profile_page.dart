import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/components/my_back_button.dart';
import 'package:social_app/providers/auth_provider.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Get current user
    final currentUser = FirebaseAuth.instance.currentUser;

    //Watch user data from provider
    final userDataState = ref.watch(currentUserDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: userDataState.when(
        data: (snapshot) {
          //Check if user data exists
          if (snapshot == null || !snapshot.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('User data not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          //Get user data
          final userData = snapshot.data() as Map<String, dynamic>?;

          if (userData == null) {
            return const Center(child: Text('No user data'));
          }

          final username = userData['username'] ?? 'Anonymous';
          final email = userData['email'] ?? currentUser?.email ?? '';
          final bio = userData['bio'] ?? '';

          return Center(
            child: Column(
              children: [
                //Back button
                const Padding(
                  padding: EdgeInsets.only(
                    top: 50.0,
                    left: 25,
                  ),
                  child: Row(
                    children: [
                      MyBackButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //Profile picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //Username
                Text(
                  '@$username',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                //Email
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),

                // Bio (if exists)
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}