import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:expert_connect/src/chat/repo/chat_repo.dart';
import 'package:expert_connect/src/models/chat_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepo chatRepository;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  ChatBloc({required this.chatRepository}) : super(ChatState.initial()) {
    on<FetchChatList>(_onFetchChatList);
    on<ReadMessage>(_onReadMessage);
    on<InitializeChat>(_onInitializeChat);
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<UpdateMessageStatus>(_onUpdateMessageStatus);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<ConnectionStateChanged>(_onConnectionStateChanged);
    on<ShowTypingIndicator>(_onShowTypingIndicator);
    on<HideTypingIndicator>(_onHideTypingIndicator);
    on<DisconnectChat>(_onDisconnectChat);
  }

  Future<void> _onFetchChatList(
    FetchChatList event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ChatStatus.loading));

      final chatList = await chatRepository.listChat();

      emit(state.copyWith(status: ChatStatus.loaded, chat: chatList));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failed, errorMessage: e.toString()));
      rethrow;
    }
  }

  Future<void> _onReadMessage(
    ReadMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final success = await chatRepository.readChat(chatId: event.chatId);
      if (success) {
        emit(state.copyWith(status: ChatStatus.read));
      }
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failed, errorMessage: e.toString()));
      rethrow;
    }
  }

  Future<void> _onInitializeChat(
    InitializeChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: ChatStatus.initializing,
        currentUserId: event.currentUserId,
        vendorId: event.vendorId,
      ));

      // Load chat history first
      add(LoadChatHistory(vendorId: event.vendorId));

      // Initialize real-time updates
      await chatRepository.initializePusher(
        vendorId: event.vendorId,
        currentUserId: event.currentUserId,
        onNewMessage: (message) {
          // Handle new message via event
          add(MessagesUpdated(messages: [...state.messages, message]));
        },
        onConnectionStateChange: (isConnected) {
          add(ConnectionStateChanged(isConnected: isConnected));
        },
      );

      // Subscribe to message stream
      _messagesSubscription = chatRepository
          .watchMessages(event.vendorId)
          .listen(
            (messages) {
              add(MessagesUpdated(messages: messages));
            },
            onError: (error) {
              add(ChatEvent.error(error.toString()));
            },
          );

      emit(state.copyWith(status: ChatStatus.initialized));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failed,
        errorMessage: 'Failed to initialize chat: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ChatStatus.loadingHistory));

      final messages = await chatRepository.loadChatHistory(event.vendorId);

      emit(state.copyWith(
        status: ChatStatus.historyLoaded,
        messages: messages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failed,
        errorMessage: 'Failed to load chat history: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Create optimistic message
    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      fromUserId: event.fromUserId,
      toUserId: event.toUserId,
      message: event.message,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSent: false,
    );

    // Add message to UI immediately (optimistic update)
    final updatedMessages = [...state.messages, tempMessage];
    emit(state.copyWith(
      messages: updatedMessages,
      status: ChatStatus.sending,
    ));

    try {
      // Send to server
      final success = await chatRepository.sendMessage(
        fromUserId: event.fromUserId,
        toUserId: event.toUserId,
        message: event.message,
      );

      if (success) {
        // Update message status to sent
        add(UpdateMessageStatus(
          messageId: tempMessage.id,
          isSent: true,
          hasError: false,
        ));
      } else {
        // Mark message as error
        add(UpdateMessageStatus(
          messageId: tempMessage.id,
          isSent: false,
          hasError: true,
        ));
      }
    } catch (e) {
      // Mark message as error
      add(UpdateMessageStatus(
        messageId: tempMessage.id,
        isSent: false,
        hasError: true,
      ));
      
      emit(state.copyWith(
        status: ChatStatus.failed,
        errorMessage: 'Failed to send message: ${e.toString()}',
      ));
    }
  }

  void _onUpdateMessageStatus(
    UpdateMessageStatus event,
    Emitter<ChatState> emit,
  ) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == event.messageId) {
        return msg.copyWith(
          isSent: event.isSent,
          hasError: event.hasError,
        );
      }
      return msg;
    }).toList();

    emit(state.copyWith(
      messages: updatedMessages,
      status: event.isSent ? ChatStatus.messageSent : ChatStatus.messageError,
    ));
  }

  void _onMessagesUpdated(
    MessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      messages: event.messages,
      status: ChatStatus.messagesUpdated,
    ));
  }

  void _onConnectionStateChanged(
    ConnectionStateChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      isConnected: event.isConnected,
      status: event.isConnected ? ChatStatus.connected : ChatStatus.disconnected,
    ));
  }

  void _onShowTypingIndicator(
    ShowTypingIndicator event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      isTyping: true,
      status: ChatStatus.typing,
    ));
  }

  void _onHideTypingIndicator(
    HideTypingIndicator event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(
      isTyping: false,
      status: ChatStatus.notTyping,
    ));
  }

  Future<void> _onDisconnectChat(
    DisconnectChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await _messagesSubscription?.cancel();
      await chatRepository.disconnectPusher();
      
      emit(state.copyWith(
        status: ChatStatus.disconnected,
        isConnected: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failed,
        errorMessage: 'Failed to disconnect: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
