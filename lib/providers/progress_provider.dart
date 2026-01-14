import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';

class ProgressProvider extends BaseProvider {
  final Map<int, Map<String, dynamic>> _bookProgress = {};

  final Api _api = Api();

  // Getters
  Map<int, Map<String, dynamic>> get bookProgress => _bookProgress;
  Map<String, dynamic>? getBookProgress(int bookId) => _bookProgress[bookId];
  double? getProgressPercentage(int bookId) {
    final progress = _bookProgress[bookId];
    return progress?['progress_percentage']?.toDouble();
  }

  int? getLastPage(int bookId) {
    final progress = _bookProgress[bookId];
    return progress?['last_page']?.toInt();
  }

  // Load all progress
  Future<void> loadAllProgress() async {
    setBusy(true);
    try {
      final response = await _api.getAllProgress();
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          for (var item in data) {
            final bookId = item['book_id'];
            if (bookId != null) {
              _bookProgress[bookId] = Map<String, dynamic>.from(item);
            }
          }
        } else if (data is Map) {
          // Single progress object
          final bookId = data['book_id'];
          if (bookId != null) {
            _bookProgress[bookId] = Map<String, dynamic>.from(data);
          }
        }
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load progress');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Load progress for specific book
  Future<void> loadBookProgress(int bookId) async {
    setBusy(true);
    try {
      final response = await _api.getBookProgress(bookId);
      if (response['success'] == true) {
        _bookProgress[bookId] = Map<String, dynamic>.from(response['data']);
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load progress');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }

  // Update progress
  Future<void> updateProgress({
    required int bookId,
    required int lastPage,
    int? totalPages,
  }) async {
    setBusy(true);
    try {
      final response = await _api.updateProgress(
        bookId: bookId,
        lastPage: lastPage,
        totalPages: totalPages,
      );
      if (response['success'] == true) {
        _bookProgress[bookId] = Map<String, dynamic>.from(response['data']);
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to update progress');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }
}
