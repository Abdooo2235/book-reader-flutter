import 'package:book_reader_app/helpers/consts.dart';
import 'package:flutter/material.dart';

/// Single source for book-cover visuals. Previously the hash-to-color logic and
/// the cover-URL fallback chain were duplicated across `books_grid`,
/// `search_delegate`, and `book_details_screen`.
class CoverUtils {
  const CoverUtils._();

  /// Deterministic fallback color for a book without a cover image, derived
  /// from a string (usually the title) so the same book always looks the same.
  static Color colorFor(String? source) {
    final str = source ?? '';
    if (str.isEmpty) return primaryColor;

    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return coverPalette[hash.abs() % coverPalette.length];
  }

  /// Resolves a cover image URL from the raw book map, trying the known
  /// backend keys in order. Relative storage paths are absolutized against the
  /// backend host (derived from [baseUrl]) so `Image.network` can load them.
  /// Returns null when no cover key is present.
  static String? resolveUrl(Map<String, dynamic> book) {
    final url =
        book['cover_url']?.toString() ??
        book['cover_image']?.toString() ??
        book['cover_thumb_url']?.toString();
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final origin = Uri.parse(baseUrl).origin;
    return url.startsWith('/') ? '$origin$url' : '$origin/$url';
  }
}
