import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/Pages/home_page.dart';
import 'package:social_app/Pages/profile_page.dart';
import 'package:social_app/Pages/users_page.dart';
import 'package:social_app/auth/auth.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/light_mode.dart';
import 'package:social_app/firebase_options.dart';
import 'package:social_app/auth/login_or_register.dart';
import 'package:social_app/Pages/loading_page.dart';
import 'package:social_app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final user = FirebaseAuth.instance.currentUser;
  print('App starting - Current user: ${user?.email ?? 'No user'}');

    //test Firebase Storage
    try {
      final storage = FirebaseStorage.instance;
      print('Firebase Storage initialized');
      print(' Bucket: ${storage.bucket}');
    } catch (e) {
      print('Firebase Storage error: $e');
    }

    runApp(const ProviderScope(child: MyApp()));
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const LoadingPage(),

      theme: lightMode,
      darkTheme: darkMode,

      routes: {
        '/loading': (context) => const LoadingPage(),
        '/auth': (context) => const AuthPage(),
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/user_page': (context) => const UsersPage(),
      },
    );
  }
}


