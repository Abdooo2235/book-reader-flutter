import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/navigator_key.dart';
import 'package:book_reader_app/providers/auth_provider.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/category_provider.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/providers/preferences_provider.dart';
import 'package:book_reader_app/providers/progress_provider.dart';
import 'package:book_reader_app/screens/auth/splash_screen.dart';
import 'package:book_reader_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  Api().init();

  // Initialize preferences from local storage
  final preferencesProvider = PreferencesProvider();
  await preferencesProvider.initFromLocal();

  runApp(MyApp(preferencesProvider: preferencesProvider));
}

class MyApp extends StatelessWidget {
  final PreferencesProvider preferencesProvider;

  const MyApp({super.key, required this.preferencesProvider});

  // Light theme
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    cardColor: whiteColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      foregroundColor: blackColor,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      surface: whiteColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: blackColor,
    ),
    iconTheme: const IconThemeData(color: blackColor),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: blackColor),
      bodyMedium: TextStyle(color: blackColor),
      bodySmall: TextStyle(color: blackColor),
    ),
  );

  // Dark theme (warm palette matching light mode)
  ThemeData get darkTheme => ThemeData(
    
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: scaffoldBackgroundColorDark,
    cardColor: surfaceColorDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldBackgroundColorDark,
      foregroundColor: whiteColorDark,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDark,
      secondary: primaryColorDark,
      surface: surfaceColorDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: whiteColorDark,
    ),
    iconTheme: const IconThemeData(color: whiteColorDark),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: whiteColorDark),
      bodyMedium: TextStyle(color: whiteColorDark),
      bodySmall: TextStyle(color: whiteColorDark),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => BookProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => LibraryProvider()),
        ChangeNotifierProvider(create: (context) => ProgressProvider()),
        ChangeNotifierProvider.value(value: preferencesProvider),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefs, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Book Reader',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
