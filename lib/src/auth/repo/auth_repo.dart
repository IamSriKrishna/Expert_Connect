// Updated auth_repo.dart with global state integration
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/request/auth_request.dart';
import 'package:expert_connect/src/models/city.dart';
import 'package:expert_connect/src/models/country.dart';
import 'package:expert_connect/src/models/state.dart';
import 'package:expert_connect/src/models/user_models.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthException implements Exception {
  final String message;
  final String code;
  final UserModel? userModel;

  const AuthException(this.message, {this.code = 'UNKNOWN', this.userModel});

  @override
  String toString() => message;
}

abstract class AuthRepo {
  Future<UserModel> login({required String email, required String password});
  Future<void> verifyEmailOTP({required String email, required String otp});
  Future<bool> saveDeviceToken(String deviceToken);
  Future<void> signup({
    required String email,
    required String name,
    required String phone,
    required String password,
    required int pincode,
    required int city,
    required int country,
    required int state,
    required String confirmPassword,
  });

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  });
  Future<AuthResult> googleLogin({
    required String idToken,
    required String userType,
  });
  Future<bool> forgetUserPassword({required String email});
  Future<List<Country>> getCountry();
  Future<List<State>> getState(int countryId);
  Future<List<City>> getCity(int stateId);
}

class YearsOfExp {
  final int id;
  final String yearsOfExp;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  YearsOfExp({
    required this.id,
    required this.yearsOfExp,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory YearsOfExp.fromJson(Map<String, dynamic> json) {
    return YearsOfExp(
      id: json['id'] as int,
      yearsOfExp: json['yearsofexp'] as String,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }
}

class AuthResult {
  final bool success;
  final UserModel? user;
  final String? token;
  final String message;

  AuthResult({
    required this.success,
    this.user,
    this.token,
    required this.message,
  });
}

class AuthRepoImpl implements AuthRepo {
  final Dio _dio;
  final Logger _logger = Logger();
  final AuthStateManager _authStateManager = AuthStateManager();

  AuthRepoImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppUrl.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Automatically add auth headers if token exists
          final authHeaders = _authStateManager.authHeaders;
          if (authHeaders != null) {
            options.headers.addAll(authHeaders);
          }

          _logger.d('Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized - clear auth data
          if (error.response?.statusCode == 401) {
            _logger.w('Unauthorized access detected, clearing auth data');
            _authStateManager.clearAuthData();
          }

          _logger.e('HTTP Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<AuthResult> googleLogin({
    required String idToken,
    required String userType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${AppUrl.baseUrl}/auth/google/callback',
        ), // Adjust your endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken, 'user_type': userType}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        _logger.d("Backend Response: ${response.body}");
        await _authStateManager.setAuthData(
          user: UserModel.fromJson(responseData['user']),
          token: responseData['access_token'],
        );
        return AuthResult(
          success: true,
          user: UserModel.fromJson(responseData['user']),
          token: responseData['access_token'],
          message: 'Login successful',
        );
      } else {
        return AuthResult(
          success: false,
          message: responseData['message'] ?? 'Google login failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> saveDeviceToken(String deviceToken) async {
    try {
      _logger.i('Saving device token for user: ${authStateManager.user!.id}');

      final requestBody = {
        'user_id': authStateManager.user!.id,
        'device_token': deviceToken,
      };

      final response = await _dio.post(
        '${AppUrl.baseUrl}/save-device-token',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _logger.d('Save device token response: ${response.data}');

      if (response.data['success'] == true) {
        _logger.i(
          'Device token saved successfully for user: $authStateManager.user!.id',
        );
        return true;
      } else {
        final errorMessage =
            _extractErrorMessage(response.data) ??
            response.data['message'] ??
            'Failed to save device token';
        throw AuthException(errorMessage, code: 'SAVE_DEVICE_TOKEN_FAILED');
      }
    } on DioException catch (e) {
      _logger.e('Network error while saving device token', error: e);
      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('Unexpected error while saving device token', error: e);
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred while saving device token',
      );
    }
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      _logger.i('Attempting password reset for email: $email');

      final requestBody = {
        'email': email.trim(),
        'otp': otp.trim(),
        'password': password.trim(),
        'confirm_password': confirmPassword.trim(),
      };

      final response = await _dio.post(
        '${AppUrl.baseUrl}/resetuserpassword',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _logger.d('Password reset response: ${response.data}');

      if (response.data['success'] == true) {
        _logger.i('Password reset successful for email: $email');
        return true;
      } else {
        final errorMessage =
            _extractErrorMessage(response.data) ??
            response.data['message'] ??
            'Password reset failed';
        throw AuthException(errorMessage, code: 'PASSWORD_RESET_FAILED');
      }
    } on DioException catch (e) {
      _logger.e('Network error during password reset', error: e);
      if (e.response?.statusCode == 400) {
        final errorMessage =
            _extractErrorMessage(e.response?.data) ?? 'Invalid OTP or password';
        throw AuthException(errorMessage, code: 'INVALID_RESET_DATA');
      }
      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('Unexpected error during password reset', error: e);
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred during password reset');
    }
  }

  @override
  Future<bool> forgetUserPassword({required String email}) async {
    try {
      _logger.i('Attempting to send password reset email to: $email');

      final requestBody = {'email': email.trim()};

      final response = await _dio.post(
        '${AppUrl.baseUrl}/forgetuserpassword',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      _logger.d('Password reset response: ${response.data}');

      if (response.data['success'] == true) {
        _logger.i('Password reset email sent successfully to: $email');
        return true;
      } else {
        final errorMessage =
            _extractErrorMessage(response.data) ??
            response.data['message'] ??
            'Failed to send password reset email';
        throw AuthException(errorMessage, code: 'PASSWORD_RESET_FAILED');
      }
    } on DioException catch (e) {
      _logger.e('Network error during password reset request', error: e);

      // Handle specific error cases
      if (e.response?.statusCode == 404) {
        throw AuthException(
          'Email not found. Please check the email address.',
          code: 'EMAIL_NOT_FOUND',
        );
      } else if (e.response?.statusCode == 400) {
        throw AuthException('Invalid email format', code: 'INVALID_EMAIL');
      }

      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('Unexpected error during password reset request', error: e);
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred while processing your request',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting login for email: $email');

      final requestBody = LoginAuthRequest(email: email, password: password);

      final response = await _dio.post(
        AppUrl.login,
        data: requestBody.toJson(),
      );

      if (response.data['success'] == true) {
        final userData = response.data['user'];

        if (userData == null) {
          _logger.e('auth_user data is null in response');
          throw AuthException(
            'Invalid response format: user data missing',
            code: 'INVALID_RESPONSE',
          );
        }

        if (userData is! Map<String, dynamic>) {
          _logger.e('auth_user data is not a Map<String, dynamic>');
          throw AuthException(
            'Invalid response format: user data has wrong type',
            code: 'INVALID_RESPONSE',
          );
        }

        final userModel = UserModel.fromJson(userData);

        // Extract token from response
        final token =
            response.data['token'] ??
            response.data['access_token'] ??
            response.data['auth_token'];

        // Check the message to determine next action
        final message = response.data['message'] ?? '';

        if (message.toLowerCase().contains('otp') ||
            message.toLowerCase().contains('email') &&
                message.toLowerCase().contains('verification')) {
          _logger.i('OTP verification required for user: ${userModel.email}');

          // For OTP case, we might not want to save the token yet
          // Or save it temporarily for OTP verification

          // Throw a specific exception to indicate OTP is needed
          throw AuthException(
            'OTP verification required',
            code: 'OTP_REQUIRED',
            userModel: userModel, // Pass user model for OTP screen
          );
        } else {
          // Successful login - save token
          if (token != null) {
            // Store user data and token globally
            await _authStateManager.setAuthData(
              user: userModel,
              token: token.toString(),
            );
          }

          _logger.i('Login successful for user ID: ${userModel.id}');
          return userModel;
        }
      } else {
        final message = response.data['message'] ?? 'Login failed';
        _logger.e('Login failed: $message');
        throw AuthException(message, code: 'LOGIN_FAILED');
      }
    } on DioException catch (e) {
      _logger.e('Network error during login', error: e);
      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('Unexpected error during login', error: e);
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred during login');
    }
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String name,
    required String phone,
    required String password,
    required String confirmPassword,
    required int pincode,
    required int city,
    required int country,
    required int state,
  }) async {
    try {
      _logger.i('Attempting signup for email: $email');

      final requestBody = SignupAuthRequest(
        name: name,
        phone: phone,
        password: password,
        pincode: pincode,
        city: city,
        country: country,
        state: state,
        confirmPassword: confirmPassword,
        email: email,
      );

      final response = await _dio.post(
        AppUrl.signUp,
        data: requestBody.toJson(),
      );

      // Add debug logging to see the actual response structure
      _logger.d('Full API Response: ${response.data}');

      if (response.data['success'] == true) {
        // Fix: Use 'user' instead of 'auth_user' based on your API response
        final userData = response.data['user'];

        // Add null check before casting
        if (userData == null) {
          throw AuthException(
            'User data not found in response',
            code: 'INVALID_RESPONSE',
          );
        }

        final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

        final token =
            response.data['access_token'] ??
            response.data['token'] ??
            response.data['auth_token'];

        if (token != null) {
          await _authStateManager.setAuthData(
            user: userModel,
            token: token.toString(),
          );
        }

        _logger.i('Signup successful for user ID: ${userModel.id}');
        return userModel;
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        throw AuthException(
          errorMessage ?? 'Signup failed',
          code: 'SIGNUP_FAILED',
        );
      }
    } on DioException catch (e) {
      _logger.e('Network error during signup', error: e);
      if (e.response != null && e.response!.data != null) {
        final errorMessage = _extractErrorMessage(e.response!.data);
        throw AuthException(
          errorMessage ?? _getErrorMessage(e),
          code: 'NETWORK_ERROR',
        );
      } else {
        throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
      }
    } catch (e) {
      _logger.e('Unexpected error during signup', error: e);
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred during signup');
    }
  }

  @override
  Future<void> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    try {
      _logger.i('💡 Verifying OTP for email: $email');

      final Map<String, dynamic> requestData = {
        'email': email.trim(),
        'otp': otp.trim(),
      };

      final response = await _dio.post(
        AppUrl.verifyEmailOTP,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) {
            return status != null && status >= 200 && status < 500;
          },
        ),
      );

      _logger.d('📋 OTP Verification Response: ${response.data}');
      _logger.d('📋 Status Code: ${response.statusCode}');

      // Enhanced response handling
      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          // Check for explicit success field first
          final success = responseData['success'];

          if (success == true ||
              success == 'true' ||
              success == 1 ||
              success == '1') {
            _logger.i('✅ OTP verification successful for email: $email');
            return;
          }

          // If no explicit success field, check the message content
          final message =
              responseData['message'] ??
              responseData['msg'] ??
              responseData['error'] ??
              '';

          // Check if message indicates success
          final messageStr = message.toString().toLowerCase();
          if (messageStr.contains('verified successfully') ||
              messageStr.contains('verification successful') ||
              messageStr.contains('otp verified') ||
              messageStr.contains('email verified')) {
            _logger.i('✅ OTP verification successful for email: $email');
            return;
          }

          // If we reach here, it's likely an error
          final errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              responseData['msg'] ??
              'OTP verification failed';
          throw AuthException(errorMessage, code: 'OTP_VERIFICATION_FAILED');
        } else {
          throw AuthException(
            'Invalid response format',
            code: 'INVALID_RESPONSE',
          );
        }
      } else if (response.statusCode == 400) {
        // Handle 400 Bad Request more specifically
        final responseData = response.data;
        String errorMessage = 'Invalid request';

        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              responseData['msg'] ??
              'Invalid OTP or email format';
        }

