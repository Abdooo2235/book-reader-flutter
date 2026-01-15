import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ------------------- API CONSTS -------------------
String baseUrl = "https://book-reader-store-backend.onrender.com/api";

// ------------------- COLORS CONSTS -------------------

// Light mode colors
const Color primaryColor = Color(0xff7A4A2E);
const Color scaffoldBackgroundColor = Color.fromARGB(255, 250, 243, 232);
const Color whiteColor = Color(0xffFAF7F2);
const Color blackColor = Color(0xff2B1D14);

const Color redColor = Color(0xffB5533C);
const Color greenColor = Color(0xff6B8E4E);

// Dark mode colors
const Color primaryColorDark = Color(
  0xffC89B7B,
);
const Color scaffoldBackgroundColorDark = Color(
  0xff1C1410,
);
const Color surfaceColorDark = Color(0xff241A15); 
const Color whiteColorDark = Color(0xffEFE6DC);
const Color blackColorDark = Color(0xff120C09);
const Color redColorDark = Color(0xffC96A54);
const Color greenColorDark = Color(0xff8FB573);

// ------------------- TEXT CONSTS -------------------

Duration animationDuration = Duration(milliseconds: 300);

// ------------------- UI CONSTS -------------------

// Logo sizes
const double logoSizeSmall = 32.0;
const double logoSizeMedium = 56.0;
const double logoSizeLarge = 80.0;
const double logoSizeSplash = 150.0;
const double logoSizeLogin = 130.0;

// Spacing
const double spacingSmall = 8.0;
const double spacingMedium = 16.0;
const double spacingLarge = 24.0;
const double spacingXLarge = 32.0;

// Border radius
const double borderRadiusSmall = 8.0;
const double borderRadiusMedium = 12.0;
const double borderRadiusLarge = 16.0;
const double borderRadiusXLarge = 20.0;

// Animation durations
const Duration animationDurationShort = Duration(milliseconds: 200);
const Duration animationDurationMedium = Duration(milliseconds: 300);
const Duration animationDurationLong = Duration(milliseconds: 500);
const Duration splashAnimationDuration = Duration(milliseconds: 1200);

// SnackBar durations
const Duration snackBarDurationShort = Duration(seconds: 2);
const Duration snackBarDurationMedium = Duration(seconds: 3);
const Duration snackBarDurationLong = Duration(seconds: 4);

// File picker
const List<String> allowedBookExtensions = ['pdf', 'epub'];
const double maxImageWidth = 800.0;
const double maxImageHeight = 800.0;
const int imageQuality = 85;

TextStyle displaySmall = GoogleFonts.cairo(
  fontSize: 20,
  fontWeight: FontWeight.bold,
);
TextStyle displayMedium = GoogleFonts.cairo(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);
TextStyle displayLarge = GoogleFonts.cairo(
  fontSize: 28,
  fontWeight: FontWeight.bold,
);

TextStyle labelSmall = GoogleFonts.cairo(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);
TextStyle labelMedium = GoogleFonts.cairo(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
TextStyle labelLarge = GoogleFonts.cairo(
  fontSize: 22,
  fontWeight: FontWeight.bold,
);

TextStyle bodySmall = GoogleFonts.cairo(
  fontSize: 12,
  fontWeight: FontWeight.normal,
);
TextStyle bodyMedium = GoogleFonts.cairo(
  fontSize: 14,
  fontWeight: FontWeight.normal,
);
TextStyle bodyLarge = GoogleFonts.cairo(
  fontSize: 16,
  fontWeight: FontWeight.normal,
);
