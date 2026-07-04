import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DownloadProgressDialog extends StatelessWidget {
  final String bookTitle;
  final double progress; // 0.0 to 1.0
  final VoidCallback? onCancel;

  const DownloadProgressDialog({
    super.key,
    required this.bookTitle,
    required this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final backgroundColor = colors.surface;
    final textColor = colors.onSurface;
    final mutedTextColor = colors.secondaryText;
    final percentage = (progress * 100).toInt();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(spacingLarge),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Progress Circle
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  // Background circle
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                  // Progress circle
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          primaryColor,
                        ),
                      ),
                    ),
                  ),
                  // Percentage text
                  Center(
                    child: Text(
                      '$percentage%',
                      style: labelLarge.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Downloading Book',
              style: labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Book name
            Text(
              bookTitle,
              style: bodyMedium.copyWith(color: mutedTextColor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            const SizedBox(height: 20),

            // Cancel button
            if (onCancel != null)
              TextButton(
                onPressed: onCancel,
                child: Text(
                  'Cancel',
                  style: bodyMedium.copyWith(
                    color: colors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show download progress dialog
void showDownloadProgressDialog({
  required BuildContext context,
  required String bookTitle,
  required ValueNotifier<double> progressNotifier,
  VoidCallback? onCancel,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ValueListenableBuilder<double>(
      valueListenable: progressNotifier,
      builder: (context, progress, _) => DownloadProgressDialog(
        bookTitle: bookTitle,
        progress: progress,
        onCancel: onCancel,
      ),
    ),
  );
}
