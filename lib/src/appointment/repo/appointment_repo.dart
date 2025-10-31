import 'package:dio/dio.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/appointment_model.dart';
import 'package:logger/logger.dart';

class AppointmentException implements Exception {
  final String message;
  final String? code;

  const AppointmentException(this.message, {this.code});

  @override
  String toString() => message;
}

// Enum for meeting activity types
enum MeetingActivityType { start, end }

// Model for meeting activity request
class MeetingActivityRequest {
  final int meetingId;
  final int userId;
  final MeetingActivityType type;

  MeetingActivityRequest({
    required this.meetingId,
    required this.userId,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'meeting_id': meetingId,
      'user_id': userId,
      'type': type.name,
    };
  }
}

// Model for meeting activity response
class MeetingActivityResponse {
  final bool success;
  final String message;
  final dynamic data;

  MeetingActivityResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MeetingActivityResponse.fromJson(Map<String, dynamic> json) {
    return MeetingActivityResponse(
      success: json['success'] == "true" || json['success'] == true,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

abstract class AppointmentRepo {
  Future<List<AppointmentData>> listAppointment();
  Future<MeetingActivityResponse> startMeeting(int meetingId);
  Future<MeetingActivityResponse> endMeeting(int meetingId);
}

class AppointmentImpl implements AppointmentRepo {
  final Dio _dio;
  final Logger _logger = Logger();

  AppointmentImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppUrl.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    
    // IMPORTANT: Configure Dio to handle redirects properly
    _dio.options.followRedirects = false; // Don't follow redirects automatically
    _dio.options.maxRedirects = 0; // Prevent automatic redirect handling
    
    // Alternative: Allow following redirects but increase max count
    // _dio.options.followRedirects = true;
    // _dio.options.maxRedirects = 3;
    
    // Custom status code validation to handle 302 as a valid response
    _dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 400; // Accept 2xx and 3xx
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.uri}');
          _logger.d('Request Data: ${options.data}');
          _logger.d('Request Headers: ${options.headers}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          _logger.d('Response Data: ${response.data}');
          _logger.d('Response Headers: ${response.headers}');
          
          // Handle redirect responses specifically
          if (response.statusCode == 302 || response.statusCode == 301) {
            _logger.w('Received redirect response. Location: ${response.headers['location']}');
            // You might want to handle this differently based on your needs
          }
          
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('HTTP Error: ${error.message}');
          _logger.e('Error Type: ${error.type}');
          if (error.response != null) {
            _logger.e('Error Response Status: ${error.response?.statusCode}');
            _logger.e('Error Response Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<List<AppointmentData>> listAppointment() async {
    final id = authStateManager.user!.id;
    try {
      final Response response = await _dio.get(
        '${AppUrl.listAppointment}/$id',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      // Handle potential redirect response
      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location']?.first;
        _logger.w('API returned redirect to: $redirectUrl');
        throw AppointmentException(
          'API endpoint is redirecting. Please check your server configuration.',
          code: 'REDIRECT_ERROR',
        );
      }

      if (response.data['success'] == "true"||response.data['success'] == true) {
        _logger.d('Successfully loaded listAppointment: ${response.data}');

        List<dynamic> data = response.data['indexdata'];
        List<AppointmentData> listAppointment = data
            .map((e) => AppointmentData.fromJson(e))
            .toList();

        return listAppointment;
      }
      _logger.e('Failed to load listAppointment: ${response.data}');
      throw AppointmentException(
        "Failed to load listAppointment: ${response.data}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading listAppointment: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
        
        // Handle redirect error specifically
        if (e.response?.statusCode == 302 || e.response?.statusCode == 301) {
          final redirectUrl = e.response?.headers['location']?.first;
          throw AppointmentException(
            'Server is redirecting to: $redirectUrl. Please check your API endpoint configuration.',
            code: 'REDIRECT_ERROR',
          );
        }
      }

      if (e.response?.statusCode == 401) {
        throw AppointmentException(
          'Authentication failed. Please login again.',
        );
      }

      throw AppointmentException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading listAppointment: $e');
      _logger.e('Stack trace: $stackTrace');
      throw AppointmentException(
        'Failed to load listAppointment: ${e.toString()}',
      );
    }
  }

  @override
  Future<MeetingActivityResponse> startMeeting(int meetingId) async {
    return _handleMeetingActivity(meetingId, MeetingActivityType.start);
  }

  @override
  Future<MeetingActivityResponse> endMeeting(int meetingId) async {
    return _handleMeetingActivity(meetingId, MeetingActivityType.end);
  }

  Future<MeetingActivityResponse> _handleMeetingActivity(
    int meetingId,
    MeetingActivityType type,
  ) async {
    final userId = authStateManager.user!.id;
    
    final request = MeetingActivityRequest(
      meetingId: meetingId,
      userId: userId,
      type: type,
    );

    try {
      _logger.d('${type.name.toUpperCase()} meeting activity for meeting: $meetingId, user: $userId');

      // Verify the endpoint URL is correct
      final endpoint = '${AppUrl.baseUrl}/meeting/activity';
      _logger.d('Making request to: $endpoint');

      final Response response = await _dio.post(
        endpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
            "Accept": "application/json", // Explicitly request JSON response
          },
        ),
      );

      _logger.d('Meeting activity response status: ${response.statusCode}');
      _logger.d('Meeting activity response: ${response.data}');

      // Handle redirect response
      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location']?.first;
        _logger.e('API endpoint is redirecting to: $redirectUrl');
        throw AppointmentException(
          'Server is redirecting requests. Please verify your API endpoint URL and server configuration.',
          code: 'REDIRECT_ERROR',
        );
      }

      // Check if response is HTML (indicates redirect page)
      if (response.data is String && response.data.toString().contains('<html>')) {
        _logger.e('Received HTML response instead of JSON - likely a redirect page');
        throw AppointmentException(
          'Server returned HTML instead of JSON. Please check your API endpoint configuration.',
          code: 'HTML_RESPONSE_ERROR',
        );
      }

      final activityResponse = MeetingActivityResponse.fromJson(response.data);
      
      if (activityResponse.success) {
        _logger.d('Successfully ${type.name}ed meeting: $meetingId');
        return activityResponse;
      } else {
        _logger.e('Failed to ${type.name} meeting: ${activityResponse.message}');
        throw AppointmentException(
          'Failed to ${type.name} meeting: ${activityResponse.message}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Dio error ${type.name}ing meeting: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
        
        // Specific handling for redirect errors
        if (e.response?.statusCode == 302 || e.response?.statusCode == 301) {
          final redirectUrl = e.response?.headers['location']?.first;
          throw AppointmentException(
            'Server is redirecting to: $redirectUrl. This usually means:\n'
            '1. The API endpoint URL is incorrect\n'
            '2. Server configuration needs to be fixed\n'
            '3. Authentication token might be invalid',
            code: 'REDIRECT_ERROR',
          );
        }
      }

      if (e.response?.statusCode == 401) {
        throw AppointmentException(
          'Authentication failed. Please login again.',
        );
      }

      throw AppointmentException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error ${type.name}ing meeting: $e');
      _logger.e('Stack trace: $stackTrace');
      throw AppointmentException(
        'Failed to ${type.name} meeting: ${e.toString()}',
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

        // Handle redirect responses
        if (statusCode == 302 || statusCode == 301) {
          final redirectUrl = error.response?.headers['location']?.first;
          return 'Server is redirecting to: $redirectUrl. Please check your API configuration.';
        }

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
          return errorMessages.first; 
        }
      }

      if (responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
    }

    return null;
  }
}