import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/helper_functions.dart';
import 'package:book_reader_app/screens/auth/login_screen.dart';
import 'package:book_reader_app/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  TextEditingController phone = TextEditingController();

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFieldWidget(
                  label: "Name",
                  controller: name,
                  validator: validator,
                  prefixWidget: Icon(Icons.person, color: primaryColor),
                ),
                TextFieldWidget(
                  controller: email,
                  validator: validator,
                  label: "Email",
                  prefixWidget: Icon(Icons.email, color: primaryColor),
                ),
                TextFieldWidget(
                  controller: phone,
                  validator: validator,
                  label: "Phone Number",
                  prefixWidget: Icon(Icons.phone, color: primaryColor),
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
                  controller: password,
                  validator: validator,
                  prefixWidget: Icon(Icons.lock, color: primaryColor),
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
                  label: "Confirm Password",
                  controller: password,
                  validator: validator,
                  prefixWidget: Icon(Icons.lock, color: primaryColor),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: MaterialButton(
                    height: getSize(context).height * 0.06,
                    minWidth: double.infinity,
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Sign Up",
                      style: labelMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                // dont have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account ?",
                      style: labelSmall.copyWith(fontSize: 17),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginScreen();
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: labelSmall.copyWith(
                          color: primaryColor,
                          fontSize: 17,
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
    );
  }
}
