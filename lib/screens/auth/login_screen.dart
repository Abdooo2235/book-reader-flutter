import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/screens/auth/signup_screen.dart';
import 'package:book_reader_app/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool obsecurePassword = true;

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFieldWidget(
              label: "Email",
              controller: email,
              validator: validator,
              keyboardType: TextInputType.emailAddress,
              prefixWidget: Icon(Icons.email, color: primaryColor),
            ),
            TextFieldWidget(
              obsecureText: obsecurePassword,
              suffixWidget: GestureDetector(
                onTap: () => setState(() {
                  obsecurePassword = !obsecurePassword;
                }),
                child: Icon(
                  obsecurePassword ? Icons.visibility_off : Icons.visibility,
                  color: primaryColor,
                ),
              ),
              label: "Password",
              controller: password,
              validator: validator,

              prefixWidget: Icon(Icons.lock, color: primaryColor),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MaterialButton(
                minWidth: double.infinity,
                height: 50,
                color: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Login",
                  style: labelMedium.copyWith(color: whiteColor),
                ),
                onPressed: () {},
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: labelSmall.copyWith(fontSize: 17),
                ),
                TextButton(
                  child: Text(
                    "Create one now ",
                    style: labelSmall.copyWith(
                      color: primaryColor,
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
