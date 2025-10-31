// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/chat/bloc/chat_bloc.dart';
import 'package:expert_connect/src/models/chat_model.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatWidgets {
  // Updated buildSearchBar to accept a TextEditingController
  static Widget buildSearchBar(TextEditingController searchController) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search chats...",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 12.h,
            ),
            // Add clear button when there's text
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      searchController.clear();
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  // Updated buildChatList to accept and use search query
  static Widget buildChatList(
    ChatState state,
    ChatBloc chatBloc,
    String searchQuery,
  ) {
    // Filter the chat list based on search query
    final filteredChats = searchQuery.isEmpty
        ? state.chat
        : state.chat
              .where(
                (chat) =>
                    chat.name.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();

    // Show "No results found" if search query exists but no matches
    if (searchQuery.isNotEmpty && filteredChats.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64.w, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              CommonWidgets.text(
                text: "No chats found",
                fontSize: 18.sp,
                color: Colors.grey[600]!,
                fontWeight: TextWeight.medium,
              ),
              SizedBox(height: 8.h),
              CommonWidgets.text(
                text: "Try adjusting your search terms",
                fontSize: 14.sp,
                color: Colors.grey[500]!,
              ),
            ],
          ),
        ),
      );
    }
    if (state.chat.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64.w, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              CommonWidgets.text(
                text: "No chats found",
                fontSize: 18.sp,
                color: Colors.grey[600]!,
                fontWeight: TextWeight.medium,
              ),
            ],
          ),
        ),
      );
    }
    return SliverList.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return _buildChatTile(chat, chatBloc);
      },
    );
  }

  static Widget _buildChatTile(ChatListModel chat, ChatBloc chatBloc) {
    String formattedDate = "Invalid date";

    try {
      // First, clean the string (remove any unexpected whitespace or characters)
      String cleanDateString = chat.lastTime.trim();

      // Try parsing with explicit format
      final inputFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
      final dateTime = inputFormat.parse(
        cleanDateString,
        true,
      ); // lenient parsing

      // Format for display
      formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      debugPrint("Date parsing error for '${chat.lastTime}': $e");

      // Fallback: Try parsing as ISO format if custom format fails
      try {
        final dateTime = DateTime.parse(chat.lastTime);
        formattedDate = DateFormat('dd MMM yyyy • hh:mm a').format(dateTime);
      } catch (e2) {
        debugPrint("ISO format parsing also failed: $e2");
        formattedDate = chat.lastTime; // Show raw string as last resort
      }
    }
    return InkWell(
      onTap: () {
        Get.toNamed(
          RoutesName.messageScreen,
          arguments: {
            'vendorId': chat.userId,
            'vendorName': chat.name,
            'chatBloc': chatBloc,
            'isFromChatScreen': true,
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColor.splashColor.withOpacity(0.1),
                  child: CommonWidgets.text(
                    text: chat.name[0].toUpperCase(),
                    fontSize: 18.sp,
                    color: AppColor.splashColor,
                    fontWeight: TextWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),

            // Chat Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonWidgets.text(
                        text: chat.name,
                        fontSize: 16.sp,
                        fontWeight: TextWeight.medium,
                        color: Colors.black87,
                      ),
                      CommonWidgets.text(
                        text: formattedDate,
                        fontSize: 12.sp,
                        color: chat.unreadCount > 0
                            ? AppColor.splashColor
                            : Colors.grey,
                        fontWeight: chat.unreadCount > 0
                            ? TextWeight.medium
                            : TextWeight.regular,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CommonWidgets.text(
                          text: chat.lastMessage,
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          maxLines: 1,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.splashColor,
                            shape: BoxShape.circle,
                          ),
                          child: CommonWidgets.text(
                            text: chat.unreadCount.toString(),
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: TextWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColor.splashColor,
      child: Icon(Icons.chat, color: Colors.white),
    );
  }
}
