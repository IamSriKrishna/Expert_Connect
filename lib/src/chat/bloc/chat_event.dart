
part of 'chat_bloc.dart';

class ChatEvent extends Equatable {
  const ChatEvent();
  
  @override
  List<Object?> get props => [];

  factory ChatEvent.error(String message) => ErrorOccurred(message: message);
}

class FetchChatList extends ChatEvent {
  const FetchChatList();
  
  @override
  List<Object?> get props => [];
}

class ReadMessage extends ChatEvent {
  final int chatId;
  
  const ReadMessage({required this.chatId});
  
  @override
  List<Object?> get props => [chatId];
}

class InitializeChat extends ChatEvent {
  final int vendorId;
  final int currentUserId;
  
  const InitializeChat({
    required this.vendorId, 
    required this.currentUserId,
  });
  
  @override
  List<Object?> get props => [vendorId, currentUserId];
}

class LoadChatHistory extends ChatEvent {
  final int vendorId;
  
  const LoadChatHistory({required this.vendorId});
  
  @override
  List<Object?> get props => [vendorId];
}

class SendMessage extends ChatEvent {
  final int fromUserId;
  final int toUserId;
  final String message;
  
  const SendMessage({
    required this.fromUserId,
    required this.toUserId,
    required this.message,
  });
  
  @override
  List<Object?> get props => [fromUserId, toUserId, message];
}

class UpdateMessageStatus extends ChatEvent {
  final int messageId;
  final bool isSent;
  final bool hasError;
  
  const UpdateMessageStatus({
    required this.messageId,
    required this.isSent,
    required this.hasError,
  });
  
  @override
  List<Object?> get props => [messageId, isSent, hasError];
}

class MessagesUpdated extends ChatEvent {
  final List<ChatMessage> messages;
  
  const MessagesUpdated({required this.messages});
  
  @override
  List<Object?> get props => [messages];
}

class ConnectionStateChanged extends ChatEvent {
  final bool isConnected;
  
  const ConnectionStateChanged({required this.isConnected});
  
  @override
  List<Object?> get props => [isConnected];
}

class ShowTypingIndicator extends ChatEvent {
  const ShowTypingIndicator();
  
  @override
  List<Object?> get props => [];
}

class HideTypingIndicator extends ChatEvent {
  const HideTypingIndicator();
  
  @override
  List<Object?> get props => [];
}

class DisconnectChat extends ChatEvent {
  const DisconnectChat();
  
  @override
  List<Object?> get props => [];
}

class ErrorOccurred extends ChatEvent {
  final String message;
  
  const ErrorOccurred({required this.message});
  
  @override
  List<Object?> get props => [message];
}