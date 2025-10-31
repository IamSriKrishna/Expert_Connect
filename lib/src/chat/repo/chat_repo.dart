// chat_repo.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/chat_model.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';
import 'dart:async';

class ChatException implements Exception {
  final String message;
  final String? code;

  const ChatException(this.message, {this.code});

  @override
  String toString() => message;
}

abstract class ChatRepo {
  Future<List<ChatMessage>> loadChatHistory(int vendorId);
 Future<bool> sendMessage({
    required int fromUserId,
    required int toUserId,
    required String message,
    File? file, // Added file parameter
  });
  Future<List<ChatListModel>> listChat();
  Future<bool> readChat({required int chatId});
  Future<void> initializePusher({
    required int vendorId,
    required int currentUserId,
    required Function(ChatMessage) onNewMessage,
    required Function(bool) onConnectionStateChange,
  });
  Future<void> disconnectPusher();
  Stream<List<ChatMessage>> watchMessages(int vendorId);
}

class ChatRepoImpl implements ChatRepo {
  final Dio _dio;
  final Logger _logger = Logger();
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  // Pusher configuration
  final String _apiKey = "e8ea0c90b88bb1146a7f";
  final String _cluster = "ap2";

  // Stream controllers
  final StreamController<List<ChatMessage>> _messagesController =
      StreamController<List<ChatMessage>>.broadcast();

  Timer? _pollingTimer;
  List<ChatMessage> _cachedMessages = [];
  bool _isPusherConnected = false;

