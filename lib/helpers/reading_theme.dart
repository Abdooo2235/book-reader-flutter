import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/material.dart';

/// Reader page appearance, applied over the rendered PDF via [ColorFilter].
/// The engine renders black-on-white pages; these modes retint that output so
/// the reading surface matches the inspirations' White / Sepia / Grey / Night.
enum ReadingTheme {
  white,
  sepia,
  grey,
  night;

  String get label => switch (this) {
    ReadingTheme.white => 'White',
    ReadingTheme.sepia => 'Sepia',
    ReadingTheme.grey => 'Grey',
    ReadingTheme.night => 'Night',
  };

  IconData get icon => switch (this) {
    ReadingTheme.white => Icons.wb_sunny_outlined,
    ReadingTheme.sepia => Icons.local_cafe_outlined,
    ReadingTheme.grey => Icons.contrast,
    ReadingTheme.night => Icons.nightlight_outlined,
  };

  /// Swatch shown in the settings picker.
  Color get swatch => switch (this) {
    ReadingTheme.white => readingWhite,
    ReadingTheme.sepia => readingSepia,
    ReadingTheme.grey => readingGrey,
    ReadingTheme.night => readingNight,
  };

  /// Scaffold background behind the page for this mode.
  Color get background => switch (this) {
    ReadingTheme.white => readingWhite,
    ReadingTheme.sepia => readingSepia,
    ReadingTheme.grey => readingGrey,
    ReadingTheme.night => readingNight,
  };

  /// Foreground (chrome text/icons) legible on [background].
  Color get onBackground => switch (this) {
    ReadingTheme.white => readingWhiteText,
    ReadingTheme.sepia => readingSepiaText,
    ReadingTheme.grey => readingGreyText,
    ReadingTheme.night => readingNightText,
  };

  /// Color filter applied to the rendered page. Null = render untouched.
  /// Multiply keeps black text readable while tinting the white paper; night
  /// inverts for a true dark surface.
  ColorFilter? get filter => switch (this) {
    ReadingTheme.white => null,
    ReadingTheme.sepia => const ColorFilter.mode(
      readingSepia,
      BlendMode.multiply,
    ),
    ReadingTheme.grey => const ColorFilter.mode(
      Color(0xFFB8B8B8),
      BlendMode.multiply,
    ),
    ReadingTheme.night => const ColorFilter.matrix(<double>[
      -1, 0, 0, 0, 255, //
      0, -1, 0, 0, 255, //
      0, 0, -1, 0, 255, //
      0, 0, 0, 1, 0, //
    ]),
  };
}
