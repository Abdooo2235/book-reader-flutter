import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ------------------- API CONSTS -------------------
String baseUrl = "https://book-reader-store-backend.onrender.com/api";

// ------------------- COLORS CONSTS -------------------
// Design system: emerald accent on warm cream surfaces (light-first) with a
// full warm dark mode. All screens read colors from these tokens or from
// AppColors.of(context) (see theme/app_colors.dart) — never hardcode hex.

// Light mode colors
const Color primaryColor = Color(
  0xff1F7A5A,
); // emerald (white-on-primary = 5.27:1 AA)
const Color primaryTextColor = Color(
  0xff1A6B4E,
); // darker emerald for small text on cream (~5.3:1)
const Color scaffoldBackgroundColor = Color.fromARGB(
  255,
  250,
  243,
  232,
); // cream
const Color whiteColor = Color(0xffFAF7F2); // off-white card surface
const Color blackColor = Color(0xff2B1D14); // espresso text (14.8:1 on cream)
const Color secondaryTextColor = Color(
  0xff6B5D52,
); // muted brown-grey body text
const Color borderColor = Color(0xffE7DCC9); // hairline on cream

const Color redColor = Color(
  0xffB5533C,
); // terracotta — danger / accent (large only)
const Color greenColor = Color(0xff6B8E4E); // olive — success
const Color starColor = Color(0xffE7A93B); // amber — ratings

// Dark mode colors
const Color primaryColorDark = Color(
  0xff4FB68C,
); // lighter emerald for dark surfaces
const Color primaryTextColorDark = Color(0xff6FCBA1);
const Color scaffoldBackgroundColorDark = Color(0xff1C1410); // espresso
const Color surfaceColorDark = Color(0xff241A15);
const Color whiteColorDark = Color(0xffEFE6DC);
const Color blackColorDark = Color(0xff120C09);
const Color secondaryTextColorDark = Color(0xffB7A99A);
const Color borderColorDark = Color(0xff3A2C22);
const Color redColorDark = Color(0xffC96A54);
const Color greenColorDark = Color(0xff8FB573);

// ------------------- READING SURFACES -------------------
// Reader page backgrounds + their body text, applied via ColorFiltered / theming.
const Color readingWhite = Color(0xffFFFFFF);
const Color readingWhiteText = Color(0xff1A1A1A);
const Color readingSepia = Color(0xffF4ECD8);
const Color readingSepiaText = Color(0xff4A3B29);
const Color readingGrey = Color(0xff3A3A3A);
const Color readingGreyText = Color(0xffD8D8D8);
const Color readingNight = Color(0xff121212);
const Color readingNightText = Color(0xffCFCFCF);

// In-reader highlight palette (translucent overlays).
const List<Color> highlightColors = [
  Color(0xff1F7A5A), // emerald
  Color(0xffE7A93B), // amber
  Color(0xffE23C6B), // rose
  Color(0xff4A7C8E), // teal-blue
];

// ------------------- BOOK COVER PALETTE -------------------
// Deterministic fallback colors for covers without an image. Single source
// (see helpers/cover_utils.dart) — previously duplicated across 3 files.
const List<Color> coverPalette = [
  Color(0xff1F7A5A),
  Color(0xffB5533C),
  Color(0xff6B8E4E),
  Color(0xff4A7C8E),
  Color(0xff8B6F47),
  Color(0xff9B7A5A),
  Color(0xff5A7A4A),
  Color(0xffC4A484),
  Color(0xff6B5A7A),
];

// ------------------- ELEVATION -------------------
const Color cardShadowColor = Color(0x14000000); // 8% black — soft card shadow

// ------------------- TEXT CONSTS -------------------

Duration animationDuration = Duration(milliseconds: 300);

// ------------------- UI CONSTS -------------------

// Logo sizes
const double logoSizeSmall = 32.0;
const double logoSizeMedium = 56.0;
const double logoSizeLarge = 80.0;
const double logoSizeSplash = 150.0;
const double logoSizeLogin = 250.0;

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

// Motion easing curves (strong custom curves — built-in easings are too weak).
const Cubic easeOutStrong = Cubic(
  0.23,
  1.0,
  0.32,
  1.0,
); // entering / responsive
const Cubic easeInOutStrong = Cubic(
  0.77,
  0.0,
  0.175,
  1.0,
); // on-screen movement
const Cubic easeDrawer = Cubic(0.32, 0.72, 0.0, 1.0); // sheets / drawers
const Duration pressFeedbackDuration = Duration(milliseconds: 120);
const double pressScale = 0.97; // button/card press feedback scale
const Duration staggerStep = Duration(
  milliseconds: 50,
); // list entrance stagger

// SnackBar durations
const Duration snackBarDurationShort = Duration(seconds: 2);
const Duration snackBarDurationMedium = Duration(seconds: 3);
const Duration snackBarDurationLong = Duration(seconds: 4);

// File picker
const List<String> allowedBookExtensions = ['pdf', 'epub'];
const double maxImageWidth = 800.0;
const double maxImageHeight = 800.0;
const int imageQuality = 85;

// Display / titles — Fraunces serif for a literary, "book" voice.
TextStyle displaySmall = GoogleFonts.fraunces(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);
TextStyle displayMedium = GoogleFonts.fraunces(
  fontSize: 24,
  fontWeight: FontWeight.w600,
);
TextStyle displayLarge = GoogleFonts.fraunces(
  fontSize: 28,
  fontWeight: FontWeight.w700,
);

// Labels — Cairo (bold), for UI chrome / buttons / nav (keeps Arabic capability).
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

// Body — Cairo (normal), for general UI text.
TextStyle bodySmall = GoogleFonts.cairo(
  fontSize: 12,
  fontWeight: FontWeight.normal,
);
TextStyle bodyMedium = GoogleFonts.cairo(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  height: 1.5,
);
TextStyle bodyLarge = GoogleFonts.cairo(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  height: 1.5,
);

// Reading body — Lora serif, for immersive in-book / long-form reading text.
TextStyle readingBody = GoogleFonts.lora(
  fontSize: 18,
  fontWeight: FontWeight.normal,
  height: 1.7,
);
