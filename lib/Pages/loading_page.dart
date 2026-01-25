import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/auth/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadingPage extends ConsumerStatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _dotsController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    _dotsController.repeat();

    // Navigate to home page after loading
    _navigateToHome();
  }

  _navigateToHome() async {

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {

        await Future.delayed(const Duration(milliseconds: 300));


      final user = FirebaseAuth.instance.currentUser;
      print('LoadingPage - About to navigate. Current user: ${user?.email ?? 'No user'}');

      //navigate to AuthPage (which handles login/register logic)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.8, 0.0),
            end: Alignment(0.79, 1.26),
            stops: [
              0.00,
              0.33,
              0.59,
              0.61,
              0.74,
              0.79,
            ],
            colors: [
              Color(0xFF000000), // Black
              Color(0xFF020D24), // Dark blue
              Color(0xFF052147), // Medium blue
              Color(0xFF05244D), // Slightly lighter blue
              Color(0xFF084A85), // Brighter blue
              Color(0xFF084A85), // Brighter blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main FELLO text
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _fadeController,
                    curve: Curves.easeOut,
                  )),
                  child: const Text(
                    'FELLO',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 4.8,
                      // fontFamily: 'System', // Use system font
                    ),
                  ),
                ),
              ),
            ),

            // Loading dots
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLoadingDot(0),
                  const SizedBox(width: 8),
                  _buildLoadingDot(1),
                  const SizedBox(width: 8),
                  _buildLoadingDot(2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        final animationValue = (_dotsController.value - (index * 0.2)) % 1.0;
        final opacity = animationValue < 0.4
            ? (animationValue / 0.4)
            : animationValue < 0.8
            ? 1.0
            : (1.0 - (animationValue - 0.8) / 0.2);

        final scale = animationValue < 0.4
            ? 1.0 + (animationValue / 0.4) * 0.2
            : animationValue < 0.8
            ? 1.2
            : 1.2 - ((animationValue - 0.8) / 0.2) * 0.2;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(opacity * 0.6 + 0.3),
            ),
          ),
        );
      },
    );
  }
}
