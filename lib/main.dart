import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/Pages/home_page.dart';
import 'package:social_app/Pages/profile_page.dart';
import 'package:social_app/Pages/users_page.dart';
import 'package:social_app/Pages/edit_profile_page.dart';
import 'package:social_app/Pages/settings_page.dart';
import 'package:social_app/Pages/search_user_page.dart';
import 'package:social_app/auth/auth.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/light_mode.dart';
import 'package:social_app/firebase_options.dart';
import 'package:social_app/auth/login_or_register.dart';
import 'package:social_app/Pages/loading_page.dart';
import 'package:social_app/routes/app_routes.dart';
import 'package:social_app/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final user = FirebaseAuth.instance.currentUser;
  print('App starting - Current user: ${user?.email ?? 'No user'}');

  // Test Firebase Storage
  try {
    final storage = FirebaseStorage.instance;
    print('Firebase Storage initialized');
    print('Bucket: ${storage.bucket}');
  } catch (e) {
    print('Firebase Storage error: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch theme mode
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,

      initialRoute: '/loading',

      routes: {
        '/loading': (context) => const LoadingPage(),
        '/auth': (context) => const AuthPage(),
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/user_page': (context) => const UsersPage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/search': (context) => const SearchUsersPage(),
      },

      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}