import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shared SnackBar + dialog helpers. This is the single place snackbars are
/// built — screens must call these instead of hand-rolling
/// `ScaffoldMessenger...showSnackBar` (which was duplicated 17× before).
class UiUtils {
  const UiUtils._();

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color background,
    IconData? icon,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: spacingSmall + 4),
              ],
              Expanded(
                child: Text(
                  message,
                  style: bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          margin: const EdgeInsets.all(spacingMedium),
          duration: duration,
        ),
      );
  }

  /// Success (green) SnackBar.
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = snackBarDurationMedium,
  }) => _showSnackBar(
    context,
    message,
    background: AppColors.of(context).success,
    icon: Icons.check_circle,
    duration: duration,
  );

  /// Error (danger) SnackBar.
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = snackBarDurationLong,
  }) => _showSnackBar(
    context,
    message,
    background: AppColors.of(context).danger,
    icon: Icons.error_outline,
    duration: duration,
  );

  /// Info (primary) SnackBar.
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = snackBarDurationMedium,
  }) => _showSnackBar(
    context,
    message,
    background: AppColors.of(context).primary,
    icon: Icons.info_outline,
    duration: duration,
  );

  /// Plain SnackBar without an icon.
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = snackBarDurationMedium,
  }) => _showSnackBar(
    context,
    message,
    background: backgroundColor ?? AppColors.of(context).primary,
    duration: duration,
  );

  /// Blocking loading dialog.
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  /// Closes the current dialog if one is open.
  static void closeDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Confirmation dialog returning true when confirmed.
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final colors = AppColors.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        title: Text(
          title,
          style: displaySmall.copyWith(color: colors.onSurface),
        ),
        content: Text(
          message,
          style: bodyMedium.copyWith(color: colors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              cancelText,
              style: bodyMedium.copyWith(color: colors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
