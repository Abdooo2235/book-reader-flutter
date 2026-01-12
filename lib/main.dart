import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/screens/auth/login_screen.dart';
import 'package:book_reader_app/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: scaffoldBackgroundColor,
          appBarTheme: AppBarTheme(backgroundColor: scaffoldBackgroundColor),
        ),
        home: const TabsScreen(),
      ),
    );
  }
}
