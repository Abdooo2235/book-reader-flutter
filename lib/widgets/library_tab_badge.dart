import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LibraryTabBadge extends StatelessWidget {
  final String count;

  const LibraryTabBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(borderRadiusSmall),
      ),
      child: Text(
        count,
        style: bodySmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: colors.secondaryText,
        ),
      ),
    );
  }
}
