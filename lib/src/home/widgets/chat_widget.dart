// chat_widgets.dart
import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/models/chat_model.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeChatWidgets {
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
                ),
                CommonWidgets.text(
                  text: isConnected ? "Online" : "Offline",
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.call, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
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
                    text: vendorName.isNotEmpty
                        ? vendorName[0].toUpperCase()
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
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
                CommonWidgets.text(
                  text: message.message,
                  fontSize: 14.sp,
                  color: isMe ? Colors.white : Colors.black87,
                  fontWeight: TextWeight.regular,
                ),
                SizedBox(height: 2.h),
                buildMessageStatus(message, isMe),
              ],
            ),
          ),
        ),
      ],
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

  static Widget buildUserAvatar() {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [AppColor.splashColor, AppColor.splashColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.splashColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.person, color: Colors.white, size: 16.sp),
      ),
    );
  }

  static Widget buildMessageInput({
    required void Function()? onPressed,
    required TextEditingController messageController,
    required void Function(String) onTypingChanged,
    required bool isTyping,
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
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.grey),
                        onPressed: () {},
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
