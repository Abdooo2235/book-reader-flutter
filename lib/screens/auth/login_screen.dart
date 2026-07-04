import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/screens/auth/signup_screen.dart';
import 'package:book_reader_app/screens/main/tabs_screen.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/app_logo.dart';
import 'package:book_reader_app/widgets/common/app_button.dart';
import 'package:book_reader_app/widgets/text_field_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController(
    text: kDebugMode ? 'test@gmail.com' : '',
  );
  TextEditingController password = TextEditingController(
    text: kDebugMode ? 'password' : '',
  );
  bool obsecurePassword = true;

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Show loading indicator
      if (mounted) {
        UiUtils.showLoadingDialog(context);
      }

      try {
        await authProvider.login(
          email: email.text.trim(),
          password: password.text,
        );

        if (mounted) {
          // Close loading dialog
          UiUtils.closeDialog(context);

          // Navigate to home screen and clear navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TabsScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          // Close loading dialog
          UiUtils.closeDialog(context);

          // Get error message from provider
          final errorMsg =
              authProvider.errorMessage ?? 'Login failed. Please try again.';

          // Show error message
          UiUtils.showErrorSnackBar(context, errorMsg);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Subtle staggered entrance for the form; slide is skipped under
    // reduced-motion, fade is always kept.
    var order = 0;
    Widget stagger(Widget child) {
      final animation = child
          .animate(delay: (order++ * staggerStep.inMilliseconds).ms)
          .fadeIn(duration: animationDurationMedium);
      if (reduceMotion) return animation;
      return animation.slideY(
        begin: 0.1,
        end: 0,
        duration: animationDurationMedium,
        curve: easeOutStrong,
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: spacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                  // App Logo
                  stagger(
                    Padding(
                      padding: const EdgeInsets.only(bottom: spacingSmall),
                      child: AppLogo.login(),
                    ),
                  ),
                  const SizedBox(height: spacingLarge),
                  stagger(
                    TextFieldWidget(
                      label: "Email",
                      hintText: "Enter your email address",
                      controller: email,
                      validator: emailValidator,
                      keyboardType: TextInputType.emailAddress,
                      prefixWidget: Icon(Icons.email, color: colors.primary),
                      horizontalPadding: 0,
                      verticalPadding: spacingSmall,
                    ),
                  ),
                  stagger(
                    TextFieldWidget(
                      obsecureText: obsecurePassword,
                      suffixWidget: GestureDetector(
                        onTap: () => setState(() {
                          obsecurePassword = !obsecurePassword;
                        }),
                        child: Icon(
                          obsecurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: colors.primary,
                        ),
                      ),
                      label: "Password",
                      hintText: "Enter your password",
                      controller: password,
                      validator: passwordValidator,
                      prefixWidget: Icon(Icons.lock, color: colors.primary),
                      horizontalPadding: 0,
                      verticalPadding: spacingSmall,
                    ),
                  ),
                  const SizedBox(height: spacingMedium),
                  stagger(
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: spacingMedium,
                      ),
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return PrimaryButton(
                            label: "Login",
                            busy: authProvider.busy,
                            onPressed: _handleLogin,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: spacingMedium),
                  stagger(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: bodyMedium.copyWith(
                            color: colors.secondaryText,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: labelSmall.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
