import 'package:dio/dio.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/transaction_response.dart';
import 'package:expert_connect/src/models/transaction_summary.dart';
import 'package:expert_connect/src/models/user_models.dart';
import 'package:logger/logger.dart';

class SettingsRepo implements Exception {
  final String message;
  final String? code;

  const SettingsRepo(this.message, {this.code});

  @override
  String toString() => message;
}

abstract class SettingRepo {
  Future<TransactionSummary> fetchTransactionSummary();
  Future<TransactionResponse> fetchwalletSummary();
  Future<UserModel> fetchUserProfile();
  Future<bool> updateProfileImage({required MultipartFile profileImage});
  Future<bool> updateUserLocation({
    required int userId,
    required String latitude,
    required String timezone,
    required String longitude,
  });
  Future<bool> updateUserProfile({
    required String name,
    required String phNumber,
    required int country,
    required int state,
    required int city,
    required String pincode,
    MultipartFile? profileImage,
  });
}

class SettingRepoImpl implements SettingRepo {
  final Dio _dio;
  final Logger _logger = Logger();
  SettingRepoImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppUrl.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);

    // Add this to follow redirects
    _dio.options.followRedirects = true;
    _dio.options.maxRedirects = 5;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('HTTP Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

 @override
Future<bool> updateUserProfile({
  required String name,
  required int country,
  required int state,
  required int city,
  required String phNumber,
  required String pincode,
  MultipartFile? profileImage,
}) async {
  try {
    final formData = FormData.fromMap({
      'name': name,
      'country': country,
      'phone': phNumber,
      'state': state,
      'city': city,
      'pincode': pincode,
      if (profileImage != null) 'profile_image': profileImage,
    });

    final Response response = await _dio.post(
      '${AppUrl.baseUrl}/user/profile/update/${authStateManager.user!.id}',
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer ${authStateManager.token}",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
      _logger.d('Successfully updated User profile: ${response.data}');
      return response.data['success'] == true;
    }
    _logger.e('Failed to update User profile: ${response.data}');
    return false;
  } on DioException catch (e) {
    _logger.e('Dio error updating User profile: ${e.message}');

    if (e.response != null) {
      _logger.e('Server response: ${e.response?.data}');
      _logger.e('Status code: ${e.response?.statusCode}');
    }

    if (e.response?.statusCode == 401) {
      throw SettingsRepo('Authentication failed. Please login again.');
    }

    // Handle validation errors specially
    if (e.response?.statusCode == 422 || e.response?.statusCode == 400) {
      final errorMessage = _extractValidationError(e.response?.data);
      if (errorMessage != null) {
        throw SettingsRepo(errorMessage);
      }
    }

    throw SettingsRepo(_getErrorMessage(e));
  } catch (e, stackTrace) {
    _logger.e('Unexpected error updating vendor profile: $e');
    _logger.e('Stack trace: $stackTrace');
    throw SettingsRepo('Failed to update vendor profile: ${e.toString()}');
  }
}

  @override
  Future<UserModel> fetchUserProfile() async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.userProfile}/${authStateManager.user!.id}',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Successfully loaded user profile: ${response.data}');
        if (response.data['success'] == true) {
          final userData =
              response.data['user_details'] as Map<String, dynamic>;
          final userModel = UserModel.fromJson(userData);
          authStateManager.updateUser(userModel);
          return userModel;
        }
        throw SettingsRepo("Failed to load user profile: ${response.data}");
      }
      _logger.e('Failed to load user profile: ${response.data}');
      throw SettingsRepo("Failed to load user profile: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error loading user profile: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw SettingsRepo('Authentication failed. Please login again.');
      }

      throw SettingsRepo(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading user profile: $e');
      _logger.e('Stack trace: $stackTrace');
      throw SettingsRepo('Failed to load user profile: ${e.toString()}');
    }
  }

  @override
  Future<bool> updateProfileImage({required MultipartFile profileImage}) async {
    try {
      final formData = FormData.fromMap({
        'user_id': authStateManager.user!.id.toString(),
        'profile_image': profileImage,
      });

      final Response response = await _dio.post(
        AppUrl.updateProfileImage,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Successfully updated profile image: ${response.data}');
        return true;
      }
      _logger.e('Failed to update profile image: ${response.data}');
      return false;
    } on DioException catch (e) {
      _logger.e('Dio error updating profile image: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw SettingsRepo('Authentication failed. Please login again.');
      }

      throw SettingsRepo(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error updating profile image: $e');
      _logger.e('Stack trace: $stackTrace');
      throw SettingsRepo('Failed to update profile image: ${e.toString()}');
    }
  }

  @override
  Future<TransactionSummary> fetchTransactionSummary() async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.userWalletSummary}/${authStateManager.user!.id}',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Successfully loaded Transaction Summary: ${response.data}');

        return TransactionSummary.fromJson(response.data);
      }
      _logger.e('Failed to load  Transaction Summary: ${response.data}');
      throw SettingsRepo(
        "Failed to load  Transaction Summary: ${response.data}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading  Transaction Summary: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw SettingsRepo('Authentication failed. Please login again.');
      }

      throw SettingsRepo(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading  Transaction Summary: $e');
      _logger.e('Stack trace: $stackTrace');
      throw SettingsRepo(
        'Failed to load  Transaction Summary: ${e.toString()}',
      );
    }
  }

  @override
  Future<TransactionResponse> fetchwalletSummary() async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.userWalletTransaction}/${authStateManager.user!.id}',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Successfully loaded Wallet Summary: ${response.data}');

        return TransactionResponse.fromJson(response.data);
      }
      _logger.e('Failed to load  Wallet Summary: ${response.data}');
      throw SettingsRepo("Failed to load  Wallet Summary: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error loading  Wallet Summary: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw SettingsRepo('Authentication failed. Please login again.');
      }

      throw SettingsRepo(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading  Wallet Summary: $e');
      _logger.e('Stack trace: $stackTrace');
      throw SettingsRepo('Failed to load  Wallet Summary: ${e.toString()}');
    }
  }

  @override
  Future<bool> updateUserLocation({
    required int userId,
    required String latitude,
    required String longitude,
    required String timezone,
  }) async {
    try {
      final Response response = await _dio.post(
        '${AppUrl.baseUrl}/user_location_update',
        data: {
          'user_id': userId,
          'latitude': latitude,
          'longitude': longitude,
          "timezone": timezone,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Successfully updated user location: ${response.data}');
        _logger.d('Successfully updated latitude: $latitude');
        _logger.d('Successfully updated longitude: $longitude');
        return response.data['success'] == true;
      }
      _logger.e('Failed to update user location: ${response.data}');
      return false;
    } on DioException catch (e) {
      _logger.e('Dio error updating user location: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw SettingsRepo('Authentication failed. Please login again.');
      }

      throw SettingsRepo(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error updating user location: $e');
      _logger.e('Stack trace: $stackTrace');
      throw SettingsRepo('Failed to update user location: ${e.toString()}');
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

 String? _handleValidationErrors(dynamic responseData) {
  return _extractValidationError(responseData);
}
  String? _extractValidationError(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) return null;

  try {
    // Check for {error: {phone: [...]}} format
    if (responseData['error'] is Map) {
      final errors = responseData['error'] as Map<String, dynamic>;
      final errorMessages = <String>[];

      errors.forEach((field, messages) {
        if (messages is List && messages.isNotEmpty) {
          errorMessages.addAll(messages.map((msg) => msg.toString()));
        } else if (messages is String) {
          errorMessages.add(messages);
        }
      });

      if (errorMessages.isNotEmpty) {
        return errorMessages.join('\n');
      }
    }

    // Check for {errors: {phone: [...]}} format (Laravel style)
    if (responseData['errors'] is Map) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      final errorMessages = <String>[];

      errors.forEach((field, messages) {
        if (messages is List && messages.isNotEmpty) {
          errorMessages.addAll(messages.map((msg) => msg.toString()));
        } else if (messages is String) {
          errorMessages.add(messages);
        }
      });

      if (errorMessages.isNotEmpty) {
        return errorMessages.join('\n');
      }
    }

    // Check for simple message field
    if (responseData['message'] is String) {
      return responseData['message'] as String;
    }
  } catch (e) {
    _logger.e('Error extracting validation error: $e');
  }

  return null;
}
}
