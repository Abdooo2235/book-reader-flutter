import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable app logo widget
class AppLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = logoSizeMedium,
    this.fit = BoxFit.contain,
  });

  const AppLogo.small({
    super.key,
    this.size = logoSizeSmall,
    this.fit = BoxFit.contain,
  });

  const AppLogo.medium({
    super.key,
    this.size = logoSizeMedium,
    this.fit = BoxFit.contain,
  });

  const AppLogo.large({
    super.key,
    this.size = logoSizeLarge,
    this.fit = BoxFit.contain,
  });

  const AppLogo.splash({
    super.key,
    this.size = logoSizeSplash,
    this.fit = BoxFit.contain,
  });

  const AppLogo.login({
    super.key,
    this.size = logoSizeLogin,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/Book Store Logo 1.svg',
      width: size,
      height: size,
      fit: fit,
    );
  }
}
