import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/models/chat_model.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatWidgets {
  static PreferredSizeWidget buildChatAppBar({
    required String vendorName,
    required int vendorId,
    required bool isConnected,
  }) {
    return AppBar(
      backgroundColor: AppColor.splashColor,
      elevation: 1,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Hero(
                tag: 'avatar_$vendorId',
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: CommonWidgets.text(
                    text: vendorName.isNotEmpty
                        ? vendorName[0].toUpperCase()
                        : '?',
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: TextWeight.bold,
                  ),
                ),
              ),
              if (isConnected)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonWidgets.text(
                  text: vendorName,
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: TextWeight.medium,
                )
              ],
            ),
          ),
        ],
      ),
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.videocam, color: Colors.white),
      //     onPressed: () {},
      //   ),
      //   IconButton(
      //     icon: Icon(Icons.call, color: Colors.white),
      //     onPressed: () {},
      //   ),
      //   IconButton(
      //     icon: Icon(Icons.more_vert, color: Colors.white),
      //     onPressed: () {},
      //   ),
      // ],
    );
  }

  static Widget buildMessagesList({
    required List<ChatMessage> messages,
    required ScrollController scrollController,
    required String vendorName,
    required int currentUserId,
  }) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48.sp,
                color: AppColor.splashColor.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16.h),
            CommonWidgets.text(
              text: 'No messages yet',
              fontSize: 18.sp,
              color: Colors.grey.shade800,
              fontWeight: TextWeight.regular,
            ),
            SizedBox(height: 8.h),
            CommonWidgets.text(
              text: 'Start a conversation with $vendorName',
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.fromUserId == currentUserId;
        final showAvatar =
            index == 0 || messages[index - 1].fromUserId != message.fromUserId;

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: 12.h),
          child: buildMessageBubble(
            message: message,
            isMe: isMe,
            showAvatar: showAvatar,
            vendorName: vendorName,
          ),
        );
      },
    );
  }

  static Widget buildMessageBubble({
    required ChatMessage message,
    required bool isMe,
    required bool showAvatar,
    required String vendorName,
  }) {
    // Get the display name - use sender name if available, otherwise fallback to vendorName
    String displayName = vendorName;
    if (!isMe && message.sender != null) {
      displayName = message.sender!.name;
    }

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          showAvatar
              ? CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColor.splashColor.withOpacity(0.1),
                  child: CommonWidgets.text(
                    text: displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    fontSize: 12.sp,
                    color: AppColor.splashColor,
                    fontWeight: TextWeight.bold,
                  ),
                )
              : SizedBox(width: 32.w),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: Get.width * 0.75),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isMe ? AppColor.splashColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomLeft: Radius.circular(isMe ? 20.r : 4.r),
                bottomRight: Radius.circular(isMe ? 4.r : 20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File attachment
                if (message.hasAttachment) ...[
                  _buildAttachmentWidget(message, isMe),
                  if (message.message.isNotEmpty) SizedBox(height: 8.h),
                ],
                // Text message
                if (message.message.isNotEmpty)
                  CommonWidgets.text(
                    text: message.message,
                    fontSize: 14.sp,
                    color: isMe ? Colors.white : Colors.black87,
                    fontWeight: TextWeight.regular,
                  ),
                SizedBox(height: 4.h),
                buildMessageStatus(message, isMe),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to check if file type is image
  static bool _isImageType(String? fileType) {
    if (fileType == null) return false;
    return fileType.toLowerCase().contains('image') ||
           fileType.toLowerCase().contains('jpg') ||
           fileType.toLowerCase().contains('jpeg') ||
           fileType.toLowerCase().contains('png') ||
           fileType.toLowerCase().contains('gif') ||
           fileType.toLowerCase().contains('bmp') ||
           fileType.toLowerCase().contains('webp');
  }

  // Helper method to check if file type is video
  static bool _isVideoType(String? fileType) {
    if (fileType == null) return false;
    return fileType.toLowerCase().contains('video') ||
           fileType.toLowerCase().contains('mp4') ||
           fileType.toLowerCase().contains('mov') ||
           fileType.toLowerCase().contains('avi') ||
           fileType.toLowerCase().contains('mkv') ||
           fileType.toLowerCase().contains('wmv');
  }

  static Widget _buildAttachmentWidget(ChatMessage message, bool isMe) {
    if (message.isUploading) {
      return Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: isMe ? Colors.white : AppColor.splashColor,
                strokeWidth: 2,
              ),
              SizedBox(height: 8.h),
              CommonWidgets.text(
                text: 'Uploading...',
                fontSize: 12.sp,
                color: isMe ? Colors.white70 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      );
    }

    // Use helper methods for better file type detection
    final isImage = _isImageType(message.fileType) || message.isImage;
    final isVideo = _isVideoType(message.fileType) || message.isVideo;

    if (isImage) {
      return _buildImageAttachment(message, isMe);
    } else if (isVideo) {
      return _buildVideoAttachment(message, isMe);
    } else {
      return _buildDocumentAttachment(message, isMe);
    }
  }

  static Widget _buildImageAttachment(ChatMessage message, bool isMe) {
    return GestureDetector(
      onTap: () => _showImagePreview(message.fileUrl ?? ''),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 300.h,
            maxWidth: double.infinity,
          ),
          child: message.fileUrl != null && message.fileUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: message.fileUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200.h,
                    color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isMe ? Colors.white : AppColor.splashColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print("Image load error: $error for URL: $url");
                    return Container(
                      height: 200.h,
                      padding: EdgeInsets.all(16.w),
                      color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: isMe ? Colors.white70 : Colors.grey,
                            size: 40.sp,
                          ),
                          SizedBox(height: 8.h),
                          CommonWidgets.text(
                            text: 'Failed to load image',
                            fontSize: 12.sp,
                            color: isMe ? Colors.white70 : Colors.grey.shade600,
                            textAlign: TextAlign.center,
                          ),
                          if (message.fileName != null) ...[
                            SizedBox(height: 4.h),
                            CommonWidgets.text(
                              text: message.fileName!,
                              fontSize: 10.sp,
                              color: isMe ? Colors.white60 : Colors.grey.shade500,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                )
              : Container(
                  height: 200.h,
                  padding: EdgeInsets.all(16.w),
                  color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color: isMe ? Colors.white70 : Colors.grey,
                        size: 40.sp,
                      ),
                      SizedBox(height: 8.h),
                      CommonWidgets.text(
                        text: 'Image not available',
                        fontSize: 12.sp,
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                        textAlign: TextAlign.center,
                      ),
                      if (message.fileName != null) ...[
                        SizedBox(height: 4.h),
                        CommonWidgets.text(
                          text: message.fileName!,
                          fontSize: 10.sp,
                          color: isMe ? Colors.white60 : Colors.grey.shade500,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  static Widget _buildVideoAttachment(ChatMessage message, bool isMe) {
    return GestureDetector(
      onTap: () {
        // Handle video playback
        if (message.fileUrl != null) {
          // You can implement video player here
          print("Play video: ${message.fileUrl}");
        }
      },
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (message.fileUrl != null && message.fileUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: message.fileUrl! + '_thumbnail', // Assuming thumbnail URL
                  height: 200.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    height: 200.h,
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library,
                            color: Colors.white,
                            size: 50.sp,
                          ),
                          if (message.fileName != null) ...[
                            SizedBox(height: 8.h),
                            CommonWidgets.text(
                              text: message.fileName!,
                              fontSize: 12.sp,
                              color: Colors.white70,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 200.h,
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library,
                        color: Colors.white,
                        size: 50.sp,
                      ),
                      if (message.fileName != null) ...[
                        SizedBox(height: 8.h),
                        CommonWidgets.text(
                          text: message.fileName!,
                          fontSize: 12.sp,
                          color: Colors.white70,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(12.w),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDocumentAttachment(ChatMessage message, bool isMe) {
    return GestureDetector(
      onTap: () {
        // Handle document download/open
        if (message.fileUrl != null) {
          print("Open document: ${message.fileUrl}");
          // Implement document opening logic
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.3) : AppColor.splashColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getFileIcon(message.fileType),
                color: isMe ? Colors.white : AppColor.splashColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonWidgets.text(
                    text: message.fileName ?? 'Unknown file',
                    fontSize: 13.sp,
                    color: isMe ? Colors.white : Colors.black87,
                    fontWeight: TextWeight.medium,
                  ),
                  CommonWidgets.text(
                    text: _getFileSizeText(message),
                    fontSize: 11.sp,
                    color: isMe ? Colors.white70 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.download,
              color: isMe ? Colors.white70 : Colors.grey.shade600,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get file size text
  static String _getFileSizeText(ChatMessage message) {
    // Since ChatMessage doesn't have fileSize property, 
    // we'll just return a generic attachment label
    // You can enhance this by adding fileSize to ChatMessage model if needed
    return 'Attachment';
  }

  static IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    
    final type = fileType.toLowerCase();
    
    if (type.contains('pdf')) return Icons.picture_as_pdf;
    if (type.contains('word') || type.contains('doc')) return Icons.description;
    if (type.contains('excel') || type.contains('sheet')) return Icons.table_chart;
    if (type.contains('powerpoint') || type.contains('presentation')) return Icons.slideshow;
    if (type.contains('zip') || type.contains('rar') || type.contains('archive')) return Icons.archive;
    if (type.contains('text') || type.contains('txt')) return Icons.text_snippet;
    if (type.contains('audio') || type.contains('mp3') || type.contains('wav')) return Icons.audiotrack;
    
    return Icons.insert_drive_file;
  }

  static void _showImagePreview(String imageUrl) {
    if (imageUrl.isEmpty) return;
    
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.white, size: 50),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: SafeArea(
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildMessageStatus(ChatMessage message, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonWidgets.text(
          text: formatTime(message.timestamp),
          fontSize: 11.sp,
          color: isMe ? Colors.white70 : Colors.grey.shade600,
        ),
        if (isMe) ...[
          SizedBox(width: 4.w),
          if (message.isUploading)
            SizedBox(
              width: 12.sp,
              height: 12.sp,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: Colors.white70,
              ),
            )
          else
            Icon(
              message.hasError
                  ? Icons.error_outline
                  : message.isSent
                  ? Icons.done_all
                  : Icons.schedule,
              size: 14.sp,
              color: message.hasError
                  ? Colors.red.shade300
                  : message.isSent
                  ? Colors.blue
                  : Colors.white70,
            ),
        ],
      ],
    );
  }

  static Widget buildMessageInput({
    required void Function()? onPressed,
    required TextEditingController messageController,
    required void Function(String) onTypingChanged,
    required bool isTyping,
    VoidCallback? onAttachmentPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file, color: Colors.grey),
                        onPressed: onAttachmentPressed,
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.grey),
                        onPressed: () {
                          // Quick camera access
                          onAttachmentPressed?.call();
                        },
                      ),
                    ],
                  ),
                ),
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                maxLines: null,
                onSubmitted: (_) => onPressed?.call(),
                onChanged: onTypingChanged,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isTyping ? AppColor.splashColor : Colors.grey.shade400,
              shape: BoxShape.circle,
              boxShadow: isTyping
                  ? [
                      BoxShadow(
                        color: AppColor.splashColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }

  static String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '${hour == 0 ? 12 : hour}:$minute $period';
    } else {
      final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
      final minute = timestamp.minute.toString().padLeft(2, '0');
      final period = timestamp.hour >= 12 ? 'PM' : 'AM';
      return '${timestamp.day}/${timestamp.month} ${hour == 0 ? 12 : hour}:$minute $period';
    }
  }
}