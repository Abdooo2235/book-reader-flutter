import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/pressable_scale.dart';
import 'package:flutter/material.dart';

/// Elevated surface container. Replaces the `BoxDecoration(color, radius,
/// border, boxShadow)` block that was duplicated across profile/submit-dialog.
///
/// When [onTap] is provided the card gets press-scale feedback.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(spacingMedium),
    this.radius = borderRadiusMedium,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return PressableScale(onTap: onTap, child: card);
  }
}

/// Tinted rounded square holding an icon — the leading element used in profile
/// option rows and the submit-book dialog. Centralized here.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, this.color});

  final IconData icon;

  /// Base accent; defaults to theme primary. The tile tints it at 12%.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.of(context).primary;
    return Container(
      padding: const EdgeInsets.all(spacingSmall),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadiusSmall),
      ),
      child: Icon(icon, color: accent, size: 22),
    );
  }
}
