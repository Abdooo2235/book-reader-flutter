import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// In-body screen header used by the tab screens that don't have an AppBar
/// (Home, Favourites, ...). Unifies the four divergent header treatments into
/// one Fraunces title + optional leading/trailing slots.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        spacingLarge,
        spacingMedium,
        spacingLarge,
        spacingSmall,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: spacingSmall),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: displayMedium.copyWith(color: colors.onSurface),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: bodySmall.copyWith(color: colors.secondaryText),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
