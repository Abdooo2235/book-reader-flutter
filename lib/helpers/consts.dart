import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ------------------- API CONSTS -------------------
String baseUrl = "";

// ------------------- COLORS CONSTS -------------------

const Color primaryColor = Color(0xff7A4A2E);
const Color scaffoldBackgroundColor = Color.fromARGB(255, 250, 243, 232);
const Color whiteColor = Color(0xffFAF7F2);
const Color blackColor = Color(0xff2B1D14);

const Color redColor = Color(0xffB5533C);
const Color greenColor = Color(0xff6B8E4E);

// ------------------- TEXT CONSTS -------------------

Duration animationDuration = Duration(milliseconds: 300);

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
