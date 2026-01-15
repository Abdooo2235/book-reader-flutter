import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/screens/auth/login_screen.dart';
import 'package:book_reader_app/screens/auth/onboarding_screen.dart';
import 'package:book_reader_app/screens/main/tabs_screen.dart';
import 'package:book_reader_app/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: splashAnimationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize auth provider (checks for existing token)
    await authProvider.initAuthProvider();

    // Wait a bit for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if onboarding has been completed
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    // Navigate based on onboarding and auth status
    if (!onboardingCompleted) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (authProvider.status == AuthStatus.authenticated) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TabsScreen()),
      );
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated App Logo
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: logoSizeSplash,
                      height: logoSizeSplash,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadiusXLarge),
                      ),
                      child: AppLogo.splash(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Book Reader',
                style: displayLarge.copyWith(color: primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
