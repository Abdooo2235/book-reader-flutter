import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/book_provider.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/screens/main/book_reader_screen.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? scaffoldBackgroundColorDark
        : scaffoldBackgroundColor;
    final textColor = isDark ? whiteColorDark : blackColor;
    final secondaryTextColor = isDark
        ? whiteColorDark.withValues(alpha: 0.6)
        : Colors.grey[600];
    final accentColor = isDark ? primaryColorDark : primaryColor;
    final iconColor = isDark ? whiteColorDark : Colors.black87;

    // Generate color from title if not present
    Color coverColor = accentColor;
    if (widget.book['color'] != null && widget.book['color'] is Color) {
      coverColor = widget.book['color'];
    } else if (widget.book['cover_color'] != null &&
        widget.book['cover_color'] is Color) {
      coverColor = widget.book['cover_color'];
    } else {
      // Generate color from title
      final title = widget.book['title']?.toString() ?? '';
      if (title.isNotEmpty) {
        int hash = 0;
        for (int i = 0; i < title.length; i++) {
          hash = title.codeUnitAt(i) + ((hash << 5) - hash);
        }
        final colors = [
          const Color(0xff7A4A2E),
          const Color(0xffB5533C),
          const Color(0xff6B8E4E),
          const Color(0xff4A7C8E),
          const Color(0xff8B6F47),
        ];
        coverColor = colors[hash.abs() % colors.length];
      }
    }

    // Extract cover URL
    String? coverUrl = widget.book['cover_url']?.toString();
    coverUrl ??= widget.book['cover_image']?.toString();
    coverUrl ??= widget.book['cover_thumb_url']?.toString();

    final title = widget.book['title']?.toString() ?? 'Untitled';
    final author = widget.book['author']?.toString() ?? 'Unknown Author';
    final pages =
        widget.book['number_of_pages']?.toString() ??
        widget.book['pages']?.toString() ??
        'Unknown';
    final format =
        widget.book['file_type']?.toString() ??
        widget.book['format']?.toString() ??
        'E-Book';
    final description =
        widget.book['description']?.toString() ??
        'No description available for this book.';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Favorites icon
          Consumer<BookProvider>(
            builder: (context, bookProvider, child) {
              final isFav = bookProvider.isFavorite(widget.book);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav
                      ? (isDark ? redColorDark : Colors.red)
                      : iconColor,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await bookProvider.toggleFavorite(widget.book);
                  } catch (e) {
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to update favorite: ${e.toString()}',
                            style: bodyMedium.copyWith(color: Colors.white),
                          ),
                          backgroundColor: redColor,
                        ),
                      );
                    }
                  }
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
            // Centered Book Cover with Image
            Center(
              child: Container(
                width: 160,
                height: 240,
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: coverUrl != null && coverUrl.isNotEmpty
                    ? Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        width: 160,
                        height: 240,
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
                          return Center(
                            child: Icon(
                              Icons.book,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.book,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Title and Author
            Text(
              title,
              style: displayMedium.copyWith(fontSize: 24, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(author, style: bodyMedium.copyWith(color: secondaryTextColor)),
            const SizedBox(height: 24),

            // Metadata Badges (Pages, Format)
            Row(
              children: [
                _buildBadge(context, Icons.menu_book, '$pages pages'),
                const SizedBox(width: 12),
                _buildBadge(context, Icons.description, format.toUpperCase()),
              ],
            ),
            const SizedBox(height: 32),

            // Description
            Text('Description', style: labelLarge.copyWith(color: textColor)),
            const SizedBox(height: 12),
            Text(
              description,
              style: bodyMedium.copyWith(
                color: secondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isDownloading ? null : _downloadAndRead,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: accentColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isDownloading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accentColor,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, color: accentColor),
                          const SizedBox(width: 8),
                          Text(
                            'Download & Read',
                            style: bodyMedium.copyWith(
                              color: accentColor,
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

  Future<void> _downloadAndRead() async {
    final bookId = widget.book['id'];
    if (bookId == null) {
      _showSnackBar('Unable to download book', isError: true);
      return;
    }

    setState(() => _isDownloading = true);

    try {
      // Mark as reading in library
      final libraryProvider = Provider.of<LibraryProvider>(
        context,
        listen: false,
      );
      await libraryProvider.markAsReading(bookId);

      if (mounted) {
        // Navigate to book reader
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookReaderScreen(book: widget.book),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Failed to start reading: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? (isDark ? redColorDark : redColor)
            : (isDark ? greenColorDark : greenColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBackground = isDark ? surfaceColorDark : const Color(0xffF5EFE6);
    final textColor = isDark ? whiteColorDark : Colors.black87;
    final accentColor = isDark ? primaryColorDark : primaryColor;
    final borderColor = isDark
        ? whiteColorDark.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(text, style: labelSmall.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
