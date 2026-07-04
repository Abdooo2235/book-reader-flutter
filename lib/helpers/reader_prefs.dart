import 'dart:convert';

import 'package:book_reader_app/helpers/reading_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single highlight: a rectangle on a page, stored in page-fraction
/// coordinates (0..1, top-left origin) so it survives zoom/resize, plus an
/// index into [highlightColors].
@immutable
class Highlight {
  const Highlight({
    required this.page,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.colorIndex,
  });

  final int page;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final int colorIndex;

  Map<String, dynamic> toJson() => {
    'p': page,
    'l': left,
    't': top,
    'r': right,
    'b': bottom,
    'c': colorIndex,
  };

  factory Highlight.fromJson(Map<String, dynamic> json) => Highlight(
    page: json['p'] as int,
    left: (json['l'] as num).toDouble(),
    top: (json['t'] as num).toDouble(),
    right: (json['r'] as num).toDouble(),
    bottom: (json['b'] as num).toDouble(),
    colorIndex: json['c'] as int,
  );
}

/// Local persistence for reader settings, bookmarks, and highlights.
/// Purely additive app data (shared_preferences) — never touches the PDF file
/// or the server-side reading progress.
class ReaderPrefs {
  const ReaderPrefs._();

  static const _themeKey = 'reader_theme';
  static String _bookmarksKey(int bookId) => 'bookmarks_$bookId';
  static String _highlightsKey(int bookId) => 'highlights_$bookId';

  static Future<ReadingTheme> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey) ?? ReadingTheme.white.index;
    return ReadingTheme.values[index.clamp(0, ReadingTheme.values.length - 1)];
  }

  static Future<void> saveTheme(ReadingTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }

  static Future<List<int>> loadBookmarks(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey(bookId)) ?? const [];
    return raw.map(int.parse).toList()..sort();
  }

  static Future<void> saveBookmarks(int bookId, List<int> pages) async {
    final prefs = await SharedPreferences.getInstance();
    final unique = pages.toSet().toList()..sort();
    await prefs.setStringList(
      _bookmarksKey(bookId),
      unique.map((p) => p.toString()).toList(),
    );
  }

  static Future<List<Highlight>> loadHighlights(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_highlightsKey(bookId));
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Highlight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveHighlights(
    int bookId,
    List<Highlight> highlights,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(highlights.map((h) => h.toJson()).toList());
    await prefs.setString(_highlightsKey(bookId), encoded);
  }
}
