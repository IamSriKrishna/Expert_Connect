class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? readAt;
  final String createdAt;
  final String notifiableUserId;
  final Map<String, dynamic>? data;
  final String isMessage;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.readAt,
    required this.createdAt,
    required this.notifiableUserId,
    this.data,
    required this.isMessage,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
      notifiableUserId: json['notifiable_user_id'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isMessage: json['is_message'] as String,
    );
  }

  // Helper getter to check if this is a message notification
  bool get isMessageNotification => isMessage == "1";

  // Helper getters to access data fields safely
  int? get senderId => data?['senderid'] as int?;
  String? get senderName => data?['sendername'] as String?;
  int? get receiverId => data?['receiverid'] as int?;
  String? get receiverName => data?['receivername'] as String?;
  bool? get isChat => data?['chat'] as bool?;
}