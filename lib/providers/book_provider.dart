import 'dart:io';
import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';

class BookProvider extends BaseProvider {
  List<Map<String, dynamic>> _books = [];
  final List<Map<String, dynamic>> _favorites = [];
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isSelecting = false;
  final Set<int> _selectedBooks = {};

  final Api _api = Api();

  // Getters
  List<Map<String, dynamic>> get books => _books;
  List<Map<String, dynamic>> get favorites => _favorites;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get isSelecting => _isSelecting;
  Set<int> get selectedBooks => _selectedBooks;

  // Filtered books based on search query
  List<Map<String, dynamic>> get filteredBooks {
    if (_searchQuery.isEmpty) {
      return _books;
    }

    final lowerQuery = _searchQuery.toLowerCase();
    return _books.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      return title.contains(lowerQuery) || author.contains(lowerQuery);
    }).toList();
  }

  // Load books from API
  Future<void> loadBooks({
    int? categoryId,
    String? title,
    String? author,
    String? fileType,
    String? sort,
    String? include,
    int? perPage,
    int? page,
  }) async {
    setBusy(true);
    try {
      final response = await _api.getBooks(
        categoryId: categoryId,
        title: title,
        author: author,
        fileType: fileType,
        sort: sort,
        include: include,
        perPage: perPage,
        page: page,
      );

      if (response['success'] == true) {
        final data = response['data'];
        if (data is Map && data['data'] != null) {
          // Paginated response
          _books = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          // List response
          _books = List<Map<String, dynamic>>.from(data);
        } else {
          _books = [];
        }
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load books');
        _books = [];
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      _books = [];
      setBusy(false);
    }
  }

  // Get single book
  Future<Map<String, dynamic>?> getBook(int id) async {
    setBusy(true);
    try {
      final response = await _api.getBook(id);
      if (response['success'] == true) {
        setBusy(false);
        return response['data'];
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load book');
        setBusy(false);
        return null;
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
      return null;
    }
  }

  // Submit new book
  Future<Map<String, dynamic>?> submitBook({
    required String title,
    required String author,
    required String description,
    required int categoryId,
    required String fileType,
    required int numberOfPages,
    File? bookFile,
    File? coverImage,
  }) async {
    setBusy(true);
    try {
      final response = await _api.submitBook(
        title: title,
        author: author,
        description: description,
        categoryId: categoryId,
        fileType: fileType,
        numberOfPages: numberOfPages,
        bookFile: bookFile,
        coverImage: coverImage,
      );

      if (response['success'] == true) {
        // Reload books to include the new one
        await loadBooks();
        setBusy(false);
        return response['data'];
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to submit book');
        setBusy(false);
        return null;
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
      return null;
    }
  }

  // Add book to local list (for immediate UI update)
  void addBookToLocalList(Map<String, dynamic> bookData) {
    _books.add(bookData);
    notifyListeners();
  }

  // Remove books (from collections)
  Future<void> removeBooks(List<int> indices) async {
    setBusy(true);
    try {
      // Remove books in reverse order to maintain indices
      final sortedIndices = indices.toList()..sort((a, b) => b.compareTo(a));
      for (final index in sortedIndices) {
        if (index >= 0 && index < _books.length) {
          _books.removeAt(index);
        }
      }

      _selectedBooks.clear();
      _isSelecting = false;
      setBusy(false);
      notifyListeners();
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Search methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchQuery = '';
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Selection methods
  void toggleSelectionMode() {
    _isSelecting = !_isSelecting;
    if (!_isSelecting) {
      _selectedBooks.clear();
    }
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelecting = false;
    _selectedBooks.clear();
    notifyListeners();
  }

  void toggleBookSelection(int index) {
    if (_selectedBooks.contains(index)) {
      _selectedBooks.remove(index);
    } else {
      _selectedBooks.add(index);
    }
    notifyListeners();
  }

  // Favorites
  bool isFavorite(Map<String, dynamic> book) {
    return _favorites.any((b) => b['id'] == book['id']);
  }

  void toggleFavorite(Map<String, dynamic> book) {
    if (isFavorite(book)) {
      _favorites.removeWhere((b) => b['id'] == book['id']);
    } else {
      _favorites.add(book);
    }
    notifyListeners();
  }
}
