import 'package:book_reader_app/services/api.dart';
import 'package:flutter/material.dart';

/// Base provider class that provides common functionality for all providers
/// 
/// This class handles:
/// - Loading state management
/// - Error state management
/// - API instance access
abstract class BaseProvider with ChangeNotifier {
  bool _busy = false;
  bool _failed = false;
  String? _errorMessage;
  final Api api = Api();

  /// Whether the provider is currently busy (loading)
  bool get busy => _busy;

  /// Whether the last operation failed
  bool get failed => _failed;

  /// Error message from the last failed operation
  String? get errorMessage => _errorMessage;

  /// Sets the busy state
  void setBusy(bool status) {
    if (_busy != status) {
      _busy = status;
    notifyListeners();
    }
  }

  /// Sets the failed state
  void setFailed(bool status) {
    if (_failed != status) {
      _failed = status;
    notifyListeners();
    }
  }

  /// Sets the error message
  void setErrorMessage(String? msg) {
    if (_errorMessage != msg) {
      _errorMessage = msg;
    notifyListeners();
    }
  }

  /// Resets all error states
  void clearError() {
    setFailed(false);
    setErrorMessage(null);
  }

  /// Resets all states (busy, failed, error message)
  void resetState() {
    setBusy(false);
    clearError();
  }

  /// Wraps an async operation with error handling
  Future<T?> executeWithErrorHandling<T>({
    required Future<T> Function() operation,
    String? defaultErrorMessage,
  }) async {
    try {
      setBusy(true);
      clearError();
      final result = await operation();
      setBusy(false);
      return result;
    } catch (e) {
      setBusy(false);
      setFailed(true);
      setErrorMessage(defaultErrorMessage ?? e.toString());
      return null;
    }
  }
}
