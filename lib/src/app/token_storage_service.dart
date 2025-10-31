import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  
  static final Logger _logger = Logger();
  static TokenStorageService? _instance;
  static SharedPreferences? _prefs;

  TokenStorageService._();

  static Future<TokenStorageService> getInstance() async {
    if (_instance == null) {
      _instance = TokenStorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Store authentication token
  Future<void> storeAuthToken(String token, {DateTime? expiryDate}) async {
    try {
      await _prefs!.setString(_tokenKey, token);
      
      // If expiry date is provided, store it
      if (expiryDate != null) {
        await _prefs!.setInt(_tokenExpiryKey, expiryDate.millisecondsSinceEpoch);
      }
      
      _logger.i('Auth token stored successfully');
    } catch (e) {
      _logger.e('Error storing auth token: $e');
    }
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    try {
      return _prefs!.getString(_tokenKey);
    } catch (e) {
      _logger.e('Error getting auth token: $e');
      return null;
    }
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final expiryTimestamp = _prefs!.getInt(_tokenExpiryKey);
      if (expiryTimestamp == null) {
        // If no expiry is set, assume token is valid
        return false;
      }
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      final now = DateTime.now();
      
      return now.isAfter(expiryDate);
    } catch (e) {
      _logger.e('Error checking token expiry: $e');
      return true; // Assume expired on error
    }
  }

  // Check if user is authenticated and token is valid
  Future<bool> isAuthenticated() async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      final isExpired = await isTokenExpired();
      return !isExpired;
    } catch (e) {
      _logger.e('Error checking authentication status: $e');
      return false;
    }
  }

  // Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    try {
      final userDataJson = jsonEncode(userData);
      await _prefs!.setString(_userDataKey, userDataJson);
      _logger.i('User data stored successfully');
    } catch (e) {
      _logger.e('Error storing user data: $e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataJson = _prefs!.getString(_userDataKey);
      if (userDataJson != null) {
        return jsonDecode(userDataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user data: $e');
      return null;
    }
  }

  // Clear all authentication data
  Future<void> clearAuthData() async {
    try {
      await _prefs!.remove(_tokenKey);
      await _prefs!.remove(_userDataKey);
      await _prefs!.remove(_tokenExpiryKey);
      _logger.i('Auth data cleared successfully');
    } catch (e) {
      _logger.e('Error clearing auth data: $e');
    }
  }

  // Store complete auth session
  Future<void> storeAuthSession({
    required String token,
    required Map<String, dynamic> userData,
    DateTime? expiryDate,
  }) async {
    await storeAuthToken(token, expiryDate: expiryDate);
    await storeUserData(userData);
  }
}