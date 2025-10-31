
part of 'chat_bloc.dart';

enum ChatStatus { 
  loading, 
  loaded, 
  failed, 
  success, 
  failure, 
  read,
  initializing,
  initialized,
  loadingHistory,
  historyLoaded,
  sending,
  messageSent,
  messageError,
  messagesUpdated,
  connected,
  disconnected,
  typing,
  notTyping,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatListModel> chat;
  final List<ChatMessage> messages;
  final bool isConnected;
  final bool isTyping;
  final int? currentUserId;
  final int? vendorId;
  final String? errorMessage;

  const ChatState({
    required this.status,
    required this.chat,
    this.messages = const [],
    this.isConnected = false,
    this.isTyping = false,
    this.currentUserId,
    this.vendorId,
    this.errorMessage,
  });

  factory ChatState.initial() {
    return const ChatState(
      status: ChatStatus.loading, 
      chat: [],
      messages: [],
      isConnected: false,
      isTyping: false,
    );
  }

  ChatState copyWith({
    ChatStatus? status,
    List<ChatListModel>? chat,
    List<ChatMessage>? messages,
    bool? isConnected,
    bool? isTyping,
    int? currentUserId,
    int? vendorId,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isConnected: isConnected ?? this.isConnected,
      isTyping: isTyping ?? this.isTyping,
      currentUserId: currentUserId ?? this.currentUserId,
      vendorId: vendorId ?? this.vendorId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    chat, 
    messages, 
    isConnected, 
    isTyping, 
    currentUserId, 
    vendorId, 
    errorMessage,
  ];
}