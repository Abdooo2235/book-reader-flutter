import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/navigator_key.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/cart_provider.dart';
import 'package:book_reader_app/providers/category_provider.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/providers/preferences_provider.dart';
import 'package:book_reader_app/providers/progress_provider.dart';
import 'package:book_reader_app/providers/review_provider.dart';
import 'package:book_reader_app/screens/auth/splash_screen.dart';
import 'package:book_reader_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // Initialize API service
  Api().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => BookProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
        ChangeNotifierProvider(create: (context) => ProgressProvider()),
        ChangeNotifierProvider(create: (context) => ReviewProvider()),
        ChangeNotifierProvider(create: (context) => PreferencesProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Book Reader',
        theme: ThemeData(
          scaffoldBackgroundColor: scaffoldBackgroundColor,
          appBarTheme: AppBarTheme(backgroundColor: scaffoldBackgroundColor),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
