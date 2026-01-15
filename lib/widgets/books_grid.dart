import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/widgets/book_card.dart';
import 'package:flutter/material.dart';

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

  // Generate a color from a string (for consistent colors per book)
  Color _getColorFromString(String str) {
    if (str.isEmpty) return primaryColor;

    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }

    // Generate a color from the hash
    final colors = [
      const Color(0xff7A4A2E),
      const Color(0xffB5533C),
      const Color(0xff6B8E4E),
      const Color(0xff4A7C8E),
      const Color(0xff8B6F47),
      const Color(0xff9B7A5A),
      const Color(0xff5A7A4A),
      const Color(0xffC4A484),
      const Color(0xff6B5A7A),
    ];

    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.48,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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

        // Safely extract cover color
        Color coverColor = primaryColor;
        if (book['color'] != null && book['color'] is Color) {
          coverColor = book['color'];
        } else if (book['cover_color'] != null &&
            book['cover_color'] is Color) {
          coverColor = book['cover_color'];
        } else {
          final title = book['title']?.toString() ?? '';
          coverColor = _getColorFromString(title);
        }

        // Extract cover URL from backend response
        String? coverUrl = book['cover_url']?.toString();
        coverUrl ??= book['cover_image']?.toString();
        coverUrl ??= book['cover_thumb_url']?.toString();

        final bookId = book['id'];
        final bookIdInt = bookId is int
            ? bookId
            : int.tryParse(bookId?.toString() ?? '');
        final isSelected = bookIdInt != null && selectedBookIds.contains(bookIdInt);

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

        return GestureDetector(
          onTap: () => onBookTap?.call(book),
          child: Stack(
            children: [
              BookCard(
                title: book['title']?.toString() ?? 'Untitled',
                author: book['author']?.toString(),
                progress: progress,
                coverColor: coverColor,
                coverUrl: coverUrl,
                isSelected: isSelected,
                showProgressCircle: progressMap != null, // Show circle only in reading tab
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
                          ? primaryColor
                          : Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.shade400,
                        width: isSelected ? 0 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
