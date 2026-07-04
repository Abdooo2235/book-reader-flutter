import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/pressable_scale.dart';
import 'package:flutter/material.dart';

/// Filled primary action button. Replaces the 5+ hand-styled `ElevatedButton`s
/// that each re-implemented the fill + radius + in-button spinner.
///
/// Set [busy] to show a spinner and block taps during async work.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.icon,
    this.expand = true,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  final bool expand;

  /// Overrides the background (defaults to the theme primary).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final background = color ?? colors.primary;
    final enabled = onPressed != null && !busy;

    final button = PressableScale(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.6,
        duration: animationDurationShort,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: spacingLarge),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          alignment: Alignment.center,
          child: busy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: colors.onPrimary, size: 20),
                      const SizedBox(width: spacingSmall),
                    ],
                    Text(
                      label,
                      style: labelSmall.copyWith(color: colors.onPrimary),
                    ),
                  ],
                ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Outlined secondary action button, matching [PrimaryButton]'s shape/behavior.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.busy = false,
    this.icon,
    this.expand = true,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;
  final bool expand;

  /// Overrides the outline + content color (defaults to the theme primary).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accent = color ?? colors.primary;
    final enabled = onPressed != null && !busy;

    final button = PressableScale(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.6,
        duration: animationDurationShort,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: spacingLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            border: Border.all(color: accent, width: 1.5),
          ),
          alignment: Alignment.center,
          child: busy
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: accent, size: 20),
                      const SizedBox(width: spacingSmall),
                    ],
                    Text(label, style: labelSmall.copyWith(color: accent)),
                  ],
                ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
