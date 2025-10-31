import 'package:expert_connect/src/app/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatShimmer {
  // Updated buildLoadingState method for chat_widgets.dart
static Widget buildLoadingState() {
  return Column(
    children: [
      // Chat messages area with skeleton loading
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: 6, // Show 6 skeleton message bubbles
          itemBuilder: (context, index) {
            final isMe = index % 3 == 0; // Alternate between sender and receiver
            return _buildSkeletonMessageBubble(isMe: isMe);
          },
        ),
      ),
      // Input area skeleton
      _buildSkeletonMessageInput(),
    ],
  );
}

// Skeleton message bubble
static Widget _buildSkeletonMessageBubble({required bool isMe}) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    margin: EdgeInsets.only(bottom: 12.h),
    child: Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          // Skeleton avatar
          _buildSkeletonAvatar(),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: Get.width * 0.75,
              minWidth: Get.width * 0.3,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isMe ? AppColor.splashColor.withOpacity(0.1) : Colors.white,
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
                // Skeleton text lines
                _buildSkeletonLine(
                  width: Get.width * (0.4 + (isMe ? 0.1 : 0.2)),
                  height: 14.h,
                ),
                SizedBox(height: 6.h),
                _buildSkeletonLine(
                  width: Get.width * (0.2 + (isMe ? 0.15 : 0.1)),
                  height: 14.h,
                ),
                SizedBox(height: 8.h),
                // Skeleton timestamp
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSkeletonLine(
                      width: 40.w,
                      height: 10.h,
                    ),
                    if (isMe) ...[
                      SizedBox(width: 4.w),
                      _buildSkeletonCircle(size: 14.sp),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Skeleton avatar
static Widget _buildSkeletonAvatar() {
  return Container(
    width: 32.w,
    height: 32.w,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      shape: BoxShape.circle,
    ),
    child: _buildShimmerEffect(),
  );
}

// Skeleton line
static Widget _buildSkeletonLine({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(4.r),
    ),
    child: _buildShimmerEffect(),
  );
}

// Skeleton circle
static Widget _buildSkeletonCircle({required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      shape: BoxShape.circle,
    ),
    child: _buildShimmerEffect(),
  );
}

// Skeleton message input
static Widget _buildSkeletonMessageInput() {
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
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              children: [
                SizedBox(width: 20.w),
                Expanded(
                  child: _buildSkeletonLine(
                    width: double.infinity,
                    height: 16.h,
                  ),
                ),
                SizedBox(width: 12.w),
                _buildSkeletonCircle(size: 20.sp),
                SizedBox(width: 8.w),
                _buildSkeletonCircle(size: 20.sp),
                SizedBox(width: 12.w),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: _buildShimmerEffect(),
        ),
      ],
    ),
  );
}

// Shimmer effect for skeleton loading
static Widget _buildShimmerEffect() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 1500),
    builder: (context, value, child) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, 0.0),
            end: Alignment(1.0, 0.0),
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.6),
              Colors.transparent,
            ],
            stops: [
              (value - 0.3).clamp(0.0, 1.0),
              value,
              (value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      );
    },
  );
}

// Alternative method with more realistic message structure
static Widget buildLoadingStateWithRealisticMessages() {
  return Column(
    children: [
      Expanded(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          children: [
            // Welcome message from vendor
            _buildSkeletonWelcomeMessage(),
            SizedBox(height: 12.h),
            
            // User inquiry
            _buildSkeletonUserMessage(),
            SizedBox(height: 12.h),
            
            // Vendor response
            _buildSkeletonVendorMessage(),
            SizedBox(height: 12.h),
            
            // Another user message
            _buildSkeletonUserMessage(),
            SizedBox(height: 12.h),
            
            // Typing indicator
            _buildSkeletonTypingIndicator(),
          ],
        ),
      ),
      _buildSkeletonMessageInput(),
    ],
  );
}

// Skeleton welcome message
static Widget _buildSkeletonWelcomeMessage() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      _buildSkeletonAvatar(),
      SizedBox(width: 8.w),
      Flexible(
        child: Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(4.r),
              bottomRight: Radius.circular(20.r),
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
              _buildSkeletonLine(width: Get.width * 0.5, height: 14.h),
              SizedBox(height: 6.h),
              _buildSkeletonLine(width: Get.width * 0.4, height: 14.h),
              SizedBox(height: 6.h),
              _buildSkeletonLine(width: Get.width * 0.3, height: 14.h),
              SizedBox(height: 8.h),
              _buildSkeletonLine(width: 40.w, height: 10.h),
            ],
          ),
        ),
      ),
    ],
  );
}

// Skeleton user message
static Widget _buildSkeletonUserMessage() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Flexible(
        child: Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColor.splashColor.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(4.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeletonLine(width: Get.width * 0.4, height: 14.h),
              SizedBox(height: 6.h),
              _buildSkeletonLine(width: Get.width * 0.25, height: 14.h),
              SizedBox(height: 8.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSkeletonLine(width: 40.w, height: 10.h),
                  SizedBox(width: 4.w),
                  _buildSkeletonCircle(size: 14.sp),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// Skeleton vendor message
static Widget _buildSkeletonVendorMessage() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(width: 32.w), // Space for avatar (not shown for consecutive messages)
      SizedBox(width: 8.w),
      Flexible(
        child: Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
              bottomLeft: Radius.circular(4.r),
              bottomRight: Radius.circular(20.r),
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
              _buildSkeletonLine(width: Get.width * 0.6, height: 14.h),
              SizedBox(height: 6.h),
              _buildSkeletonLine(width: Get.width * 0.45, height: 14.h),
              SizedBox(height: 8.h),
              _buildSkeletonLine(width: 40.w, height: 10.h),
            ],
          ),
        ),
      ),
    ],
  );
}

// Skeleton typing indicator
static Widget _buildSkeletonTypingIndicator() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      _buildSkeletonAvatar(),
      SizedBox(width: 8.w),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(delay: 0),
            SizedBox(width: 4.w),
            _buildTypingDot(delay: 200),
            SizedBox(width: 4.w),
            _buildTypingDot(delay: 400),
          ],
        ),
      ),
    ],
  );
}

// Animated typing dot
static Widget _buildTypingDot({required int delay}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 800),
    builder: (context, value, child) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade400.withOpacity(0.5 + (value * 0.5)),
          shape: BoxShape.circle,
        ),
      );
    },
  );
}
}