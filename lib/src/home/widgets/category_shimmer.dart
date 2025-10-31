// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryShimmer {
  static Widget buildSideBarShimmerState() {
    return Container(
      width: 80.w,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: 6, // Show 6 shimmer items including "All" item
        itemBuilder: (context, index) {
          final isFirstItem = index == 0;
          return Padding(
            padding: EdgeInsets.only(top: isFirstItem ? 0 : 15.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Icon placeholder
                _AnimatedShimmerBox(
                  height: 48.h,
                  width: 48.w,
                  borderRadius: BorderRadius.circular(24.w),
                  delay: Duration(milliseconds: index * 200),
                ),
                SizedBox(height: 8.h),

                // Animated Text placeholder
                _AnimatedShimmerBox(
                  width: 40.w,
                  height: 12.h,
                  borderRadius: BorderRadius.circular(6),
                  delay: Duration(milliseconds: index * 200 + 100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget buildProfessionalShimmerState() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: 6, // Show 6 shimmer items
          itemBuilder: (context, index) {
            return Container(
              height: 88.h,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Animated Icon placeholder
                    _AnimatedShimmerBox(
                      width: 48,
                      height: 48,
                      borderRadius: BorderRadius.circular(12),
                      delay: Duration(milliseconds: index * 150),
                    ),
                    const SizedBox(width: 16),

                    // Content placeholders
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Title placeholder
                          _AnimatedShimmerBox(
                            width: double.infinity,
                            height: 18,
                            borderRadius: BorderRadius.circular(4),
                            delay: Duration(milliseconds: index * 150 + 50),
                          ),
                          const SizedBox(height: 8),

                          // Animated Subtitle placeholder
                          _AnimatedShimmerBox(
                            width: 120,
                            height: 14,
                            borderRadius: BorderRadius.circular(4),
                            delay: Duration(milliseconds: index * 150 + 100),
                          ),
                        ],
                      ),
                    ),

                    // Animated Arrow placeholder
                    _AnimatedShimmerBox(
                      width: 30,
                      height: 30,
                      borderRadius: BorderRadius.circular(8),
                      delay: Duration(milliseconds: index * 150 + 150),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final Duration delay;

  const _AnimatedShimmerBox({
    this.width,
    required this.height,
    required this.borderRadius,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedShimmerBox> createState() => _AnimatedShimmerBoxState();
}

class _AnimatedShimmerBoxState extends State<_AnimatedShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Scale animation for heartbeat effect
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Opacity animation for breathing effect
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start animation with delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}