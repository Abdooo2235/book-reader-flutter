import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/screens/auth/signup_screen.dart';
import 'package:book_reader_app/screens/main/tabs_screen.dart';
import 'package:book_reader_app/widgets/app_logo.dart';
import 'package:book_reader_app/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
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
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacingXLarge),
                    child: AppLogo.login(),
                  ),
                  const SizedBox(height: spacingLarge),
                  TextFieldWidget(
                    label: "Email",
                    hintText: "Enter your email address",
                    controller: email,
                    validator: emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    prefixWidget: Icon(Icons.email, color: primaryColor),
                    horizontalPadding: 0,
                    verticalPadding: spacingSmall,
                  ),
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
                        color: primaryColor,
                      ),
                    ),
                    label: "Password",
                    hintText: "Enter your password",
                    controller: password,
                    validator: passwordValidator,
                    prefixWidget: Icon(Icons.lock, color: primaryColor),
                    horizontalPadding: 0,
                    verticalPadding: spacingSmall,
                  ),
                  const SizedBox(height: spacingMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: spacingMedium,
                    ),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authProvider.busy ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadiusMedium,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: authProvider.busy
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    "Login",
                                    style: labelMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: spacingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: bodyMedium.copyWith(color: Colors.grey[700]),
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
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