  ChatRepoImpl({Dio? dio}) : _dio = dio ?? Dio() {
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
  Future<bool> readChat({required int chatId}) async {
    try {
      final Response response = await _dio.post(
        '/messages/mark-read/$chatId',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Message read successfully');
        return true;
      }

      _logger.e('Failed to read message: ${response.data}');
      throw ChatException("Failed to read message: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error reading message: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw ChatException('Authentication failed. Please login again.');
      }

      throw ChatException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error reading message: $e');
      _logger.e('Stack trace: $stackTrace');
      throw ChatException('Failed to read message: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatMessage>> loadChatHistory(int vendorId) async {
    try {
      final Response response = await _dio.get(
        '/chat-history/$vendorId',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.d('Chat history response: $data');

        List<ChatMessage> messages = [];

        // Handle different possible response structures
        if (data is List) {
          messages = data.map((msg) => ChatMessage.fromJson(msg)).toList();
        } else if (data is Map && data.containsKey('messages')) {
          messages = (data['messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          messages = (data['data'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();
        }

        _cachedMessages = messages;
        _messagesController.add(_cachedMessages);
        return messages;
      }

      _logger.e('Failed to load chat history: ${response.data}');
      throw ChatException("Failed to load chat history: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error loading chat history: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw ChatException('Authentication failed. Please login again.');
      }

      throw ChatException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading chat history: $e');
      _logger.e('Stack trace: $stackTrace');
      throw ChatException('Failed to load chat history: ${e.toString()}');
    }
  }


  @override
  Future<bool> sendMessage({
    required int fromUserId,
    required int toUserId,
    required String message,
    File? file,
  }) async {
    try {
      // Create FormData
      FormData formData = FormData.fromMap({
        'from_user_id': fromUserId.toString(),
        'to_user_id': toUserId.toString(),
        'message': message,
      });

      // Add file if provided
      if (file != null) {
        String fileName = file.path.split('/').last;
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ));
      }

      final Response response = await _dio.post(
        '/send-message',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "multipart/form-data",
          },
          sendTimeout: const Duration(minutes: 2), // Increased timeout for file uploads
          receiveTimeout: const Duration(minutes: 2),
        ),
        onSendProgress: (sent, total) {
          if (file != null) {
            double progress = sent / total;
            _logger.d('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        _logger.d('Message sent successfully');
        return true;
      }

      _logger.e('Failed to send message: ${response.data}');
      throw ChatException("Failed to send message: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error sending message: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw ChatException('Authentication failed. Please login again.');
      }

      // Handle file upload specific errors
      if (e.type == DioExceptionType.sendTimeout) {
        throw ChatException('File upload timeout. Please try again with a smaller file.');
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        throw ChatException('Server response timeout. Please check your connection.');
      }

      throw ChatException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error sending message: $e');
      _logger.e('Stack trace: $stackTrace');
      throw ChatException('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatListModel>> listChat() async {
    final id = authStateManager.user!.id;
    try {
      final Response response = await _dio.get(
        '${AppUrl.listChat}/$id',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _logger.d('Successfully loaded Chat List: ${response.data}');

        List<dynamic> data;

        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data.containsKey('data')) {
          data = response.data['data'];
        } else {
          data = [response.data];
        }

        List<ChatListModel> chatList = data
            .map((e) => ChatListModel.fromJson(e))
            .toList();

        return chatList;
      }

      _logger.e('Failed to load Chat List: ${response.data}');
      throw ChatException("Failed to load Chat List: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error loading Chat List: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw ChatException('Authentication failed. Please login again.');
      }

      throw ChatException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading Chat List: $e');
      _logger.e('Stack trace: $stackTrace');
      throw ChatException('Failed to load Chat List: ${e.toString()}');
    }
  }

  @override
  Future<void> initializePusher({
    required int vendorId,
    required int currentUserId,
    required Function(ChatMessage) onNewMessage,
    required Function(bool) onConnectionStateChange,
  }) async {
    try {
      if (!await _isPusherAvailable()) {
        _logger.w('Pusher plugin not available, using polling fallback');
        _startPollingForMessages(vendorId);
        return;
      }

      await _pusher.init(
        apiKey: _apiKey,
        cluster: _cluster,
        onConnectionStateChange: (currentState, previousState) {
          _logger.d('Pusher connection state: $currentState');
          _isPusherConnected = currentState == 'connected';
          onConnectionStateChange(_isPusherConnected);
        },
        onError: (message, code, e) {
          _logger.e('Pusher error: $message, code: $code, exception: $e');
        },
        onEvent: (PusherEvent event) {
          _logger.d('Received pusher event: ${event.eventName}');

          if (event.eventName == 'new-message') {
            final messageData = json.decode(event.data);
            final newMessage = ChatMessage.fromJson(messageData);

            _cachedMessages.add(newMessage);
            _messagesController.add(_cachedMessages);
            onNewMessage(newMessage);
          }
        },
        onSubscriptionSucceeded: (channelName, data) {
          _logger.d('Pusher subscription succeeded for channel: $channelName');
        },
        onSubscriptionError: (message, e) {
          _logger.e('Pusher subscription error: $message, exception: $e');
        },
      );

      // Subscribe to chat channel
      String channelName = 'chat-$vendorId-$currentUserId';
      await _pusher.subscribe(channelName: channelName);
      await _pusher.connect();
    } catch (e) {
      _logger.e('Pusher initialization error: $e');
      // Fallback to polling if Pusher fails
      _startPollingForMessages(vendorId);
    }
  }

  Future<bool> _isPusherAvailable() async {
    try {
      await _pusher.init(apiKey: _apiKey, cluster: _cluster);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _startPollingForMessages(int vendorId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final messages = await loadChatHistory(vendorId);
        if (messages.length > _cachedMessages.length) {
          _cachedMessages = messages;
          _messagesController.add(_cachedMessages);
        }
      } catch (e) {
        _logger.e('Error during polling: $e');
      }
    });
  }

  @override
  Future<void> disconnectPusher() async {
    try {
      _pollingTimer?.cancel();
      await _pusher.disconnect();
    } catch (e) {
      _logger.e('Error disconnecting pusher: $e');
    }
  }

  @override
  Stream<List<ChatMessage>> watchMessages(int vendorId) {
    return _messagesController.stream;
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


  void dispose() {
    _pollingTimer?.cancel();
    _messagesController.close();
  }
}
