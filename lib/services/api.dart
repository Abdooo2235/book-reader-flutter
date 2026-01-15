import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_reader_app/helpers/consts.dart';
import 'package:book_reader_app/helpers/navigator_key.dart';
import 'package:book_reader_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

class Api {
  static final Api _instance = Api._internal();
  factory Api() => _instance;
  Api._internal();

  late Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token
            await _clearToken();
            // Navigate to login screen if navigator key is available
            if (navigatorKey.currentContext != null) {
              Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ==================== AUTHENTICATION ====================

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await _clearToken();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/auth/user');
    return response.data;
  }

  // ==================== PROFILE ====================

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/profile');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({String? name}) async {
    final response = await _dio.put(
      '/profile',
      data: {if (name != null) 'name': name},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(imageFile.path),
    });
    final response = await _dio.post('/profile/avatar', data: formData);
    return response.data;
  }

  Future<void> deleteAvatar() async {
    await _dio.delete('/profile/avatar');
  }

  // ==================== BOOKS (PUBLIC) ====================

  Future<Map<String, dynamic>> getBooks({
    int? categoryId,
    String? title,
    String? author,
    String? fileType,
    String? sort,
    String? include,
    int? perPage,
    int? page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null) queryParams['filter[category_id]'] = categoryId;
    if (title != null) queryParams['filter[title]'] = title;
    if (author != null) queryParams['filter[author]'] = author;
    if (fileType != null) queryParams['filter[file_type]'] = fileType;
    if (sort != null) queryParams['sort'] = sort;
    if (include != null) queryParams['include'] = include;
    if (perPage != null) queryParams['per_page'] = perPage;
    if (page != null) queryParams['page'] = page;

    final response = await _dio.get('/books', queryParameters: queryParams);
    return response.data;
  }

  Future<Map<String, dynamic>> getBook(int id) async {
    final response = await _dio.get('/books/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> getBookReviews(int bookId) async {
    final response = await _dio.get('/books/$bookId/reviews');
    return response.data;
  }

  // ==================== CATEGORIES (PUBLIC) ====================

  Future<List<dynamic>> getCategories() async {
    final response = await _dio.get('/categories');
    return response.data['data'] ?? [];
  }

  // ==================== BOOK SUBMISSION ====================

  Future<Map<String, dynamic>> submitBook({
    required String title,
    required String author,
    required String description,
    required int categoryId,
    required String fileType,
    required int numberOfPages,
    File? bookFile,
    File? coverImage,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'author': author,
      'description': description,
      'category_id': categoryId,
      'file_type': fileType,
      'number_of_pages': numberOfPages,
      if (bookFile != null)
        'book_file': await MultipartFile.fromFile(bookFile.path),
      if (coverImage != null)
        'cover_image': await MultipartFile.fromFile(coverImage.path),
    });

    final response = await _dio.post('/books', data: formData);

    // Handle different response types
    if (response.data is Map<String, dynamic>) {
      return response.data;
    } else if (response.data is String) {
      // Try to parse string as JSON, otherwise wrap it
      return {'success': true, 'message': response.data};
    } else {
      return {'success': true, 'data': response.data};
    }
  }

  Future<Map<String, dynamic>> getMySubmittedBooks() async {
    final response = await _dio.get('/my-books');
    return response.data;
  }

  Future<void> deletePendingBook(int id) async {
    await _dio.delete('/my-books/$id');
  }

  // ==================== ORDERS ====================

  Future<Map<String, dynamic>> getOrders() async {
    final response = await _dio.get('/orders');
    return response.data;
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    final response = await _dio.get('/orders/$id');
    return response.data;
  }

  // ==================== LIBRARY (DOWNLOADED BOOKS) ====================

  Future<Map<String, dynamic>> getLibrary() async {
    final response = await _dio.get('/library');
    return response.data;
  }

  Future<Map<String, dynamic>> downloadBook(int bookId) async {
    final response = await _dio.get('/library/$bookId/download');
    return response.data;
  }

  Future<void> removeBookFromLibrary(int bookId) async {
    await _dio.delete('/library/$bookId');
  }

  // ==================== FAVORITES ====================

  Future<void> addToFavorites(int bookId) async {
    await _dio.post('/library/$bookId/favorite');
  }

  Future<void> removeFromFavorites(int bookId) async {
    await _dio.delete('/library/$bookId/favorite');
  }

  Future<Map<String, dynamic>> getFavorites() async {
    final response = await _dio.get('/favorites');
    return response.data;
  }

  // ==================== COLLECTIONS ====================

  Future<List<dynamic>> getCollections() async {
    final response = await _dio.get('/collections');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> createCollection(String name) async {
    final response = await _dio.post('/collections', data: {'name': name});
    return response.data;
  }

  Future<void> deleteCollection(int collectionId) async {
    await _dio.delete('/collections/$collectionId');
  }

  Future<Map<String, dynamic>> getCollectionBooks(int collectionId) async {
    final response = await _dio.get('/collections/$collectionId/books');
    return response.data;
  }

  Future<void> addBookToCollection({
    required int collectionId,
    required int bookId,
  }) async {
    await _dio.post(
      '/collections/$collectionId/books',
      data: {'book_id': bookId},
    );
  }

  Future<void> removeBookFromCollection({
    required int collectionId,
    required int bookId,
  }) async {
    await _dio.delete('/collections/$collectionId/books/$bookId');
  }

  // ==================== READING PROGRESS ====================

  Future<Map<String, dynamic>> getAllProgress() async {
    final response = await _dio.get('/progress');
    return response.data;
  }

  Future<Map<String, dynamic>> getBookProgress(int bookId) async {
    final response = await _dio.get('/progress/$bookId');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProgress({
    required int bookId,
    required int lastPage,
    int? totalPages,
  }) async {
    final response = await _dio.put(
      '/progress/$bookId',
      data: {
        'last_page': lastPage,
        if (totalPages != null) 'total_pages': totalPages,
      },
    );
    return response.data;
  }

  // ==================== REVIEWS ====================

  Future<Map<String, dynamic>> createReview({
    required int bookId,
    required int rating,
    required String reviewText,
  }) async {
    final response = await _dio.post(
      '/books/$bookId/reviews',
      data: {'rating': rating, 'review_text': reviewText},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateReview({
    required int reviewId,
    int? rating,
    String? reviewText,
  }) async {
    final response = await _dio.put(
      '/reviews/$reviewId',
      data: {
        if (rating != null) 'rating': rating,
        if (reviewText != null) 'review_text': reviewText,
      },
    );
    return response.data;
  }

  Future<void> deleteReview(int reviewId) async {
    await _dio.delete('/reviews/$reviewId');
  }

  // ==================== PREFERENCES ====================

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _dio.get('/preferences');
    return response.data;
  }

  Future<Map<String, dynamic>> updatePreferences({
    String? theme,
    int? fontSize,
  }) async {
    final response = await _dio.put(
      '/preferences',
      data: {
        if (theme != null) 'theme': theme,
        if (fontSize != null) 'font_size': fontSize,
      },
    );
    return response.data;
  }
}
