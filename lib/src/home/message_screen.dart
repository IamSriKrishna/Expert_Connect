import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/chat/bloc/chat_bloc.dart';
import 'package:expert_connect/src/chat/repo/chat_repo.dart';
import 'package:expert_connect/src/chat/widgets/message_widgets.dart';
import 'package:expert_connect/src/home/widgets/chat_shimmer.dart';
import 'package:expert_connect/src/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class MessageScreen extends StatefulWidget {
  final int vendorId;
  final bool isFromChatScreen;
  final String vendorName;
  final ChatBloc? chatBloc;

  const MessageScreen({
    super.key,
    required this.vendorId,
    required this.chatBloc,
    required this.vendorName,
    required this.isFromChatScreen,
  });

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with TickerProviderStateMixin {
  // Repository
  late final ChatRepo _chatRepo;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State variables
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isConnected = false;
  late int _currentUserId;
  bool _isTyping = false;

  // File handling
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedFile;
  bool _isUploading = false;

  // Stream subscription
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  // Real-time update timer
  Timer? _realtimeTimer;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _currentUserId = authStateManager.user!.id;
    _chatRepo = ChatRepoImpl();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeChat();
    _startRealtimeUpdates();
  }

  void _startRealtimeUpdates() {
    // Start a timer that updates the chat every second
    _realtimeTimer = Timer.periodic(const Duration(milliseconds: 2500), (
      timer,
    ) {
      if (mounted) {
        _fetchLatestMessages();
      }
    });
  }

  Future<void> _fetchLatestMessages() async {
    try {
      // Don't show loading state for periodic updates
      final messages = await _chatRepo.loadChatHistory(widget.vendorId);

      if (mounted) {
        // Only update if we have new messages or changes
        if (_shouldUpdateMessages(messages)) {
          final wasAtBottom = _isScrolledToBottom();

          setState(() {
            _messages = messages;
            _lastUpdateTime = DateTime.now();

            // Clear uploading state if we received new messages that aren't uploading
            if (messages.isNotEmpty &&
                !messages.any((msg) => msg.isUploading)) {
              _isUploading = false;
            }
          });

          _debugPrintMessages(messages);

          // Only auto-scroll if user was already at bottom
          if (wasAtBottom) {
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      // Silently handle periodic update errors to avoid spam
      debugPrint('Periodic update error: $e');
    }
  }

  bool _shouldUpdateMessages(List<ChatMessage> newMessages) {
    // Check if message count changed
    if (newMessages.length != _messages.length) {
      return true;
    }

    // Check if any message content changed (for status updates, etc.)
    for (int i = 0; i < newMessages.length; i++) {
      final oldMsg = _messages[i];
      final newMsg = newMessages[i];

      if (oldMsg.id != newMsg.id ||
          oldMsg.isSent != newMsg.isSent ||
          oldMsg.isUploading != newMsg.isUploading ||
          oldMsg.hasError != newMsg.hasError ||
          oldMsg.fileUrl != newMsg.fileUrl ||
          oldMsg.timestamp != newMsg.timestamp) {
        // Add timestamp check
        return true;
      }
    }

    return false;
  }

  bool _isScrolledToBottom() {
    if (!scrollController.hasClients) return true;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    // Consider "bottom" if within 100 pixels of the actual bottom
    return (maxScroll - currentScroll) < 100;
  }

  Future<void> _initializeChat() async {
    try {
      // Load chat history
      await _loadChatHistory();

      // Initialize real-time updates
      await _initializeRealTimeUpdates();

      // Subscribe to message stream
      _messagesSubscription = _chatRepo
          .watchMessages(widget.vendorId)
          .listen(
            (messages) {
              if (mounted) {
                final wasAtBottom = _isScrolledToBottom();

                setState(() {
                  _messages = messages;
                  _lastUpdateTime = DateTime.now();
                });

                // Debug: Print message details
                _debugPrintMessages(messages);

                // Only auto-scroll if user was at bottom or if it's a new message from current user
                if (wasAtBottom || _isNewMessageFromCurrentUser(messages)) {
                  _scrollToBottom();
                }
              }
            },
            onError: (error) {
              _showError('Failed to receive messages: $error');
            },
          );
    } catch (e) {
      _showError('Failed to initialize chat: $e');
    }
  }

  bool _isNewMessageFromCurrentUser(List<ChatMessage> messages) {
    if (messages.isEmpty || _messages.isEmpty) return false;

    // Check if the last message is new and from current user
    final latestMessage = messages.last;
    final wasLastMessage = _messages.length > 0 ? _messages.last : null;

    return wasLastMessage?.id != latestMessage.id &&
        latestMessage.fromUserId == _currentUserId;
  }

  // Debug method to print message details
  void _debugPrintMessages(List<ChatMessage> messages) {
    debugPrint(
      "DEBUG: Total messages: ${messages.length} (Updated: ${DateTime.now()})",
    );
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (msg.hasAttachment) {
        debugPrint("DEBUG: Message $i - ID: ${msg.id}");
        debugPrint("  - fileUrl: ${msg.fileUrl}");
        debugPrint("  - fileType: ${msg.fileType}");
        debugPrint("  - fileName: ${msg.fileName}");
        debugPrint("  - isImage: ${msg.isImage}");
        debugPrint("  - isVideo: ${msg.isVideo}");
        debugPrint("  - hasAttachment: ${msg.hasAttachment}");
        debugPrint("  - isUploading: ${msg.isUploading}");
        debugPrint("  - isSent: ${msg.isSent}");
        debugPrint("  - hasError: ${msg.hasError}");
      }
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final messages = await _chatRepo.loadChatHistory(widget.vendorId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
          _lastUpdateTime = DateTime.now();
        });
        _animationController.forward();
        _debugPrintMessages(messages);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showError('Failed to load chat history: $e');
    }
  }

  Future<void> _initializeRealTimeUpdates() async {
    try {
      await _chatRepo.initializePusher(
        vendorId: widget.vendorId,
        currentUserId: _currentUserId,
        onNewMessage: (message) {
          // Handle new message if needed
          debugPrint('Real-time message received: ${message.message}');
        },
        onConnectionStateChange: (isConnected) {
          if (mounted) {
            setState(() {
              _isConnected = isConnected;
            });

            // If reconnected, fetch latest messages immediately
            if (isConnected) {
              _fetchLatestMessages();
            }
          }
        },
      );
    } catch (e) {
      _showError('Failed to initialize real-time updates: $e');
    }
  }

  void sendMessage() {
    final messageText = messageController.text.trim();

    if (messageText.isEmpty && _selectedFile == null) return;

    debugPrint("DEBUG: sendMessage() called");
    debugPrint("DEBUG: _selectedFile: ${_selectedFile?.path}");
    debugPrint("DEBUG: _selectedFile exists: ${_selectedFile?.existsSync()}");

    messageController.clear();

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Store file reference before clearing UI state
    final fileToSend = _selectedFile;

    debugPrint("DEBUG: fileToSend: ${fileToSend?.path}");
    debugPrint("DEBUG: fileToSend exists: ${fileToSend?.existsSync()}");

    // Create temp message with enhanced file info
    final tempMessage = ChatMessage.temporary(
      fromUserId: _currentUserId,
      toUserId: widget.vendorId,
      message: messageText,
      fileType: _getFileType(fileToSend),
      // For local preview, use file path temporarily
      fileUrl: fileToSend?.path,
    );

    debugPrint("DEBUG: tempMessage created:");
    debugPrint("  - fileType: ${tempMessage.fileType}");
    debugPrint("  - fileUrl: ${tempMessage.fileUrl}");
    debugPrint("  - isImage: ${tempMessage.isImage}");
    debugPrint("  - hasAttachment: ${tempMessage.hasAttachment}");

    setState(() {
      _messages.add(tempMessage);
      _isTyping = false;
      _isUploading = fileToSend != null;
      // Clear selected file from UI immediately
      _selectedFile = null;
    });
    _scrollToBottom();

    debugPrint(
      "DEBUG: About to call _sendToServer with file: ${fileToSend?.path}",
    );

    // Send to server with the stored file reference
    _sendToServer(tempMessage, fileToSend);
  }

  String? _getFileType(File? file) {
    if (file == null) return null;

    final extension = file.path.split('.').last.toLowerCase();
    debugPrint("DEBUG: File extension detected: $extension");

    String fileType;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        fileType = 'image/jpeg';
        break;
      case 'png':
        fileType = 'image/png';
        break;
      case 'gif':
        fileType = 'image/gif';
        break;
      case 'webp':
        fileType = 'image/webp';
        break;
      case 'bmp':
        fileType = 'image/bmp';
        break;
      case 'mp4':
        fileType = 'video/mp4';
        break;
      case 'mov':
        fileType = 'video/mov';
        break;
      case 'avi':
        fileType = 'video/avi';
        break;
      case 'pdf':
        fileType = 'application/pdf';
        break;
      case 'doc':
        fileType = 'application/msword';
        break;
      case 'docx':
        fileType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        break;
      case 'xlsx':
        fileType =
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        break;
      default:
        fileType = 'application/octet-stream';
    }

    debugPrint("DEBUG: File type determined: $fileType");
    return fileType;
  }

  Future<void> _sendToServer(ChatMessage tempMessage, File? file) async {
    try {
      debugPrint("DEBUG: _sendToServer called");
      debugPrint("DEBUG: file parameter: ${file?.path}");
      debugPrint("DEBUG: file exists: ${file?.existsSync()}");
      if (file != null) {
        debugPrint("DEBUG: file size: ${file.lengthSync()} bytes");
      }

      final success = await _chatRepo.sendMessage(
        fromUserId: _currentUserId,
        toUserId: widget.vendorId,
        message: tempMessage.message,
        file: file,
      );

      debugPrint("DEBUG: _chatRepo.sendMessage returned: $success");

      if (success) {
        // Clear uploading state immediately after successful send
        setState(() {
          _isUploading = false;
        });

        debugPrint(
          "DEBUG: Message sent successfully, waiting for server response...",
        );

        // Trigger immediate update to get the server response
        Future.delayed(Duration(milliseconds: 500), () {
          _fetchLatestMessages();
        });
      } else {
        debugPrint("DEBUG: Failed to send message");
        setState(() {
          _isUploading = false; // Clear uploading state on failure too
        });
        _markMessageAsError(tempMessage.id);
      }
    } catch (e) {
      debugPrint("DEBUG: Error in _sendToServer: $e");
      setState(() {
        _isUploading = false; // Clear uploading state on error
      });
      _markMessageAsError(tempMessage.id);
      _showError('Failed to send message: $e');
    }
  }

  void _markMessageAsError(int messageId) {
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          hasError: true,
          isUploading: false, // Ensure uploading is set to false
        );
      }
      _isUploading = false; // Clear global uploading state
    });
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Attachment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  onTap: _pickDocument,
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      debugPrint("DEBUG: _pickImage called with source: $source");

      // Request permissions
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus != PermissionStatus.granted) {
          _showError('Camera permission is required');
          return;
        }
      } else {
        final storageStatus = await Permission.photos.request();
        if (storageStatus != PermissionStatus.granted) {
          _showError('Storage permission is required');
          return;
        }
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80, // Compress image to reduce file size
      );

      debugPrint("DEBUG: ImagePicker returned: ${image?.path}");

      if (image != null) {
        final file = File(image.path);
        debugPrint("DEBUG: Created File object: ${file.path}");
        debugPrint("DEBUG: File exists: ${file.existsSync()}");
        debugPrint("DEBUG: File size: ${file.lengthSync()} bytes");
        debugPrint("DEBUG: File extension: ${file.path.split('.').last}");

        setState(() {
          _selectedFile = file;
        });

        debugPrint("DEBUG: _selectedFile set to: ${_selectedFile?.path}");
        debugPrint("DEBUG: _selectedFile type: ${_getFileType(_selectedFile)}");
      } else {
        debugPrint("DEBUG: No image selected");
      }
    } catch (e) {
      debugPrint("DEBUG: Error picking image: $e");
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _pickDocument() async {
    try {
      debugPrint("DEBUG: _pickDocument called");

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false, // Don't load file data into memory
      );

      debugPrint("DEBUG: FilePicker result: ${result?.files.length} files");

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        debugPrint("DEBUG: Document selected: ${file.path}");
        debugPrint("DEBUG: Document exists: ${file.existsSync()}");
        debugPrint("DEBUG: Document size: ${file.lengthSync()} bytes");

        setState(() {
          _selectedFile = file;
        });
      } else {
        debugPrint("DEBUG: No document selected");
      }
    } catch (e) {
      debugPrint("DEBUG: Error picking document: $e");
      _showError('Failed to pick document: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _onTypingChanged(String text) {
    setState(() {
      _isTyping = text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    _animationController.dispose();
    _messagesSubscription?.cancel();
    _chatRepo.disconnectPusher();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (widget.chatBloc != null) {
          widget.chatBloc!.add(ReadMessage(chatId: widget.vendorId));
        }
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: ChatWidgets.buildChatAppBar(
            vendorName: widget.vendorName,
            vendorId: widget.vendorId,
            isConnected: _isConnected,
          ),
          body: Column(
            children: [
              // Real-time status indicator (optional)
              Expanded(
                child: _isLoading
                    ? ChatShimmer.buildLoadingState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: ChatWidgets.buildMessagesList(
                          messages: _messages,
                          scrollController: scrollController,
                          vendorName: widget.vendorName,
                          currentUserId: _currentUserId,
                        ),
                      ),
              ),
              if (_selectedFile != null) _buildFilePreview(),
              if (_isUploading) _buildUploadingIndicator(),
              ChatWidgets.buildMessageInput(
                onPressed: sendMessage,
                messageController: messageController,
                onTypingChanged: _onTypingChanged,
                isTyping: _isTyping,
                onAttachmentPressed: _showAttachmentOptions,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) return SizedBox.shrink();

    final fileType = _getFileType(_selectedFile);
    final isImage = fileType?.startsWith('image/') == true;

    debugPrint(
      "DEBUG: Building file preview - isImage: $isImage, fileType: $fileType",
    );

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          if (isImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedFile!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("DEBUG: Error loading image for preview: $error");
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.insert_drive_file, color: Colors.blue),
            ),
          ],
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!.path.split('/').last,
                  style: TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB • ${fileType ?? 'Unknown'}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              setState(() {
                _selectedFile = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Uploading...', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
