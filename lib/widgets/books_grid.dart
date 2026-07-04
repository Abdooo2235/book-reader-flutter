import 'dart:math' as math;

import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/cover_utils.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/book_card.dart';
import 'package:book_reader_app/widgets/common/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BooksGrid extends StatelessWidget {
  final List<Map<String, dynamic>> books;
  final Function(Map<String, dynamic>)? onBookTap;
  final bool isSelectionMode;
  final Set<int> selectedBookIds;
  final Map<int, Map<String, dynamic>>? progressMap;

  const BooksGrid({
    super.key,
    required this.books,
    this.onBookTap,
    this.isSelectionMode = false,
    this.selectedBookIds = const {},
    this.progressMap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return GridView.builder(
      padding: const EdgeInsets.all(spacingMedium),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.48,
        crossAxisSpacing: spacingMedium,
        mainAxisSpacing: spacingMedium,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        // Safely extract progress
        double progress = 0.0;
        if (book['progress'] != null) {
          if (book['progress'] is double) {
            progress = book['progress'];
          } else if (book['progress'] is int) {
            progress = (book['progress'] as int).toDouble();
          } else if (book['progress'] is num) {
            progress = (book['progress'] as num).toDouble();
          }
        } else if (book['progress_percentage'] != null) {
          if (book['progress_percentage'] is double) {
            progress = book['progress_percentage'];
          } else if (book['progress_percentage'] is int) {
            progress = (book['progress_percentage'] as int).toDouble();
          } else if (book['progress_percentage'] is num) {
            progress = (book['progress_percentage'] as num).toDouble();
          }
        }

        // Cover color: explicit override, else deterministic fallback from title.
        Color coverColor;
        if (book['color'] != null && book['color'] is Color) {
          coverColor = book['color'];
        } else if (book['cover_color'] != null &&
            book['cover_color'] is Color) {
          coverColor = book['cover_color'];
        } else {
          coverColor = CoverUtils.colorFor(book['title']?.toString());
        }

        final coverUrl = CoverUtils.resolveUrl(book);

        final bookId = book['id'];
        final bookIdInt = bookId is int
            ? bookId
            : int.tryParse(bookId?.toString() ?? '');
        final isSelected =
            bookIdInt != null && selectedBookIds.contains(bookIdInt);

        // Get progress from progressMap if available (for reading tab)
        if (progressMap != null && bookIdInt != null) {
          final bookProgress = progressMap![bookIdInt];
          if (bookProgress != null) {
            final progressValue = bookProgress['progress_percentage'];
            if (progressValue != null) {
              if (progressValue is double) {
                progress = progressValue;
              } else if (progressValue is int) {
                progress = progressValue.toDouble();
              } else if (progressValue is String) {
                progress = double.tryParse(progressValue) ?? progress;
              } else if (progressValue is num) {
                progress = progressValue.toDouble();
              }
            }
          }
        }

        final card = Stack(
          children: [
            BookCard(
              title: book['title']?.toString() ?? 'Untitled',
              author: book['author']?.toString(),
              progress: progress,
              coverColor: coverColor,
              coverUrl: coverUrl,
              isSelected: isSelected,
              bookId: bookIdInt,
              showProgressCircle:
                  progressMap != null, // Show circle only in reading tab
            ),
            if (isSelectionMode)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary
                        : colors.surface.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.border,
                      width: isSelected ? 0 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: colors.onPrimary, size: 18)
                      : Icon(
                          Icons.circle_outlined,
                          color: colors.secondaryText,
                          size: 20,
                        ),
                ),
              ),
          ],
        );

        // Staggered entrance: always fade; add slide unless reduced-motion.
        final delay = (math.min(index, 10) * 40).ms;
        final Widget animated = reduceMotion
            ? card
                  .animate(delay: delay)
                  .fadeIn(duration: animationDurationMedium)
            : card
                  .animate(delay: delay)
                  .fadeIn(duration: animationDurationMedium)
                  .slideY(
                    begin: 0.08,
                    end: 0,
                    curve: easeOutStrong,
                    duration: animationDurationMedium,
                  );

        return PressableScale(
          onTap: onBookTap == null ? null : () => onBookTap!(book),
          child: animated,
        );
      },
    );
  }
}
