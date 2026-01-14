import 'dart:io';
import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/providers/library_provider.dart';
import 'package:book_reader_app/providers/progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
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
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isControlsVisible = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    try {
      final bookId = widget.book['id'];
      
      // Load progress to resume from last page
      final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
      final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
      
      // Ensure collections are loaded
      if (libraryProvider.collections.isEmpty) {
        await libraryProvider.loadCollections();
      }
      
      await progressProvider.loadBookProgress(bookId);
      final lastPage = progressProvider.getLastPage(bookId) ?? 0;
      
      // Mark book as reading if not already marked
      if (lastPage == 0) {
        try {
          await libraryProvider.markAsReading(bookId);
        } catch (e) {
          // Silently fail - not critical
          debugPrint('Failed to mark as reading: $e');
        }
      }

      // Get download URL from API response
      String? downloadUrl;
      String? fileType;
      
      // Try to get download URL from downloadBook API response
      try {
        final downloadResponse = await libraryProvider.downloadBook(bookId);
        
        if (downloadResponse != null) {
          debugPrint('Download response: $downloadResponse');
          
          // API returns file_url in data (check nested structure)
          downloadUrl = downloadResponse['file_url']?.toString() ??
              downloadResponse['data']?['file_url']?.toString() ??
              downloadResponse['download_url']?.toString() ??
              downloadResponse['book_file']?.toString() ??
              downloadResponse['data']?['book_file']?.toString();
          
          fileType = downloadResponse['file_type']?.toString() ??
              downloadResponse['data']?['file_type']?.toString() ??
              widget.book['file_type']?.toString() ??
              'pdf';
          
          debugPrint('Extracted downloadUrl: $downloadUrl, fileType: $fileType');
        }
      } catch (e) {
        debugPrint('Download API error: $e');
        // If download API fails, try to use existing book data
        downloadUrl = widget.book['file_url']?.toString() ??
            widget.book['download_url']?.toString() ??
            widget.book['book_file']?.toString();
        fileType = widget.book['file_type']?.toString() ?? 'pdf';
        debugPrint('Using book data - downloadUrl: $downloadUrl');
      }
      
      // If still no URL, try to get from book data directly
      if ((downloadUrl == null || downloadUrl.isEmpty) && widget.book['file_url'] != null) {
        downloadUrl = widget.book['file_url']?.toString();
        fileType = widget.book['file_type']?.toString() ?? 'pdf';
      }
      
      if (downloadUrl == null || downloadUrl.isEmpty) {
        setState(() {
          _error = 'Book file not available. Please ensure the book is purchased and in your library.';
          _isLoading = false;
        });
        debugPrint('ERROR: No download URL found. Book data: ${widget.book}');
        return;
      }

      // Ensure URL is complete (add base URL if relative)
      if (!downloadUrl.startsWith('http://') && !downloadUrl.startsWith('https://')) {
        final baseUrl = 'https://book-reader-store-backend.onrender.com';
        downloadUrl = downloadUrl.startsWith('/') 
            ? '$baseUrl$downloadUrl'
            : '$baseUrl/$downloadUrl';
      }

      debugPrint('Final download URL: $downloadUrl');

      // Download the file
      final filePath = await _downloadFile(downloadUrl, bookId, fileType ?? 'pdf');
      
      debugPrint('File downloaded to: $filePath');

      // Check file type and load accordingly
      final fileTypeLower = (fileType ?? 'pdf').toLowerCase();
      
      if (fileTypeLower == 'epub') {
        // EPUB files - show message that EPUB support is coming soon
        setState(() {
          _error = 'EPUB support is coming soon. Currently only PDF files are supported.';
          _isLoading = false;
        });
        return;
      }

      // Load PDF document and initialize controller
      final pdfDocumentFuture = PdfDocument.openFile(filePath);
      
      // Initialize PDF controller
      _pdfController = PdfController(
        document: pdfDocumentFuture,
        initialPage: lastPage > 0 ? lastPage : 0,
      );

      // Get total pages after document loads
      final pdfDocument = await pdfDocumentFuture;
      _totalPages = pdfDocument.pagesCount;

      setState(() {
        _currentPage = lastPage > 0 ? lastPage : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load book: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<String> _downloadFile(String url, int bookId, String fileType) async {
    final dio = Dio();
    final appDir = await getApplicationDocumentsDirectory();
    final extension = fileType.toLowerCase() == 'epub' ? 'epub' : 'pdf';
    final filePath = '${appDir.path}/book_$bookId.$extension';
    final file = File(filePath);

    // Return cached file if exists
    if (file.existsSync()) {
      return filePath;
    }

    // Show download progress
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Downloading book...',
                  style: bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 30),
        ),
      );
    }

    try {
      // Download with progress tracking
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Download progress: $progress%');
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      return filePath;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      throw Exception('Failed to download book: ${e.toString()}');
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Save progress periodically
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    if (_pdfController == null || _currentPage == 0) return;

    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    final libraryProvider = Provider.of<LibraryProvider>(context, listen: false);
    final bookId = widget.book['id'];
    final totalPages = widget.book['number_of_pages'] ?? _totalPages;

    try {
      await progressProvider.updateProgress(
        bookId: bookId,
        lastPage: _currentPage,
        totalPages: totalPages,
      );
      
      // Check if book is completed (progress >= 100%)
      final progress = progressProvider.getProgressPercentage(bookId) ?? 0.0;
      if (progress >= 100.0) {
        // Mark as completed
        try {
          await libraryProvider.markAsCompleted(bookId);
        } catch (e) {
          debugPrint('Failed to mark as completed: $e');
        }
      }
    } catch (e) {
      // Silently fail - progress saving is not critical
      debugPrint('Failed to save progress: $e');
    }
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  void _goToPage(int page) {
    _pdfController?.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _saveProgress(); // Save final progress
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // PDF Viewer
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: primaryColor))
            else if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: redColor),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: bodyMedium.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
            else if (_pdfController != null)
              GestureDetector(
                onTap: _toggleControls,
                child: PdfView(
                  controller: _pdfController!,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                ),
              ),

            // Controls Overlay
            if (!_isLoading && _error == null && _isControlsVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
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
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.white),
                            onPressed: _currentPage > 0
                                ? () => _goToPage(_currentPage - 1)
                                : null,
                          ),
                          Text(
                            'Page ${_currentPage + 1} / $_totalPages',
                            style: bodyMedium.copyWith(color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.white),
                            onPressed: _currentPage < _totalPages - 1
                                ? () => _goToPage(_currentPage + 1)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress slider
                      Slider(
                        value: _currentPage.toDouble(),
                        min: 0,
                        max: (_totalPages - 1).toDouble(),
                        divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                        activeColor: primaryColor,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
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

