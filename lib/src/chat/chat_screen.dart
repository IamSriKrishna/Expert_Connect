import 'dart:async';
import 'package:expert_connect/src/chat/bloc/chat_bloc.dart';
import 'package:expert_connect/src/chat/repo/chat_repo.dart';
import 'package:expert_connect/src/chat/widgets/chat_widgets.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatBloc _chatBloc;
  Timer? _timer;
  bool _isDisposed = false;
  
  // Add TextEditingController for search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatBloc = ChatBloc(chatRepository: ChatRepoImpl())..add(FetchChatList());
    _startTimer();
    
    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel existing timer if any
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      // Check if widget is still mounted and BLoC is not closed
      if (!_isDisposed && mounted && !_chatBloc.isClosed) {
        try {
          _chatBloc.add(FetchChatList());
        } catch (e) {
          // Handle any errors gracefully
          print('Error adding FetchChatList event: $e');
          _stopTimer(); // Stop timer if there's an error
        }
      } else {
        // Stop timer if conditions are not met
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (_isDisposed) return;
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _stopTimer(); // Stop timer when app goes to background
        break;
      case AppLifecycleState.resumed:
        if (mounted && !_chatBloc.isClosed) {
          _startTimer(); // Resume timer when app comes to foreground
        }
        break;
      default:
        break;
    }
  }

  @override
  void deactivate() {
    // Called when widget is removed from the tree temporarily
    _stopTimer();
    super.deactivate();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    
    // Dispose search controller
    _searchController.dispose();
    
    // Only close BLoC if it's not already closed
    if (!_chatBloc.isClosed) {
      _chatBloc.close();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatBloc,
      child: BlocBuilder<ChatBloc, ChatState>(
        bloc: _chatBloc,
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                CommonWidgets.appBar(
                  text: "Messenger"
                ),
                // Pass the search controller to the search bar
                ChatWidgets.buildSearchBar(_searchController),
                // Pass the search query to filter the chat list
                ChatWidgets.buildChatList(state, _chatBloc, _searchQuery),
                
              ],
            ),
          );
        },
      ),
    );
  }
}