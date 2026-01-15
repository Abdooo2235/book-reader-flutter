import 'dart:io';
import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/providers/progress_provider.dart';
import 'package:book_reader_app/widgets/download_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class BookReaderScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  PdfViewerController? _pdfController;
  bool _isLoading = true;
  String? _error;
  String? _filePath;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isControlsVisible = true;
  bool _isMarkingAsRead = false;

  // Download progress
  final ValueNotifier<double> _downloadProgress = ValueNotifier(0.0);
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final bookId = widget.book['id'];

      // Load progress to resume from last page
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      final libraryProvider = Provider.of<LibraryProvider>(
        context,
        listen: false,
      );

      // Ensure collections are loaded
      if (libraryProvider.collections.isEmpty) {
        await libraryProvider.loadCollections();
      }

      await progressProvider.loadBookProgress(bookId);
      final lastPage = progressProvider.getLastPage(bookId) ?? 1;

      // Mark book as reading if not already marked
      if (lastPage <= 1) {
        try {
          await libraryProvider.markAsReading(bookId);
        } catch (e) {
          debugPrint('Failed to mark as reading: $e');
        }
      }

      // Get download URL - first try from the book object itself
      String? downloadUrl =
          widget.book['book_file_url']?.toString() ??
          widget.book['file_url']?.toString() ??
          widget.book['download_url']?.toString();

      String? fileType = widget.book['file_type']?.toString() ?? 'pdf';

      // If not in book object, try to get from API
      if (downloadUrl == null || downloadUrl.isEmpty) {
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
      }

      // Final fallback - sample PDF for testing
      if (downloadUrl == null || downloadUrl.isEmpty) {
        downloadUrl =
            'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
        debugPrint('Using fallback sample PDF');
      }

      if (downloadUrl.isEmpty) {
        setState(() {
          _error = 'Book file not available. Please try again later.';
          _isLoading = false;
        });
        return;
      }

      // Ensure URL is complete
      if (!downloadUrl.startsWith('http://') &&
          !downloadUrl.startsWith('https://')) {
        const baseUrl = 'https://book-reader-store-backend.onrender.com';
        downloadUrl = downloadUrl.startsWith('/')
            ? '$baseUrl$downloadUrl'
            : '$baseUrl/$downloadUrl';
      }

      // Download the file with progress indicator
      final filePath = await _downloadFile(
        downloadUrl,
        bookId,
        fileType ?? 'pdf',
      );

      // Check file type
      final fileTypeLower = (fileType ?? 'pdf').toLowerCase();

      if (fileTypeLower == 'epub') {
        setState(() {
          _error =
              'EPUB support is coming soon. Currently only PDF files are supported.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _filePath = filePath;
        _currentPage = lastPage > 0 ? lastPage : 1;
        _isLoading = false;
      });

      // Jump to last page after widget builds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pdfController != null && lastPage > 1) {
          _pdfController!.jumpToPage(lastPage);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load book: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<String> _downloadFile(String url, int bookId, String fileType) async {
    final appDir = await getApplicationDocumentsDirectory();
    final extension = fileType.toLowerCase() == 'epub' ? 'epub' : 'pdf';
    final filePath = '${appDir.path}/book_$bookId.$extension';
    final file = File(filePath);

    // Return cached file if exists
    if (file.existsSync()) {
      return filePath;
    }

    // Show download progress dialog
    _cancelToken = CancelToken();

    if (mounted) {
      showDownloadProgressDialog(
        context: context,
        bookTitle: widget.book['title']?.toString() ?? 'Book',
        progressNotifier: _downloadProgress,
        onCancel: () {
          _cancelToken?.cancel('User cancelled download');
          Navigator.pop(context);
          Navigator.pop(context); // Go back to previous screen
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
          if (total > 0) {
            _downloadProgress.value = received / total;
          }
        },
      );

      // Close download dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      return filePath;
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      throw Exception('Failed to download book: ${e.toString()}');
    }
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber;
      _totalPages = _pdfController?.pageCount ?? 0;
    });
    _saveProgress();
    
    // Show controls when reaching last page to display Done button
    if (_currentPage >= _totalPages && _totalPages > 0) {
      setState(() {
        _isControlsVisible = true;
      });
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
    });
  }

  Future<void> _saveProgress() async {
    if (_pdfController == null || _currentPage == 0) return;

    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );
    final libraryProvider = Provider.of<LibraryProvider>(
      context,
      listen: false,
    );
    final bookId = widget.book['id'];
    final totalPages = widget.book['number_of_pages'] ?? _totalPages;

    try {
      await progressProvider.updateProgress(
        bookId: bookId,
        lastPage: _currentPage,
        totalPages: totalPages,
      );

      // Check if book is completed
      final progress = progressProvider.getProgressPercentage(bookId) ?? 0.0;
      if (progress >= 100.0) {
        try {
          await libraryProvider.markAsCompleted(bookId);
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

    setState(() {
      _isMarkingAsRead = true;
    });

    try {
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      final libraryProvider = Provider.of<LibraryProvider>(
        context,
        listen: false,
      );
      final bookId = widget.book['id'];
      final totalPages = widget.book['number_of_pages'] ?? _totalPages;

      // Update progress to 100%
      await progressProvider.updateProgress(
        bookId: bookId,
        lastPage: totalPages > 0 ? totalPages : _totalPages,
        totalPages: totalPages > 0 ? totalPages : _totalPages,
      );

      // Mark as completed
      await libraryProvider.markAsCompleted(bookId);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Book marked as read!',
                    style: bodyMedium.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: greenColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMarkingAsRead = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to mark as read: ${e.toString()}',
              style: bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: redColor,
          ),
        );
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  void _goToPage(int page) {
    _pdfController?.jumpToPage(page);
  }

  @override
  void dispose() {
    _saveProgress();
    _pdfController?.dispose();
    _downloadProgress.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? scaffoldBackgroundColorDark
        : Colors.grey[200];
    final controlsBackground = isDark
        ? Colors.black.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // PDF Viewer
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      'Loading book...',
                      style: bodyMedium.copyWith(
                        color: isDark ? whiteColorDark : blackColor,
                      ),
                    ),
                  ],
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: redColor),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: bodyMedium.copyWith(
                          color: isDark ? whiteColorDark : blackColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filePath != null)
              GestureDetector(
                onTap: _toggleControls,
                child: SfPdfViewer.file(
                  File(_filePath!),
                  controller: _pdfController,
                  onPageChanged: _onPageChanged,
                  onDocumentLoaded: _onDocumentLoaded,
                  enableTextSelection: true,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  pageSpacing: 4,
                ),
              ),

            // Controls Overlay - Bottom
            if (!_isLoading && _error == null && _isControlsVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: controlsBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Done button - Show when on last page
                      if (_totalPages > 0 && _currentPage >= _totalPages)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ElevatedButton.icon(
                            onPressed: _isMarkingAsRead ? null : _markAsReadAndClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isMarkingAsRead
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check_circle, size: 24),
                            label: Text(
                              _isMarkingAsRead
                                  ? 'Marking as read...'
                                  : 'Done - Mark as Read',
                              style: labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                            onPressed: _currentPage > 1
                                ? () => _goToPage(_currentPage - 1)
                                : null,
                          ),
                          Text(
                            'Page $_currentPage / $_totalPages',
                            style: bodyMedium.copyWith(color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            onPressed: _currentPage < _totalPages
                                ? () => _goToPage(_currentPage + 1)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress slider
                      if (_totalPages > 1)
                        Slider(
                          value: _currentPage.toDouble().clamp(
                            1,
                            _totalPages.toDouble(),
                          ),
                          min: 1,
                          max: _totalPages.toDouble(),
                          divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                          activeColor: primaryColor,
                          inactiveColor: primaryColor.withValues(alpha: 0.3),
                          onChanged: (value) {
                            _goToPage(value.toInt());
                          },
                        ),
                    ],
                  ),
                ),
              ),

            // Top App Bar
            if (!_isLoading && _error == null && _isControlsVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: controlsBackground,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.book['title']?.toString() ?? 'Book',
                          style: bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Search button
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement search
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Search feature coming soon',
                                style: bodyMedium.copyWith(color: Colors.white),
                              ),
                              backgroundColor: primaryColor,
                            ),
                          );
                        },
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
}
