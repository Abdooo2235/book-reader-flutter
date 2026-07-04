import 'dart:io';
import 'dart:math' as math;

import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/reader_prefs.dart';
import 'package:book_reader_app/helpers/reading_theme.dart';
import 'package:book_reader_app/helpers/ui_utils.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/providers/progress_provider.dart';
import 'package:book_reader_app/theme/app_colors.dart';
import 'package:book_reader_app/widgets/common/app_button.dart';
import 'package:book_reader_app/widgets/download_progress_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:provider/provider.dart';

/// PDF reader built on the free, MIT-licensed `pdfrx` engine (replaced the
/// paid Syncfusion viewer). The download / cache / progress / mark-as-read
/// logic is unchanged; reading themes, zoom, bookmarks and highlights are
/// additive and persisted locally via [ReaderPrefs].
class BookReaderScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final PdfViewerController _controller = PdfViewerController();
  PdfDocument? _document;

  bool _isLoading = true;
  String? _error;
  String? _filePath;
  int _currentPage = 1;
  int _totalPages = 0;
  int _resumePage = 1;
  bool _isControlsVisible = true;
  bool _isMarkingAsRead = false;
  bool _hasSelection = false;

  // Reader settings + annotations (local, additive).
  ReadingTheme _readingTheme = ReadingTheme.white;
  List<int> _bookmarks = [];
  List<Highlight> _highlights = [];
  int _highlightColorIndex = 0;

  // Download progress.
  final ValueNotifier<double> _downloadProgress = ValueNotifier(0.0);
  CancelToken? _cancelToken;

  int get _bookId => widget.book['id'] as int;

  @override
  void initState() {
    super.initState();
    _restoreSettings();
    _loadBook();
  }

  Future<void> _restoreSettings() async {
    final theme = await ReaderPrefs.loadTheme();
    final bookmarks = await ReaderPrefs.loadBookmarks(_bookId);
    final highlights = await ReaderPrefs.loadHighlights(_bookId);
    if (!mounted) return;
    setState(() {
      _readingTheme = theme;
      _bookmarks = bookmarks;
      _highlights = highlights;
    });
  }

  // --------------------------------------------------------------------------
  // Load + download (unchanged behavior)
  // --------------------------------------------------------------------------

  Future<void> _loadBook() async {
    try {
      final bookId = _bookId;

      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      final libraryProvider = Provider.of<LibraryProvider>(
        context,
        listen: false,
      );

      if (libraryProvider.collections.isEmpty) {
        await libraryProvider.loadCollections();
      }

      await progressProvider.loadBookProgress(bookId);
      final lastPage = progressProvider.getLastPage(bookId) ?? 1;

      if (lastPage <= 1) {
        try {
          await libraryProvider.markAsReading(bookId);
        } catch (e) {
          debugPrint('Failed to mark as reading: $e');
        }
      }

      // Prefer the backend proxy (GET /library/{id}/download → /api/books/{id}/stream):
      // it fetches the file server-side with a proper User-Agent + SSL, so it
      // works for uploaded files and rescues external links that a direct
      // mobile fetch can't reach. A URL embedded in the book map (often a dead
      // seed link) is only a fallback.
      String? downloadUrl;
      String? fileType = widget.book['file_type']?.toString() ?? 'pdf';

      try {
        final downloadResponse = await libraryProvider.downloadBook(bookId);
        if (downloadResponse != null) {
          downloadUrl =
              downloadResponse['file_url']?.toString() ??
              downloadResponse['data']?['file_url']?.toString() ??
              downloadResponse['download_url']?.toString() ??
              downloadResponse['book_file_url']?.toString() ??
              downloadResponse['data']?['book_file_url']?.toString();
          fileType =
              downloadResponse['file_type']?.toString() ??
              downloadResponse['data']?['file_type']?.toString() ??
              fileType;
        }
      } catch (e) {
        debugPrint('Download API error: $e');
      }

      if (downloadUrl == null || downloadUrl.isEmpty) {
        downloadUrl =
            widget.book['book_file_url']?.toString() ??
            widget.book['file_url']?.toString() ??
            widget.book['download_url']?.toString();
      }

      if (downloadUrl == null || downloadUrl.isEmpty) {
        downloadUrl =
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
        debugPrint('Using fallback sample PDF');
      }

      if (!downloadUrl.startsWith('http://') &&
          !downloadUrl.startsWith('https://')) {
        final origin = Uri.parse(baseUrl).origin;
        downloadUrl = downloadUrl.startsWith('/')
            ? '$origin$downloadUrl'
            : '$origin/$downloadUrl';
      }

      final filePath = await _downloadFile(
        downloadUrl,
        bookId,
        fileType ?? 'pdf',
      );

      if ((fileType ?? 'pdf').toLowerCase() == 'epub') {
        setState(() {
          _error =
              'EPUB support is coming soon. Currently only PDF files are supported.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _filePath = filePath;
        _resumePage = lastPage > 0 ? lastPage : 1;
        _currentPage = _resumePage;
        _isLoading = false;
      });
    } catch (e) {
      // Keep the raw cause in logs, but show the user a clean message rather
      // than a raw DioException (a 404/502 means the file source is down).
      debugPrint('Reader load error: $e');
      setState(() {
        _error =
            "This book's file is currently unavailable. Please try again later or pick another book.";
        _isLoading = false;
      });
    }
  }

  Future<String> _downloadFile(String url, int bookId, String fileType) async {
    final appDir = await getApplicationDocumentsDirectory();
    final extension = fileType.toLowerCase() == 'epub' ? 'epub' : 'pdf';
    final filePath = '${appDir.path}/book_$bookId.$extension';
    final file = File(filePath);

    if (file.existsSync()) {
      return filePath;
    }

    _cancelToken = CancelToken();

    if (mounted) {
      showDownloadProgressDialog(
        context: context,
        bookTitle: widget.book['title']?.toString() ?? 'Book',
        progressNotifier: _downloadProgress,
        onCancel: () {
          _cancelToken?.cancel('User cancelled download');
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    }

    try {
      final dio = Dio();
      await dio.download(
        url,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) _downloadProgress.value = received / total;
        },
      );
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      return filePath;
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      throw Exception('Failed to download book: ${e.toString()}');
    }
  }

  // --------------------------------------------------------------------------
  // Viewer callbacks
  // --------------------------------------------------------------------------

  // pdfrx fires onViewerReady during the viewer's first layout, so defer any
  // setState / navigation to the next frame to avoid "setState during build".
  void _onViewerReady(PdfDocument document, PdfViewerController controller) {
    _document = document;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _totalPages = controller.pageCount);
      if (_resumePage > 1) controller.goToPage(pageNumber: _resumePage);
    });
  }

  /// Total pages from the book metadata (which may be a numeric String), or the
  /// rendered count as a fallback.
  int get _bookTotalPages {
    final raw = widget.book['number_of_pages'];
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? _totalPages;
    return _totalPages;
  }

  void _onPageChanged(int? pageNumber) {
    if (pageNumber == null) return;
    setState(() {
      _currentPage = pageNumber;
      if (_document != null) _totalPages = _document!.pages.length;
    });
    _saveProgress();
    if (_currentPage >= _totalPages && _totalPages > 0) {
      setState(() => _isControlsVisible = true);
    }
  }

  void _onTextSelectionChange(PdfTextSelection selection) {
    if (selection.hasSelectedText != _hasSelection) {
      setState(() => _hasSelection = selection.hasSelectedText);
    }
  }

  Future<void> _saveProgress() async {
    if (_currentPage == 0) return;
    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );
    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    try {
      await progressProvider.updateProgress(
        bookId: _bookId,
        lastPage: _currentPage,
        totalPages: _bookTotalPages,
      );
      final progress = progressProvider.getProgressPercentage(_bookId) ?? 0.0;
      if (progress >= 100.0) {
        try {
          await libraryProvider.markAsCompleted(_bookId);
        } catch (e) {
          debugPrint('Failed to mark as completed: $e');
        }
      }
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }

  Future<void> _markAsReadAndClose() async {
    if (_isMarkingAsRead) return;
    setState(() => _isMarkingAsRead = true);
    try {
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      final libraryProvider = Provider.of<LibraryProvider>(
        context,
        listen: false,
      );
      final target = _bookTotalPages > 0 ? _bookTotalPages : _totalPages;

      await progressProvider.updateProgress(
        bookId: _bookId,
        lastPage: target,
        totalPages: target,
      );
      await libraryProvider.markAsCompleted(_bookId);

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, 'Book marked as read!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMarkingAsRead = false);
        UiUtils.showErrorSnackBar(context, 'Failed to mark as read: $e');
      }
    }
  }

  // --------------------------------------------------------------------------
  // Bookmarks + highlights
  // --------------------------------------------------------------------------

  bool get _isCurrentBookmarked => _bookmarks.contains(_currentPage);

  Future<void> _toggleBookmark() async {
    setState(() {
      if (_isCurrentBookmarked) {
        _bookmarks.remove(_currentPage);
      } else {
        _bookmarks.add(_currentPage);
        _bookmarks.sort();
      }
    });
    await ReaderPrefs.saveBookmarks(_bookId, _bookmarks);
    if (mounted) {
      UiUtils.showInfoSnackBar(
        context,
        _isCurrentBookmarked
            ? 'Bookmarked page $_currentPage'
            : 'Removed bookmark',
      );
    }
  }

  /// Commits the current text selection to a highlight, storing page-fraction
  /// rectangles so it repaints correctly at any zoom.
  Future<void> _addHighlight() async {
    final document = _document;
    if (document == null) return;
    try {
      final ranges = await _controller.textSelectionDelegate
          .getSelectedTextRanges();
      final newHighlights = <Highlight>[];

      for (final range in ranges) {
        final page = document.pages[range.pageNumber - 1];
        final charRects = range.pageText.charRects;
        final start = range.start.clamp(0, charRects.length);
        final end = range.end.clamp(0, charRects.length);
        if (start >= end) continue;

        for (final line in _mergeLines(charRects.sublist(start, end))) {
          newHighlights.add(
            Highlight(
              page: range.pageNumber,
              left: line.left / page.width,
              top: (page.height - line.top) / page.height,
              right: line.right / page.width,
              bottom: (page.height - line.bottom) / page.height,
              colorIndex: _highlightColorIndex,
            ),
          );
        }
      }

      if (newHighlights.isEmpty) return;
      setState(() => _highlights = [..._highlights, ...newHighlights]);
      await ReaderPrefs.saveHighlights(_bookId, _highlights);
      await _controller.textSelectionDelegate.clearTextSelection();
      _controller.invalidate();
      if (mounted) UiUtils.showSuccessSnackBar(context, 'Highlight added');
    } catch (e) {
      debugPrint('Failed to add highlight: $e');
    }
  }

  /// Merges per-character rects into per-line rects (chars sharing a line are
  /// unioned) so highlights paint as continuous bars, not a grid of boxes.
  List<PdfRect> _mergeLines(List<PdfRect> rects) {
    final lines = <PdfRect>[];
    for (final r in rects) {
      if (r.isEmpty) continue;
      if (lines.isNotEmpty) {
        final last = lines.last;
        final vOverlap =
            math.min(last.top, r.top) - math.max(last.bottom, r.bottom);
        final minHeight = math.min(last.height, r.height);
        if (minHeight > 0 && vOverlap > minHeight * 0.4) {
          lines[lines.length - 1] = last.merge(r);
          continue;
        }
      }
      lines.add(r);
    }
    return lines;
  }

  void _paintHighlights(Canvas canvas, Rect pageRect, PdfPage page) {
    for (final h in _highlights) {
      if (h.page != page.pageNumber) continue;
      final rect = Rect.fromLTRB(
        pageRect.left + h.left * pageRect.width,
        pageRect.top + h.top * pageRect.height,
        pageRect.left + h.right * pageRect.width,
        pageRect.top + h.bottom * pageRect.height,
      );
      final paint = Paint()
        ..color =
            highlightColors[h.colorIndex.clamp(0, highlightColors.length - 1)]
                .withValues(alpha: 0.35);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  Future<void> _setReadingTheme(ReadingTheme theme) async {
    setState(() => _readingTheme = theme);
    await ReaderPrefs.saveTheme(theme);
  }

  void _toggleControls() =>
      setState(() => _isControlsVisible = !_isControlsVisible);

  @override
  void dispose() {
    _saveProgress();
    _downloadProgress.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // UI
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final chromeVisible = _isControlsVisible && !_isLoading && _error == null;

    return Scaffold(
      backgroundColor: _readingTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isLoading)
              _buildLoading()
            else if (_error != null)
              _buildError()
            else if (_filePath != null)
              _buildViewer(),

            _buildTopBar(chromeVisible),
            _buildBottomBar(chromeVisible),
            _buildHighlightToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: spacingMedium),
          Text(
            'Loading book...',
            style: bodyMedium.copyWith(color: colors.onSurface),
          ),
        ],
      ),
    );
  }

  void _retryLoad() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadBook();
  }

  Widget _buildError() {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: colors.danger),
            const SizedBox(height: spacingMedium),
            Text(
              _error!,
              style: bodyMedium.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: spacingLarge),
            PrimaryButton(
              label: 'Try Again',
              icon: Icons.refresh,
              expand: false,
              onPressed: _retryLoad,
            ),
            const SizedBox(height: spacingSmall),
            SecondaryButton(
              label: 'Go Back',
              expand: false,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewer() {
    final viewer = PdfViewer.file(
      _filePath!,
      controller: _controller,
      params: PdfViewerParams(
        backgroundColor: _readingTheme.background,
        onViewerReady: _onViewerReady,
        onPageChanged: _onPageChanged,
        textSelectionParams: PdfTextSelectionParams(
          onTextSelectionChange: _onTextSelectionChange,
        ),
        pagePaintCallbacks: [_paintHighlights],
      ),
    );

    final filter = _readingTheme.filter;
    final themed = filter == null
        ? viewer
        : ColorFiltered(colorFilter: filter, child: viewer);

    return GestureDetector(onTap: _toggleControls, child: themed);
  }

  Widget _buildTopBar(bool visible) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: _AnimatedChrome(
        visible: visible,
        fromTop: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: spacingSmall),
          decoration: BoxDecoration(
            color: _readingTheme.background,
            border: Border(
              bottom: BorderSide(
                color: _readingTheme.onBackground.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: _readingTheme.onBackground),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.book['title']?.toString() ?? 'Book',
                  style: labelSmall.copyWith(color: _readingTheme.onBackground),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isCurrentBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _readingTheme.onBackground,
                ),
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: Icon(Icons.tune, color: _readingTheme.onBackground),
                onPressed: _openSettingsSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool visible) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: _AnimatedChrome(
        visible: visible,
        fromTop: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            spacingLarge,
            spacingSmall,
            spacingLarge,
            spacingMedium,
          ),
          decoration: BoxDecoration(
            color: _readingTheme.background,
            border: Border(
              top: BorderSide(
                color: _readingTheme.onBackground.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_totalPages > 0 && _currentPage >= _totalPages)
                Padding(
                  padding: const EdgeInsets.only(bottom: spacingMedium),
                  child: PrimaryButton(
                    label: _isMarkingAsRead
                        ? 'Marking as read...'
                        : 'Mark as Read',
                    icon: Icons.check_circle,
                    busy: _isMarkingAsRead,
                    color: greenColor,
                    onPressed: _isMarkingAsRead ? null : _markAsReadAndClose,
                  ),
                ),
              _buildProgressFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact reading footer: a slim progress track with a dot, and a
  /// Prev / "N of M" / Next row (inspired by image4).
  Widget _buildProgressFooter() {
    final fg = _readingTheme.onBackground;
    final fraction = _totalPages > 0
        ? (_currentPage / _totalPages).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return SizedBox(
              height: 12,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Container(
                    height: 2,
                    width: width * fraction,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Positioned(
                    left: (width * fraction - 5).clamp(0.0, width - 10),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: spacingSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _footerAction(
              'Prev',
              _currentPage > 1
                  ? () => _controller.goToPage(pageNumber: _currentPage - 1)
                  : null,
            ),
            Text(
              '$_currentPage of $_totalPages',
              style: labelSmall.copyWith(color: fg),
            ),
            _footerAction(
              'Next',
              _currentPage < _totalPages
                  ? () => _controller.goToPage(pageNumber: _currentPage + 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _footerAction(String label, VoidCallback? onTap) {
    final fg = _readingTheme.onBackground;
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: bodySmall.copyWith(
          color: onTap == null
              ? fg.withValues(alpha: 0.3)
              : fg.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  /// Floating text-selection toolbar (inspired by image2): a dark pill of
  /// highlight-color dots. Tapping a color highlights the current selection.
  Widget _buildHighlightToolbar() {
    if (!_hasSelection) return const SizedBox.shrink();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 120,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacingSmall,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(borderRadiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < highlightColors.length; i++)
                GestureDetector(
                  onTap: () {
                    _highlightColorIndex = i;
                    _addHighlight();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: highlightColors[i],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Settings sheet (reading theme + zoom + highlight color + bookmarks)
  // --------------------------------------------------------------------------

  void _openSettingsSheet() {
    final colors = AppColors.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadiusLarge),
        ),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> pick(ReadingTheme theme) async {
            await _setReadingTheme(theme);
            setSheetState(() {});
          }

          return Padding(
            padding: const EdgeInsets.all(spacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading theme',
                  style: labelSmall.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: spacingSmall),
                Row(
                  children: [
                    for (final theme in ReadingTheme.values)
                      Padding(
                        padding: const EdgeInsets.only(right: spacingSmall),
                        child: _ThemeSwatch(
                          theme: theme,
                          selected: theme == _readingTheme,
                          onTap: () => pick(theme),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: spacingLarge),
                Text(
                  'Zoom',
                  style: labelSmall.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: spacingSmall),
                Row(
                  children: [
                    _roundIcon(
                      Icons.text_decrease,
                      () => _controller.zoomDown(),
                    ),
                    const SizedBox(width: spacingMedium),
                    _roundIcon(Icons.text_increase, () => _controller.zoomUp()),
                  ],
                ),
                const SizedBox(height: spacingLarge),
                Text(
                  'Highlight color',
                  style: labelSmall.copyWith(color: colors.onSurface),
                ),
                const SizedBox(height: spacingSmall),
                Row(
                  children: [
                    for (var i = 0; i < highlightColors.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: spacingSmall),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _highlightColorIndex = i);
                            setSheetState(() {});
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: highlightColors[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _highlightColorIndex == i
                                    ? colors.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_bookmarks.isNotEmpty) ...[
                  const SizedBox(height: spacingLarge),
                  Text(
                    'Bookmarks',
                    style: labelSmall.copyWith(color: colors.onSurface),
                  ),
                  const SizedBox(height: spacingSmall),
                  Wrap(
                    spacing: spacingSmall,
                    runSpacing: spacingSmall,
                    children: [
                      for (final page in _bookmarks)
                        ActionChip(
                          label: Text('p.$page'),
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _controller.goToPage(pageNumber: page);
                          },
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(spacingMedium),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        child: Icon(icon, color: colors.primary),
      ),
    );
  }
}

/// Slides + fades the reader chrome in/out. Honors reduced-motion (skips the
/// slide, keeps the fade) and blocks input while hidden.
class _AnimatedChrome extends StatelessWidget {
  const _AnimatedChrome({
    required this.visible,
    required this.fromTop,
    required this.child,
  });

  final bool visible;
  final bool fromTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final hiddenOffset = fromTop ? const Offset(0, -1) : const Offset(0, 1);
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: (visible || reduceMotion) ? Offset.zero : hiddenOffset,
        duration: animationDurationMedium,
        curve: easeOutStrong,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: animationDurationMedium,
          child: child,
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final ReadingTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.swatch,
              borderRadius: BorderRadius.circular(borderRadiusMedium),
              border: Border.all(
                color: selected ? colors.primary : colors.border,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Icon(
              theme.icon,
              size: 20,
              color: theme == ReadingTheme.night || theme == ReadingTheme.grey
                  ? Colors.white
                  : blackColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            theme.label,
            style: bodySmall.copyWith(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }
}
