import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Generate color from title if not present
    Color coverColor = primaryColor;
    if (book['color'] != null && book['color'] is Color) {
      coverColor = book['color'];
    } else if (book['cover_color'] != null && book['cover_color'] is Color) {
      coverColor = book['cover_color'];
    }

    final title = book['title']?.toString() ?? 'Untitled';
    final author = book['author']?.toString() ?? 'Unknown Author';
    final pages = book['pages']?.toString() ?? 'Unknown';
    final format = book['format']?.toString() ?? 'E-Book';
    final description =
        book['description']?.toString() ??
        'No description available for this book.';

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Favorites icon
          Consumer<BookProvider>(
            builder: (context, bookProvider, child) {
              final isFav = bookProvider.isFavorite(book);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black87,
                ),
                onPressed: () {
                  bookProvider.toggleFavorite(book);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered Book Cover
            Center(
              child: Container(
                width: 160,
                height: 240,
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.book, // Placeholder icon if no image
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title and Author
            Text(title, style: displayMedium.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text(author, style: bodyMedium.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 24),

            // Metadata Badges (Pages, Format)
            Row(
              children: [
                _buildBadge(Icons.menu_book, '$pages pages'),
                const SizedBox(width: 12),
                _buildBadge(Icons.description, format),
              ],
            ),
            const SizedBox(height: 32),

            // Description
            Text('Description', style: labelLarge),
            const SizedBox(height: 12),
            Text(
              description,
              style: bodyMedium.copyWith(color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add to cart functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.cart, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Cart',
                      style: bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Download/Read functionality
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download, color: Color(0xff8B6F47)),
                    const SizedBox(width: 8),
                    Text(
                      'Download & Read',
                      style: bodyMedium.copyWith(
                        color: const Color(0xff8B6F47),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffF5EFE6), // Light beige background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 6),
          Text(text, style: labelSmall.copyWith(color: Colors.black87)),
        ],
      ),
    );
  }
}
