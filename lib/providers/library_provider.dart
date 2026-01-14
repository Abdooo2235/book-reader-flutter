import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';
import 'package:flutter/foundation.dart';

class LibraryProvider extends BaseProvider {
  List<Map<String, dynamic>> _libraryBooks = [];
  List<Map<String, dynamic>> _collections = [];
  Map<int, List<Map<String, dynamic>>> _collectionBooks = {};

  final Api _api = Api();

  // Getters
  List<Map<String, dynamic>> get libraryBooks => _libraryBooks;
  List<Map<String, dynamic>> get collections => _collections;
  List<Map<String, dynamic>> getCollectionBooks(int collectionId) =>
      _collectionBooks[collectionId] ?? [];

  // Load library books
  Future<void> loadLibrary() async {
    setBusy(true);
    try {
      final response = await _api.getLibrary();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _libraryBooks = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          _libraryBooks = List<Map<String, dynamic>>.from(data['data']);
        } else {
          _libraryBooks = [];
        }
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load library');
        _libraryBooks = [];
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      _libraryBooks = [];
      setBusy(false);
    }
  }

  // Load collections
  Future<void> loadCollections() async {
    setBusy(true);
    try {
      final response = await _api.getCollections();
      _collections = List<Map<String, dynamic>>.from(
        response.map((item) => item as Map<String, dynamic>),
      );
      setBusy(false);
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      _collections = [];
      setBusy(false);
    }
  }

  // Load books for a specific collection
  Future<void> loadCollectionBooks(int collectionId) async {
    setBusy(true);
    try {
      final response = await _api.getCollectionBooks(collectionId);
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _collectionBooks[collectionId] =
              List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          _collectionBooks[collectionId] =
              List<Map<String, dynamic>>.from(data['data']);
        } else {
          _collectionBooks[collectionId] = [];
        }
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load collection books');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      _collectionBooks[collectionId] = [];
      setBusy(false);
    }
  }

  // Add book to collection
  Future<void> addBookToCollection({
    required int collectionId,
    required int bookId,
  }) async {
    setBusy(true);
    try {
      await _api.addBookToCollection(
        collectionId: collectionId,
        bookId: bookId,
      );
      // Reload collection books
      await loadCollectionBooks(collectionId);
      setBusy(false);
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Remove book from collection
  Future<void> removeBookFromCollection({
    required int collectionId,
    required int bookId,
  }) async {
    setBusy(true);
    try {
      await _api.removeBookFromCollection(
        collectionId: collectionId,
        bookId: bookId,
      );
      // Reload collection books
      await loadCollectionBooks(collectionId);
      setBusy(false);
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Download book
  Future<Map<String, dynamic>?> downloadBook(int bookId) async {
    setBusy(true);
    setFailed(false);
    setErrorMessage(null);
    
    try {
      final response = await _api.downloadBook(bookId);
      
      debugPrint('Download API response: $response');
      
      // Handle both nested and flat response structures
      Map<String, dynamic>? data;
      if (response['success'] == true && response['data'] != null) {
        data = response['data'];
      } else if (response['file_url'] != null) {
        // Response might be flat
        data = response;
      } else if (response['data'] != null) {
        // Data exists but success might be false
        data = response['data'];
      } else {
        // Try to get data directly
        data = response;
      }
      
      debugPrint('Extracted data: $data');
      
      // Check if file URL exists
      final fileUrl = data?['file_url']?.toString() ??
          data?['download_url']?.toString() ??
          data?['book_file']?.toString();
      
      if (data != null && fileUrl != null && fileUrl.isNotEmpty) {
        // Reload library to include the new book
        try {
          await loadLibrary();
        } catch (e) {
          debugPrint('Failed to reload library: $e');
          // Don't fail the download if library reload fails
        }
        setBusy(false);
        return data;
      } else {
        // No file URL found
        final errorMsg = response['message']?.toString() ?? 
            'File URL not found in server response. Response: ${response.toString()}';
        setFailed(true);
        setErrorMessage(errorMsg);
        setBusy(false);
        debugPrint('ERROR: $errorMsg');
        return null;
      }
    } catch (e) {
      debugPrint('Download exception: $e');
      
      // Extract meaningful error message
      String errorMsg = 'Failed to download book';
      if (e.toString().contains('DioException')) {
        // Dio errors have more details
        final dioError = e.toString();
        if (dioError.contains('401')) {
          errorMsg = 'Authentication failed. Please log in again.';
        } else if (dioError.contains('403')) {
          errorMsg = 'You don\'t have permission to download this book. Please purchase it first.';
        } else if (dioError.contains('404')) {
          errorMsg = 'Book not found. It may have been removed.';
        } else if (dioError.contains('timeout')) {
          errorMsg = 'Request timed out. Please check your internet connection.';
        } else {
          errorMsg = 'Network error: ${e.toString()}';
        }
      } else {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }
      
      setFailed(true);
      setErrorMessage(errorMsg);
      setBusy(false);
      return null;
    }
  }

  // Get books by collection type
  List<Map<String, dynamic>> getBooksByCollectionType(String type) {
    // Find collection by type/name
    final collection = _collections.firstWhere(
      (c) => c['type']?.toString().toLowerCase() == type.toLowerCase() ||
          c['name']?.toString().toLowerCase().contains(type.toLowerCase()) == true,
      orElse: () => <String, dynamic>{},
    );
    
    if (collection.isEmpty) return [];
    
    final collectionId = collection['id'];
    if (collectionId == null) return [];
    
    return getCollectionBooks(collectionId);
  }

  // Get Reading books (books with progress > 0 and < 100)
  List<Map<String, dynamic>> getReadingBooks(
    Map<int, Map<String, dynamic>> progressMap,
  ) {
    return _libraryBooks.where((book) {
      final bookId = book['id'];
      if (bookId == null) return false;
      
      final progress = progressMap[bookId];
      if (progress == null) return false;
      
      final percentage = progress['progress_percentage']?.toDouble() ?? 0.0;
      return percentage > 0 && percentage < 100;
    }).toList();
  }

  // Get Already Read books (books with progress = 100)
  List<Map<String, dynamic>> getAlreadyReadBooks(
    Map<int, Map<String, dynamic>> progressMap,
  ) {
    return _libraryBooks.where((book) {
      final bookId = book['id'];
      if (bookId == null) return false;
      
      final progress = progressMap[bookId];
      if (progress == null) return false;
      
      final percentage = progress['progress_percentage']?.toDouble() ?? 0.0;
      return percentage >= 100;
    }).toList();
  }

  // Get all library books (for Shelves tab)
  List<Map<String, dynamic>> getAllLibraryBooks() {
    return _libraryBooks;
  }

  // Mark book as reading (add to Reading collection)
  Future<void> markAsReading(int bookId) async {
    // Find "Reading" collection
    final readingCollection = _collections.firstWhere(
      (c) => c['name']?.toString().toLowerCase().contains('reading') == true ||
          c['type']?.toString().toLowerCase() == 'reading',
      orElse: () => <String, dynamic>{},
    );

    if (readingCollection.isNotEmpty && readingCollection['id'] != null) {
      await addBookToCollection(
        collectionId: readingCollection['id'],
        bookId: bookId,
      );
    }
  }

  // Mark book as completed (add to Already Read collection)
  Future<void> markAsCompleted(int bookId) async {
    // Find "Already Read" or "Completed" collection
    final completedCollection = _collections.firstWhere(
      (c) => c['name']?.toString().toLowerCase().contains('read') == true ||
          c['name']?.toString().toLowerCase().contains('completed') == true ||
          c['type']?.toString().toLowerCase() == 'completed',
      orElse: () => <String, dynamic>{},
    );

    if (completedCollection.isNotEmpty && completedCollection['id'] != null) {
      await addBookToCollection(
        collectionId: completedCollection['id'],
        bookId: bookId,
      );
    }
  }

  // Check if book is in a specific collection
  bool isBookInCollection(int bookId, int collectionId) {
    final books = getCollectionBooks(collectionId);
    return books.any((book) => book['id'] == bookId);
  }
}

