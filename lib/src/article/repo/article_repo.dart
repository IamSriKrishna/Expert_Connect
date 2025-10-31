import 'package:dio/dio.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/article_vendor_list.dart';
import 'package:logger/logger.dart';

class ArticleRepoException implements Exception {
  final String message;
  final String? code;

  const ArticleRepoException(this.message, {this.code});

  @override
  String toString() => message;
}

abstract class ArticleRepo {
  Future<List<ArticleVendorList>> getArticleVendorList();
}

class ArticleRepoImpl implements ArticleRepo {
  final Dio _dio;
  final Logger _logger = Logger();

  ArticleRepoImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppUrl.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);

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
  Future<List<ArticleVendorList>> getArticleVendorList() async {
    try {
      final Response response = await _dio.get(
        AppUrl.getArticleVendorList,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data['success'] == "true") {
        _logger.d('Successfully loaded getArticleVendorList: ${response.data}');

        List<dynamic> data = response.data['indexdata'];
        List<ArticleVendorList> listAppointment = data
            .map((e) => ArticleVendorList.fromJson(e))
            .toList();

        return listAppointment;
      }
      _logger.e('Failed to load listAppointment: ${response.data}');
      throw ArticleRepoException(
        "Failed to load getArticleVendorList: ${response.data}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading getArticleVendorList: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw ArticleRepoException(
          'Authentication failed. Please login again.',
        );
      }

      throw ArticleRepoException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading getArticleVendorList: $e');
      _logger.e('Stack trace: $stackTrace');
      throw ArticleRepoException(
        'Failed to load getArticleVendorList: ${e.toString()}',
      );
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
}
