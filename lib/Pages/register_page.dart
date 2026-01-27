import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/components/my_button.dart';
import 'package:social_app/components/my_textfield.dart';
import 'package:social_app/providers/auth_provider.dart';


class RegisterPage extends ConsumerStatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  //Text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  //Loading state
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    // Validate inputs
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showError("Please fill all fields");
      return;
    }

    //Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      showError("Passwords don't match");
      return;
    }

    setState(() => isLoading = true);

    try {
      //Get AuthService from Riverpod
      final authService = ref.read(authServiceProvider);

      // Create the user with Firebase Auth
      await authService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      //Get current user from Riverpod
      final currentUser = ref.read(authServiceProvider).currentUser;

      //Create user document in Firestore
      if (currentUser != null) {
        await createUserDocument(currentUser.email, usernameController.text);
      }

      //Success! authStateProvider will automatically update
      //and navigate to HomePage

    } catch (e) {
      showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }


  // CREATE USER DOCUMENT IN FIRESTORE

  Future<void> createUserDocument(String? email, String username) async {
    if (email != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(email)
          .set({
        'email': email,
        'username': username,
        'bio': '',  // Empty bio by default
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //logo
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),

                  const SizedBox(height: 25),

                  //app name
                  const Text(
                    "F E L L O",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 50),

                  //username textfield
                  MyTextfield(
                    hintText: "Username",
                    obscureText: false,
                    controller: usernameController,
                  ),

                  const SizedBox(height: 10),

                  //email textfield
                  MyTextfield(
                    hintText: "Email",
                    obscureText: false,
                    controller: emailController,
                  ),

                  const SizedBox(height: 10),

                  //password textfield
                  MyTextfield(
                    hintText: "Password",
                    obscureText: true,
                    controller: passwordController,
                  ),

                  const SizedBox(height: 10),

                  //confirm password textfield
                  MyTextfield(
                    hintText: "Confirm Password",
                    obscureText: true,
                    controller: confirmPasswordController,
                  ),

                  const SizedBox(height: 25),

                  //register button
                  isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(
                    text: "Register",
                    onTap: registerUser,
                  ),

                  const SizedBox(height: 25),

                  //toggle to login page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login Here",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
