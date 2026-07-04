import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String? author;
  final double progress;
  final Color coverColor;
  final String? coverUrl;
  final bool isSelected;
  final bool showProgressCircle;

  /// Book id used to build the shared-element `Hero` tag so the cover morphs
  /// into the details screen (which uses the same `book-cover-<id>` convention).
  final int? bookId;

  const BookCard({
    super.key,
    required this.title,
    this.author,
    required this.progress,
    required this.coverColor,
    this.coverUrl,
    this.isSelected = false,
    this.showProgressCircle = false,
    this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Widget cover = Container(
      decoration: BoxDecoration(
        color: coverColor,
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        border: isSelected ? Border.all(color: colors.primary, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.5)
                : colors.shadow,
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl != null && coverUrl!.isNotEmpty
          ? Image.network(
              coverUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            )
          : _buildPlaceholder(),
    );

    // Shared-element transition into the details screen.
    if (bookId != null) {
      cover = Hero(tag: 'book-cover-$bookId', child: cover);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Aspect Ratio for Book Cover
        AspectRatio(
          aspectRatio: 0.7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              cover,
              // Selection Overlay
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(borderRadiusMedium),
                  ),
                ),
              // Progress Badge (Top Left) - Only show if not using circle at bottom
              if (progress > 0 && !showProgressCircle)
                Positioned(
                  top: spacingSmall,
                  left: spacingSmall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: blackColor.withAlpha(200),
                      borderRadius: BorderRadius.circular(borderRadiusSmall),
                    ),
                    child: Text(
                      "${progress.toInt()}%",
                      style: bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Progress Circle or Play Button (Bottom Right)
              Positioned(
                bottom: spacingSmall,
                right: spacingSmall,
                child: showProgressCircle && progress > 0
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "${progress.toInt()}%",
                            style: bodySmall.copyWith(
                              color: blackColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.play_fill,
                          size: 14,
                          color: blackColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: spacingSmall),
        // Title
        Text(
          title,
          style: labelSmall.copyWith(
            fontSize: 12,
            height: 1.2,
            color: colors.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // Author (if provided)
        if (author != null && author!.isNotEmpty)
          Text(
            author!,
            style: bodySmall.copyWith(
              fontSize: 10,
              color: colors.secondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        CupertinoIcons.book_fill,
        color: Colors.white.withAlpha(100),
        size: 40,
      ),
    );
  }
}
