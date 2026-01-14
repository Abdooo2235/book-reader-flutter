import 'package:book_reader_app/helpers/navigator_key.dart';
import 'package:book_reader_app/providers/base_provider.dart';
import 'package:book_reader_app/screens/auth/login_screen.dart';
import 'package:book_reader_app/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  uninitialized,
  unauthenticated,
  authenticated,
  authenticating,
}

class AuthProvider extends BaseProvider {
  AuthStatus status = AuthStatus.uninitialized;
  String? token;
  Map<String, dynamic>? user;

  final Api _api = Api();

  Future<void> initAuthProvider() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tempToken = prefs.getString("token");

    if (tempToken != null) {
      status = AuthStatus.authenticated;
      token = tempToken;
      if (kDebugMode) {
        print("TOKEN : $tempToken");
      }
      // Load user profile
      try {
        await loadCurrentUser();
      } catch (e) {
        if (kDebugMode) {
          print("Error loading user: $e");
        }
      }
      setBusy(false);
    } else {
      status = AuthStatus.unauthenticated;
      token = null;
      setBusy(false);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    setBusy(true);
    setFailed(false);
    try {
      final response = await _api.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (response['success'] == true) {
        final newToken = response['data']['token'];
        final userData = response['data']['user'];

        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);

        token = newToken;
        user = userData;
        status = AuthStatus.authenticated;

        setBusy(false);
        return response;
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Registration failed');
        setBusy(false);
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    setBusy(true);
    setFailed(false);
    status = AuthStatus.authenticating;
    try {
      final response = await _api.login(email: email, password: password);

      if (response['success'] == true) {
        final newToken = response['data']['token'];
        final userData = response['data']['user'];

        // Store token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);

        token = newToken;
        user = userData;
        status = AuthStatus.authenticated;

        setBusy(false);
        return response;
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Login failed');
        status = AuthStatus.unauthenticated;
        setBusy(false);
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      status = AuthStatus.unauthenticated;
      setBusy(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    setBusy(true);
    try {
      await _api.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      token = null;
      user = null;
      status = AuthStatus.unauthenticated;

      setBusy(false);

      // Navigate to login screen and clear navigation stack
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Even if API call fails, clear local token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      token = null;
      user = null;
      status = AuthStatus.unauthenticated;

      setBusy(false);
      setFailed(true);
      setErrorMessage(e.toString());

      // Navigate to login screen even if logout API call fails
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<Map<String, dynamic>> loadCurrentUser() async {
    setBusy(true);
    try {
      final response = await _api.getCurrentUser();
      if (response['success'] == true) {
        user = response['data'];
        setBusy(false);
        return response;
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load user');
        setBusy(false);
        throw Exception(response['message'] ?? 'Failed to load user');
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadProfile() async {
    setBusy(true);
    try {
      final response = await _api.getProfile();
      if (response['success'] == true) {
        user = response['data'];
        setBusy(false);
        return response;
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to load profile');
        setBusy(false);
        throw Exception(response['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile({String? name}) async {
    setBusy(true);
    try {
      final response = await _api.updateProfile(name: name);
      if (response['success'] == true) {
        user = response['data'];
        setBusy(false);
        return response;
      } else {
        setFailed(true);
        setErrorMessage(response['message'] ?? 'Failed to update profile');
        setBusy(false);
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      setFailed(true);
      setErrorMessage(e.toString());
      setBusy(false);
      rethrow;
    }
  }
}
