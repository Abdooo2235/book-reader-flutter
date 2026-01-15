import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String? author;
  final double progress;
  final Color coverColor;
  final String? coverUrl;

  const BookCard({
    super.key,
    required this.title,
    this.author,
    required this.progress,
    required this.coverColor,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? whiteColorDark : blackColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Aspect Ratio for Book Cover
        AspectRatio(
          aspectRatio: 0.7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Book Cover
              Container(
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 4,
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
              ),

              // Progress Badge (Top Left)
              if (progress > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: blackColor.withAlpha(200),
                      borderRadius: BorderRadius.circular(6),
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

              // Play/Action Button (Bottom Right)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
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
        const SizedBox(height: 8),
        // Title
        Text(
          title,
          style: labelSmall.copyWith(
            fontSize: 12,
            height: 1.2,
            color: textColor,
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
              color: textColor.withValues(alpha: 0.6),
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
