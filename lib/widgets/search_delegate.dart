import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/widgets/book_card.dart';
import 'package:flutter/material.dart';

class BookSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> books;
  final Function(Map<String, dynamic>)? onBookTap;

  BookSearchDelegate({required this.books, this.onBookTap})
    : super(
        searchFieldLabel: 'Search',
        searchFieldStyle: bodyMedium.copyWith(color: blackColor),
      );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterBooks(query);
    return _buildResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filterBooks(query);
    return _buildResultsList(context, results);
  }

  List<Map<String, dynamic>> _filterBooks(String searchQuery) {
    if (searchQuery.isEmpty) {
      return books;
    }

    final lowerQuery = searchQuery.toLowerCase();
    return books.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      return title.contains(lowerQuery) || author.contains(lowerQuery);
    }).toList();
  }

  // Helper method to safely extract progress
  double _getProgress(Map<String, dynamic> book) {
    if (book['progress'] != null) {
      if (book['progress'] is double) return book['progress'];
      if (book['progress'] is int) return (book['progress'] as int).toDouble();
      if (book['progress'] is num) return (book['progress'] as num).toDouble();
    }
    if (book['progress_percentage'] != null) {
      if (book['progress_percentage'] is double) {
        return book['progress_percentage'];
      }
      if (book['progress_percentage'] is int) {
        return (book['progress_percentage'] as int).toDouble();
      }
      if (book['progress_percentage'] is num) {
        return (book['progress_percentage'] as num).toDouble();
      }
    }
    return 0.0;
  }

  // Helper method to safely extract cover color
  Color _getCoverColor(Map<String, dynamic> book) {
    if (book['color'] != null && book['color'] is Color) {
      return book['color'];
    }
    if (book['cover_color'] != null && book['cover_color'] is Color) {
      return book['cover_color'];
    }
    // Generate color from title
    final title = book['title']?.toString() ?? '';
    return _getColorFromString(title);
  }

  // Generate a color from a string (for consistent colors per book)
  Color _getColorFromString(String str) {
    if (str.isEmpty) return primaryColor;

    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }

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

  Widget _buildResultsList(
    BuildContext context,
    List<Map<String, dynamic>> results,
  ) {
    if (results.isEmpty && query.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No books found',
              style: bodyLarge.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: bodyMedium.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty && query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for books',
              style: bodyLarge.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a book title or author name',
              style: bodyMedium.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 24,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return GestureDetector(
          onTap: () {
            if (onBookTap != null) {
              onBookTap!(book);
            }
            close(context, book);
          },
          child: BookCard(
            title: book['title']?.toString() ?? 'Untitled',
            progress: _getProgress(book),
            coverColor: _getCoverColor(book),
          ),
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: bodyMedium.copyWith(color: blackColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
