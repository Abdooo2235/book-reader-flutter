import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centered empty-state block (icon + title + message + optional action).
/// One widget for the 6 near-identical copies that lived in home/favourite/
/// library/search screens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.scrollable = true,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  /// Wraps content so it can sit inside a `RefreshIndicator` and still scroll.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final content =
        Padding(
              padding: const EdgeInsets.all(spacingXLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: colors.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: spacingMedium),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: displaySmall.copyWith(color: colors.onSurface),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: spacingSmall),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: bodyMedium.copyWith(color: colors.secondaryText),
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: spacingLarge),
                    action!,
                  ],
                ],
              ),
            )
            .animate()
            .fadeIn(duration: animationDurationMedium)
            .slideY(
              begin: 0.08,
              end: 0,
              curve: easeOutStrong,
              duration: animationDurationMedium,
            );

    if (!scrollable) return Center(child: content);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: content),
        ),
      ),
    );
  }
}
