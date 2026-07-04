import 'package:animations/animations.dart';
import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/navigator_key.dart';
import 'package:book_reader_app/theme/app_colors.dart';
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

  // Shared page-transition theme: shared-axis motion on push/pop.
  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
      TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
        transitionType: SharedAxisTransitionType.horizontal,
      ),
    },
  );

  // Maps token text styles onto the Material TextTheme (Fraunces display,
  // Cairo body/labels) so `Theme.of(context).textTheme` is consistent app-wide.
  TextTheme _textTheme(Color onSurface, Color muted) => TextTheme(
    displayLarge: displayLarge.copyWith(color: onSurface),
    displayMedium: displayMedium.copyWith(color: onSurface),
    displaySmall: displaySmall.copyWith(color: onSurface),
    titleLarge: labelLarge.copyWith(color: onSurface),
    titleMedium: labelMedium.copyWith(color: onSurface),
    titleSmall: labelSmall.copyWith(color: onSurface),
    bodyLarge: bodyLarge.copyWith(color: onSurface),
    bodyMedium: bodyMedium.copyWith(color: onSurface),
    bodySmall: bodySmall.copyWith(color: muted),
  );

  // Light theme
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    cardColor: whiteColor,
    dividerColor: borderColor,
    extensions: const [AppColors.light],
    pageTransitionsTheme: _pageTransitions,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      foregroundColor: blackColor,
      elevation: 0,
      titleTextStyle: displaySmall.copyWith(color: blackColor),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: redColor,
      onSecondary: Colors.white,
      surface: whiteColor,
      onSurface: blackColor,
      error: redColor,
    ),
    iconTheme: const IconThemeData(color: blackColor),
    textTheme: _textTheme(blackColor, secondaryTextColor),
  );

  // Dark theme (warm palette matching light mode)
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: scaffoldBackgroundColorDark,
    cardColor: surfaceColorDark,
    dividerColor: borderColorDark,
    extensions: const [AppColors.dark],
    pageTransitionsTheme: _pageTransitions,
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackgroundColorDark,
      foregroundColor: whiteColorDark,
      elevation: 0,
      titleTextStyle: displaySmall.copyWith(color: whiteColorDark),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDark,
      onPrimary: Colors.black,
      secondary: redColorDark,
      onSecondary: Colors.black,
      surface: surfaceColorDark,
      onSurface: whiteColorDark,
      error: redColorDark,
    ),
    iconTheme: const IconThemeData(color: whiteColorDark),
    textTheme: _textTheme(whiteColorDark, secondaryTextColorDark),
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
