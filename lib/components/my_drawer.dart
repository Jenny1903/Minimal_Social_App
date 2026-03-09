import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/providers/auth_provider.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final userDataAsync = ref.watch(currentUserDataProvider);

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          //header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.primary,
                    size: 50,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'F E L L O',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  userDataAsync.when(
                    data: (snapshot) {
                      if (snapshot != null && snapshot.exists) {
                        final userData = snapshot.data() as Map<String, dynamic>?;
                        final username = userData?['username'] ?? 'User';
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '@$username',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          //home
          ListTile(
            leading: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: Text(
              'H O M E',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home_page');
            },
          ),

          //profile
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: Text(
              'P R O F I L E',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile_page');
            },
          ),

          //search users
          ListTile(
            leading: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: Text(
              'S E A R C H',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/search');
            },
          ),

          //users
          ListTile(
            leading: Icon(
              Icons.group,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: Text(
              'U S E R S',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/user_page');
            },
          ),

          const Spacer(),

          //settings
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: Text(
              'S E T T I N G S',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),

          //logout
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            title: Text(
              'L O G O U T',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              // Sign out using Firebase Auth directly
              await FirebaseAuth.instance.signOut();
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}