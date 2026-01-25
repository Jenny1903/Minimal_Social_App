import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/auth/login_or_register.dart';
import 'package:social_app/providers/auth_provider.dart';
import '../Pages/home_page.dart';


class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final authState = ref.watch(authStateProvider);


    return authState.when(

      //data We have auth state data
      data: (user) {
        //Debug prints
        print('Auth state: ${user != null ? 'Logged in' : 'Logged out'}');
        print('User: ${user?.email ?? 'No user'}');

        if (user != null) {
          //User is logged in → Show HomePage
          return HomePage();
        } else {
          // User is NOT logged in → Show Login/Register
          return const LoginOrRegister();
        }
      },

      //lOADING - Waiting for auth state
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      //ERROR - Something went wrong
      error: (error, stackTrace) {
        print('Auth error: $error');
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Authentication Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Retry by invalidating the provider
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
