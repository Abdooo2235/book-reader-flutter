import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/material.dart';

/// Semantic color resolver for the app.
///
/// Instead of the `isDark ? x : y` ternary that used to be copy-pasted at the
/// top of every `build()`, widgets read `AppColors.of(context).<role>` and the
/// right light/dark value is chosen by the active theme. Register [light]/[dark]
/// in the respective [ThemeData.extensions] (see main.dart).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryText,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.secondaryText,
    required this.border,
    required this.shadow,
    required this.danger,
    required this.success,
    required this.star,
  });

  /// Brand accent (buttons, active nav, progress). White text is legible on it.
  final Color primary;

  /// Darker accent variant for small accent-colored text on light surfaces.
  final Color primaryText;

  /// Foreground used on top of [primary].
  final Color onPrimary;

  /// App scaffold background.
  final Color background;

  /// Raised surface (cards, sheets, dialogs).
  final Color surface;

  /// Primary text/icon color on [background]/[surface].
  final Color onSurface;

  /// Muted secondary text (captions, metadata, hints).
  final Color secondaryText;

  /// Hairline borders / dividers.
  final Color border;

  /// Card/elevation shadow color.
  final Color shadow;

  /// Destructive / error accent.
  final Color danger;

  /// Positive / success accent.
  final Color success;

  /// Rating star color.
  final Color star;

  static const AppColors light = AppColors(
    primary: primaryColor,
    primaryText: primaryTextColor,
    onPrimary: Colors.white,
    background: scaffoldBackgroundColor,
    surface: whiteColor,
    onSurface: blackColor,
    secondaryText: secondaryTextColor,
    border: borderColor,
    shadow: cardShadowColor,
    danger: redColor,
    success: greenColor,
    star: starColor,
  );

  static const AppColors dark = AppColors(
    primary: primaryColorDark,
    primaryText: primaryTextColorDark,
    onPrimary: Colors.black,
    background: scaffoldBackgroundColorDark,
    surface: surfaceColorDark,
    onSurface: whiteColorDark,
    secondaryText: secondaryTextColorDark,
    border: borderColorDark,
    shadow: cardShadowColor,
    danger: redColorDark,
    success: greenColorDark,
    star: starColor,
  );

  /// Convenience accessor; falls back to [light] if the extension is missing.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? light;
  }

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryText,
    Color? onPrimary,
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? secondaryText,
    Color? border,
    Color? shadow,
    Color? danger,
    Color? success,
    Color? star,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryText: primaryText ?? this.primaryText,
      onPrimary: onPrimary ?? this.onPrimary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      secondaryText: secondaryText ?? this.secondaryText,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      star: star ?? this.star,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      star: Color.lerp(star, other.star, t)!,
    );
  }
}
