import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/services/api.dart';

class ReviewProvider extends BaseProvider {
  final Map<int, List<Map<String, dynamic>>> _bookReviews = {};

  final Api _api = Api();

  // Getters
  List<Map<String, dynamic>> getBookReviews(int bookId) =>
      _bookReviews[bookId] ?? [];

  // Load reviews for a book
  Future<void> loadBookReviews(int bookId) async {
    setBusy(true);
    try {
      final response = await _api.getBookReviews(bookId);
      if (response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _bookReviews[bookId] = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          _bookReviews[bookId] = List<Map<String, dynamic>>.from(data['data']);
        } else {
          _bookReviews[bookId] = [];
        }
        setBusy(false);
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load reviews');
        setBusy(false);
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      _bookReviews[bookId] = [];
      setBusy(false);
    }
  }

  // Create review
  Future<Map<String, dynamic>?> createReview({
    required int bookId,
    required int rating,
    required String reviewText,
  }) async {
    setBusy(true);
    try {
      final response = await _api.createReview(
        bookId: bookId,
        rating: rating,
        reviewText: reviewText,
      );
      if (response['success'] == true) {
        // Reload reviews
        await loadBookReviews(bookId);
        setBusy(false);
        return response['data'];
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to create review');
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

  // Update review
  Future<Map<String, dynamic>?> updateReview({
    required int reviewId,
    required int bookId,
    int? rating,
    String? reviewText,
  }) async {
    setBusy(true);
    try {
      final response = await _api.updateReview(
        reviewId: reviewId,
        rating: rating,
        reviewText: reviewText,
      );
      if (response['success'] == true) {
        // Reload reviews
        await loadBookReviews(bookId);
        setBusy(false);
        return response['data'];
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to update review');
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

  // Delete review
  Future<void> deleteReview(int reviewId, int bookId) async {
    setBusy(true);
    try {
      await _api.deleteReview(reviewId);
      // Reload reviews
      await loadBookReviews(bookId);
      setBusy(false);
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
    }
  }
}
