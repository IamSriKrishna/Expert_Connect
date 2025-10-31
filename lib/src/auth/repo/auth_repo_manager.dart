// auth_state_manager.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expert_connect/src/models/user_models.dart';

class AuthStateManager extends ChangeNotifier {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal();

  // Private variables
  UserModel? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // SharedPreferences keys
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Initialize the auth state from stored data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load token
      _token = prefs.getString(_tokenKey);
      
      // Load user data
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _user = UserModel.fromJson(userMap);
      }
      
      // Load login status
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      // Validate if we have both token and user data
      if (_token != null && _user != null) {
        _isLoggedIn = true;
      } else {
        _isLoggedIn = false;
      }
      
    } catch (e) {
      debugPrint('Error loading auth state: $e');
      await clearAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set user data and token after successful login
  Future<void> setAuthData({
    required UserModel user,
    required String token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store user data
      await prefs.setString(_userKey, json.encode(user.toJson()));
      
      // Store token
      await prefs.setString(_tokenKey, token);
      
      // Store login status
      await prefs.setBool(_isLoggedInKey, true);
      
      // Update in-memory variables
      _user = user;
      _token = token;
      _isLoggedIn = true;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      throw Exception('Failed to save authentication data');
    }
  }

  /// Update user data only (for profile updates)
  Future<void> updateUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(user.toJson()));
      
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  /// Update token only (for token refresh)
  Future<void> updateToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      _token = token;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating token: $e');
      throw Exception('Failed to update token');
    }
  }

  /// Clear all auth data (logout)
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove stored data
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_isLoggedInKey);
      
      // Clear in-memory variables
      _user = null;
      _token = null;
      _isLoggedIn = false;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  /// Get authorization header for API requests
  Map<String, String>? get authHeaders {
    if (_token != null) {
      return {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return null;
  }


  /// Get user's full name
  String get userFullName {
    return _user?.name ?? 'Unknown User';
  }

  /// Get user's email
  String get userEmail {
    return _user?.email ?? '';
  }

  /// Get user's phone
  String get userPhone {
    return _user?.phone ?? '';
  }
}

// Global instance for easy access
final authStateManager = AuthStateManager();