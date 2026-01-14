import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/widgets/book_card.dart';
import 'package:flutter/material.dart';

class BooksGrid extends StatelessWidget {
  final List<Map<String, dynamic>> books;
  final Function(Map<String, dynamic>)? onBookTap;

  const BooksGrid({super.key, required this.books, this.onBookTap});

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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.48,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        // Safely extract progress - handle different possible field names and types
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

        // Safely extract color
        Color coverColor = primaryColor;
        if (book['color'] != null && book['color'] is Color) {
          coverColor = book['color'];
        } else if (book['cover_color'] != null &&
            book['cover_color'] is Color) {
          coverColor = book['cover_color'];
        } else {
          // Generate color from title or cover_url
          final title = book['title']?.toString() ?? '';
          coverColor = _getColorFromString(title);
        }

        return GestureDetector(
          onTap: () => onBookTap?.call(book),
          child: BookCard(
            title: book['title']?.toString() ?? 'Untitled',
            progress: progress,
            coverColor: coverColor,
          ),
        );
      },
    );
  }
}
