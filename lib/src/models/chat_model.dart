class ChatUser {
  final int id;
  final String name;

  ChatUser({
    required this.id,
    required this.name,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ChatMessage {
  final int id;
  final int fromUserId;
  final int toUserId;
  final String message;
  final String? fileUrl;
  final String? fileType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatUser? sender;
  final ChatUser? receiver;
  
  // Local UI state properties
  final bool isSent;
  final bool hasError;
  final bool isUploading;
  final double uploadProgress;

  ChatMessage({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.message,
    this.fileUrl,
    this.fileType,
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
    this.isSent = false,
    this.hasError = false,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  bool get hasAttachment => fileUrl != null && fileUrl!.isNotEmpty;
  bool get isImage => fileType?.startsWith('image/') == true;
  bool get isVideo => fileType?.startsWith('video/') == true;
  bool get isDocument => !isImage && !isVideo && hasAttachment;
  
  String? get fileName {
    if (fileUrl == null) return null;
    return fileUrl!.split('/').last;
  }

  // For compatibility with existing timestamp usage
  DateTime get timestamp => createdAt;

  ChatMessage copyWith({
    int? id,
    int? fromUserId,
    int? toUserId,
    String? message,
    String? fileUrl,
    String? fileType,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChatUser? sender,
    ChatUser? receiver,
    bool? isSent,
    bool? hasError,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      message: message ?? this.message,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      isSent: isSent ?? this.isSent,
      hasError: hasError ?? this.hasError,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      fromUserId: json['from_user_id'],
      toUserId: json['to_user_id'],
      message: json['message'] ?? '',
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      isRead: json['is_read'] == 1,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      sender: json['sender'] != null ? ChatUser.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? ChatUser.fromJson(json['receiver']) : null,
      isSent: true, // Messages from API are already sent
      hasError: false,
      isUploading: false,
      uploadProgress: 0.0,
    );
  }

  static DateTime _parseDateTime(String dateString) {
    try {
      // Parse format: "28-08-2025 11:51:45"
      final parts = dateString.split(' ');
      final dateParts = parts[0].split('-');
      final timeParts = parts[1].split(':');
      
      return DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
        int.parse(timeParts[2]), // second
      );
    } catch (e) {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'message': message,
      'file_url': fileUrl,
      'file_type': fileType,
      'is_read': isRead ? 1 : 0,
      'created_at': _formatDateTime(createdAt),
      'updated_at': _formatDateTime(updatedAt),
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
    };
  }

  static String _formatDateTime(DateTime dateTime) {
    // Format to: "28-08-2025 11:51:45"
    return '${dateTime.day.toString().padLeft(2, '0')}-'
           '${dateTime.month.toString().padLeft(2, '0')}-'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  // Factory constructor for creating temporary messages (before sending to server)
  factory ChatMessage.temporary({
    required int fromUserId,
    required int toUserId,
    required String message,
    String? fileUrl,
    String? fileType,
  }) {
    final now = DateTime.now();
    return ChatMessage(
      id: now.millisecondsSinceEpoch, // Temporary ID
      fromUserId: fromUserId,
      toUserId: toUserId,
      message: message,
      fileUrl: fileUrl,
      fileType: fileType,
      createdAt: now,
      updatedAt: now,
      isSent: false,
      isUploading: fileUrl != null,
    );
  }
}
class ChatListModel {
  final int userId;
  final int chatId;
  final String name;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final bool online;

  ChatListModel({
    required this.userId,
    required this.name,
    required this.lastMessage,
    required this.chatId,
    required this.lastTime,
    required this.unreadCount,
    required this.online,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      chatId: json['chat_id'] ?? 0,
      lastMessage: json['last_message'] ?? '',
      lastTime: json['last_time'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      online: json['online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'chat_id': chatId,
      'name': name,
      'last_message': lastMessage,
      'last_time': lastTime,
      'unread_count': unreadCount,
      'online': online,
    };
  }
}