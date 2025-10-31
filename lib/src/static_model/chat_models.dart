class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;
  final int unreadCount;
  final bool isOnline;
  final List<MessageModel> messages;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.messages,
  });
}
class MessageModel {
  final String id;
  final String message;
  final String time;
  final bool isSentByMe;
  final MessageType type;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.message,
    required this.time,
    required this.isSentByMe,
    this.type = MessageType.text,
    this.isRead = true,
  });
}

enum MessageType { text, image, voice, document }


  List<ChatModel> getDummyChats() {
    return [
      ChatModel(
        id: '1',
        name: 'Dr. Sarah Johnson',
        lastMessage: 'Thanks for the consultation, I\'ll follow up tomorrow.',
        time: '2:30 PM',
        avatar: '',
        unreadCount: 2,
        isOnline: true,
        messages: getDummyMessages('1'),
      ),
      ChatModel(
        id: '2',
        name: 'Expert Team',
        lastMessage: 'Your appointment is confirmed for tomorrow at 10 AM',
        time: '1:15 PM',
        avatar: '',
        unreadCount: 0,
        isOnline: false,
        messages: getDummyMessages('2'),
      ),
      ChatModel(
        id: '3',
        name: 'Dr. Michael Chen',
        lastMessage: 'Please review the documents I sent earlier',
        time: '11:45 AM',
        avatar: '',
        unreadCount: 1,
        isOnline: true,
        messages: getDummyMessages('3'),
      ),
      ChatModel(
        id: '4',
        name: 'Support Team',
        lastMessage: 'How can we help you today?',
        time: 'Yesterday',
        avatar: '',
        unreadCount: 0,
        isOnline: false,
        messages: getDummyMessages('4'),
      ),
      ChatModel(
        id: '5',
        name: 'Dr. Emily Davis',
        lastMessage: 'The test results look good. Let\'s schedule a follow-up.',
        time: 'Yesterday',
        avatar: '',
        unreadCount: 0,
        isOnline: true,
        messages: getDummyMessages('5'),
      ),
    ];
  }

  List<MessageModel> getDummyMessages(String chatId) {
    switch (chatId) {
      case '1':
        return [
          MessageModel(id: '1', message: 'Hello Dr. Johnson, I need a consultation', time: '2:00 PM', isSentByMe: true),
          MessageModel(id: '2', message: 'Of course! What seems to be the issue?', time: '2:05 PM', isSentByMe: false),
          MessageModel(id: '3', message: 'I\'ve been experiencing some symptoms lately', time: '2:10 PM', isSentByMe: true),
          MessageModel(id: '4', message: 'Let me schedule an appointment for you', time: '2:25 PM', isSentByMe: false),
          MessageModel(id: '5', message: 'Thanks for the consultation, I\'ll follow up tomorrow.', time: '2:30 PM', isSentByMe: false),
        ];
      case '2':
        return [
          MessageModel(id: '1', message: 'Hi, I\'d like to book an appointment', time: '1:00 PM', isSentByMe: true),
          MessageModel(id: '2', message: 'Your appointment is confirmed for tomorrow at 10 AM', time: '1:15 PM', isSentByMe: false),
        ];
      default:
        return [
          MessageModel(id: '1', message: 'Hello!', time: '10:00 AM', isSentByMe: true),
          MessageModel(id: '2', message: 'Hi there! How can I help you?', time: '10:05 AM', isSentByMe: false),
        ];
    }
  }
