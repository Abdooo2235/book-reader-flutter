import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';

class CategoryProvider extends BaseProvider {
  List<Map<String, dynamic>> _categories = [];
  int _selectedIndex =
      -1; // Start with -1 (no selection) until categories are loaded

  final Api _api = Api();

  // Getters
  List<Map<String, dynamic>> get categories {
    // Add "All" as the first category
    final allCategory = {'id': null, 'name': 'All', 'book_count': 0};
    return [allCategory, ..._categories];
  }

  int get selectedIndex => _selectedIndex;

  Map<String, dynamic>? get selectedCategory {
    if (_selectedIndex < 0) return null;
    // Index 0 is "All", so subtract 1 for API categories
    if (_selectedIndex == 0) {
      return {'id': null, 'name': 'All', 'book_count': 0};
    }
    final apiIndex = _selectedIndex - 1;
    return apiIndex >= 0 && apiIndex < _categories.length
        ? _categories[apiIndex]
        : null;
  }

  int? get selectedCategoryId {
    // Return null for "All" (index 0) to show all books
    if (_selectedIndex == 0) return null;
    final apiIndex = _selectedIndex - 1;
    if (apiIndex >= 0 && apiIndex < _categories.length) {
      return _categories[apiIndex]['id'];
    }
    return null;
  }

  // Initialize categories from API
  Future<void> loadCategories() async {
    setBusy(true);
    try {
      final response = await _api.getCategories();
      _categories = List<Map<String, dynamic>>.from(
        response.map((item) => item as Map<String, dynamic>),
      );
      // Set initial selection to "All" (index 0) when categories are loaded
      if (_selectedIndex < 0) {
        _selectedIndex = 0; // "All" is always at index 0
      } else if (_selectedIndex > _categories.length) {
        // Reset if current selection is out of bounds (accounting for "All" at index 0)
        _selectedIndex = 0; // Default to "All"
      }
      setBusy(false);
      setFailed(false);
      notifyListeners();
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      // Only show categories from API - no fallback
      _categories = [];
      // Set to "All" (index 0) even if API fails, so "All" chip is shown
      _selectedIndex = 0;
      setBusy(false);
      notifyListeners();
    }
  }

  // Select category
  void selectCategory(int index) {
    // Index 0 is "All", valid range is 0 to categories.length (inclusive of "All")
    if (index >= 0 && index <= _categories.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  // Reset selection to "All"
  void resetSelection() {
    _selectedIndex = 0; // "All" is always at index 0
    notifyListeners();
  }
}
