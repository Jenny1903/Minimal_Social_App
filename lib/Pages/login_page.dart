import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/components/my_button.dart';
import 'package:social_app/components/my_textfield.dart';
import 'package:social_app/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, this.onTap});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

//notice: ConsumerState instead of State
class _LoginPageState extends ConsumerState<LoginPage> {
  //text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //loading state
  bool isLoading = false;

  //toggle between login and register
  bool showLoginPage = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    //validate inputs
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    try {

      final authService = ref.read(authServiceProvider);

      await authService.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );



    } catch (e) {
      //show error to user
      showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> register() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      await authService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

    } catch (e) {
      showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
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
                  Text(
                    'F E L L O',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),

                  const SizedBox(height: 50),

                  //email textfield
                  MyTextfield(
                    hintText: 'Email',
                    obscureText: false,
                    controller: emailController,
                  ),

                  const SizedBox(height: 10),

                  //password textfield
                  MyTextfield(
                    hintText: 'Password',
                    obscureText: true,
                    controller: passwordController,
                  ),

                  const SizedBox(height: 10),

                  //forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  //login/Register button
                  isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(
                    text: showLoginPage ? 'Login' : 'Register',
                    onTap: showLoginPage ? login : register,
                  ),

                  const SizedBox(height: 25),

                  //toggle to register/login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showLoginPage
                            ? "Don't have an account? "
                            : "Already have an account? ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      GestureDetector(

                        onTap: widget.onTap,
                        child: Text(
                          showLoginPage ? 'Register here' : 'Login here',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.inversePrimary,
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