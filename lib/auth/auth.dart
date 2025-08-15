import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/auth/login_or_register.dart';

import '../Pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){

            // Show loading while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Add debug print to see what's happening
            print('Auth state: ${snapshot.hasData ? 'Logged in' : 'Logged out'}');
            print('User: ${snapshot.data?.email ?? 'No user'}');

            //user is logged in
            if (snapshot.hasData){
              return HomePage();
            }
            //user is NOT logged in
            else{
              return const LoginOrRegister();
         }
        },
    ),
    );
  }
}
