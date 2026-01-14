import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/screens/auth/login_screen.dart';
import 'package:book_reader_app/screens/main/tabs_screen.dart';
import 'package:book_reader_app/widgets/app_logo.dart';
import 'package:book_reader_app/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordConfirmation = TextEditingController();

  bool obsecurePassword = true;
  bool obsecurePasswordConfirmation = true;

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
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

  String? passwordConfirmationValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Show loading indicator
      if (mounted) {
        UiUtils.showLoadingDialog(context);
      }

      try {
        await authProvider.register(
          name: name.text.trim(),
          email: email.text.trim(),
          password: password.text,
          passwordConfirmation: passwordConfirmation.text,
        );

        if (mounted) {
          // Close loading dialog
          UiUtils.closeDialog(context);
          
          // Navigate to home screen and clear navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const TabsScreen(),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          // Close loading dialog
          UiUtils.closeDialog(context);
          
          // Get error message from provider
          final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
          
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  // App Logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacingLarge),
                    child: AppLogo.login(),
                  ),
                  const SizedBox(height: spacingMedium),
                  TextFieldWidget(
                    label: "Name",
                    hintText: "Enter your full name",
                    controller: name,
                    validator: nameValidator,
                    prefixWidget: Icon(Icons.person, color: primaryColor),
                    horizontalPadding: 0,
                    verticalPadding: spacingSmall,
                  ),
                  TextFieldWidget(
                    controller: email,
                    validator: emailValidator,
                    label: "Email",
                    hintText: "Enter your email address",
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
                    hintText: "Enter your password (min. 6 characters)",
                    controller: password,
                    validator: passwordValidator,
                    prefixWidget: Icon(Icons.lock, color: primaryColor),
                    horizontalPadding: 0,
                    verticalPadding: spacingSmall,
                  ),
                  TextFieldWidget(
                    obsecureText: obsecurePasswordConfirmation,
                    suffixWidget: GestureDetector(
                      onTap: () => setState(() {
                        obsecurePasswordConfirmation = !obsecurePasswordConfirmation;
                      }),
                      child: Icon(
                        obsecurePasswordConfirmation
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: primaryColor,
                      ),
                    ),
                    label: "Confirm Password",
                    hintText: "Re-enter your password",
                    controller: passwordConfirmation,
                    validator: passwordConfirmationValidator,
                    prefixWidget: Icon(Icons.lock, color: primaryColor),
                    horizontalPadding: 0,
                    verticalPadding: spacingSmall,
                  ),
                  const SizedBox(height: spacingMedium),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: spacingMedium),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authProvider.busy ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(borderRadiusMedium),
                              ),
                              elevation: 0,
                          ),
                          child: authProvider.busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  "Sign Up",
                                  style: labelMedium.copyWith(color: Colors.white),
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
                        "Already have an account?",
                        style: bodyMedium.copyWith(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Login",
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