        throw AuthException(errorMessage, code: 'BAD_REQUEST');
      } else {
        throw AuthException(
          'Request failed with status: ${response.statusCode}',
          code: 'HTTP_ERROR',
        );
      }
    } on DioException catch (e) {
      _logger.e('⛔ Network error during OTP verification', error: e);

      // Enhanced error handling for different scenarios
      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        String errorMessage = 'Invalid request data';

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            if (errors is Map) {
              errorMessage = errors.values.first?.toString() ?? errorMessage;
            }
          } else {
            errorMessage = responseData['message'] ?? errorMessage;
          }
        }

        throw AuthException(errorMessage, code: 'VALIDATION_ERROR');
      } else if (e.response?.statusCode == 422) {
        // Validation errors
        final responseData = e.response?.data;
        String errorMessage = 'Validation failed';

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];
            if (errors is Map) {
              errorMessage = errors.values.first?.toString() ?? errorMessage;
            }
          } else {
            errorMessage = responseData['message'] ?? errorMessage;
          }
        }

        throw AuthException(errorMessage, code: 'VALIDATION_ERROR');
      }

      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('⛔ Unexpected error during OTP verification', error: e);
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred during OTP verification',
      );
    }
  }

  @override
  Future<List<Country>> getCountry() async {
    try {
      _logger.i('Fetching getCountry for category');

      final response = await _dio.get(AppUrl.country);

      if (response.data['success'] == "true") {
        final List<dynamic> data = response.data['indexdata'];
        final country = data
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Successfully fetched ${country.length} getCountry');
        return country;
      } else {
        throw AuthException(
          response.data['message'] ?? 'Failed to fetch country',
          code: 'FETCH_Country_FAILED',
        );
      }
    } on DioException catch (e) {
      _logger.e('Network error while fetching country', error: e);
      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('Unexpected error while fetching country', error: e);
      if (e is AuthException) rethrow;
      throw AuthException(
        'An unexpected error occurred while fetching country',
      );
    }
  }

  @override
  Future<List<State>> getState(int countryId) async {
    try {
      _logger.i('Fetching getState for category: $countryId');

      final response = await _dio.get("${AppUrl.state}/$countryId");

      if (response.data['success'] == "true") {
        final List<dynamic> data = response.data['indexdata'];
        final state = data
            .map((json) => State.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Successfully fetched ${state.length} getState');
        return state;
      } else {
        throw AuthException(
          response.data['message'] ?? 'Failed to fetch state',
          code: 'FETCH_STATE_FAILED',
        );
      }
    } on DioException catch (e) {
      _logger.e('Network error while fetching state', error: e);
      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('Unexpected error while fetching state', error: e);
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred while fetching state');
    }
  }

  @override
  Future<List<City>> getCity(int stateId) async {
    try {
      _logger.i('Fetching getCity for category: $stateId');

      final response = await _dio.get("${AppUrl.city}/$stateId");

      if (response.data['success'] == "true") {
        final List<dynamic> data = response.data['indexdata'];
        final city = data
            .map((json) => City.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Successfully fetched ${city.length} getCity');
        return city;
      } else {
        throw AuthException(
          response.data['message'] ?? 'Failed to fetch city',
          code: 'FETCH_City_FAILED',
        );
      }
    } on DioException catch (e) {
      _logger.e('Network error while fetching city', error: e);
      throw AuthException(_getErrorMessage(e), code: 'NETWORK_ERROR');
    } catch (e) {
      _logger.e('Unexpected error while fetching city', error: e);
      if (e is AuthException) rethrow;
      throw AuthException('An unexpected error occurred while fetching city');
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Try to extract meaningful error message from response
        String? serverMessage;
        if (responseData is Map<String, dynamic>) {
          serverMessage =
              responseData['message'] ??
              responseData['error'] ??
              responseData['errors']?.toString();
        }

        switch (statusCode) {
          case 400:
            return serverMessage ??
                'Bad request. Please check your input data.';
          case 401:
            return 'Authentication failed. Please login again.';
          case 403:
            return 'Access denied. You don\'t have permission to perform this action.';
          case 404:
            return 'Resource not found. The requested item may have been deleted.';
          case 409:
            return serverMessage ??
                'Conflict occurred. The resource already exists or is being used.';
          case 422:
            return _handleValidationErrors(responseData) ??
                'Validation failed. Please check your input and try again.';
          case 429:
            return 'Too many requests. Please wait a moment and try again.';
          case 500:
            return 'Internal server error. Please try again later.';
          case 502:
            return 'Bad gateway. Server is temporarily unavailable.';
          case 503:
            return 'Service unavailable. Please try again later.';
          case 504:
            return 'Gateway timeout. Please try again.';
          default:
            return serverMessage ?? 'Request failed. Please try again.';
        }

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';

      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Helper method to handle validation errors (422 status code)
  String? _handleValidationErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Laravel-style validation errors
      if (responseData.containsKey('errors') && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];

        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.map((msg) => msg.toString()));
          } else {
            errorMessages.add(messages.toString());
          }
        });

        if (errorMessages.isNotEmpty) {
          return errorMessages.first; // Return first validation error
        }
      }

      // Simple message field
      if (responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
    }

    return null;
  }

  String? _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        // Check for error object with field-specific errors
        if (responseData.containsKey('error')) {
          final error = responseData['error'];
          if (error is Map<String, dynamic>) {
            // Check for common field errors in order of priority
            const errorFields = [
              'email',
              'phone',
              'password',
              'name',
            ]; // Add more if needed
            for (final field in errorFields) {
              if (error.containsKey(field) &&
                  error[field] is List &&
                  (error[field] as List).isNotEmpty) {
                return error[field].first?.toString();
              }
            }
          }
        }
        // Fallback to general message
        return responseData['message']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
