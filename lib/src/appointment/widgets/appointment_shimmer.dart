// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentShimmer {
  /// Professional loading state for appointment list items
  static Widget buildAppointmentListShimmer({int itemCount = 3}) {
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 10,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Profile Avatar Shimmer
                  _AnimatedShimmerBox(
                    width: 52,
                    height: 52,
                    borderRadius: BorderRadius.circular(26),
                    delay: Duration(milliseconds: index * 150),
                  ),

                  const SizedBox(width: 16),

                  // Appointment Details Shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vendor name shimmer
                        _AnimatedShimmerBox(
                          width: double.infinity,
                          height: 18,
                          borderRadius: BorderRadius.circular(4),
                          delay: Duration(milliseconds: index * 150 + 50),
                        ),
                        const SizedBox(height: 12),
                        
                        // Time row shimmer
                        Row(
                          children: [
                            _AnimatedShimmerBox(
                              width: 16,
                              height: 16,
                              borderRadius: BorderRadius.circular(8),
                              delay: Duration(milliseconds: index * 150 + 100),
                            ),
                            const SizedBox(width: 6),
                            _AnimatedShimmerBox(
                              width: 80,
                              height: 14,
                              borderRadius: BorderRadius.circular(4),
                              delay: Duration(milliseconds: index * 150 + 125),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Video call row shimmer
                        Row(
                          children: [
                            _AnimatedShimmerBox(
                              width: 16,
                              height: 16,
                              borderRadius: BorderRadius.circular(8),
                              delay: Duration(milliseconds: index * 150 + 150),
                            ),
                            const SizedBox(width: 6),
                            _AnimatedShimmerBox(
                              width: 70,
                              height: 14,
                              borderRadius: BorderRadius.circular(4),
                              delay: Duration(milliseconds: index * 150 + 175),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Join Call Button Shimmer
                  _AnimatedShimmerBox(
                    width: 36,
                    height: 36,
                    borderRadius: BorderRadius.circular(8),
                    delay: Duration(milliseconds: index * 150 + 200),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Professional horizontal loading state for professional cards
  static Widget buildProfessionalHorizontalShimmer({int itemCount = 3}) {
    return SizedBox(
      height: 240.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < itemCount - 1 ? 16 : 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with status and favorite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AnimatedShimmerBox(
                        width: 60,
                        height: 24,
                        borderRadius: BorderRadius.circular(12),
                        delay: Duration(milliseconds: index * 150),
                      ),
                      _AnimatedShimmerBox(
                        width: 20,
                        height: 20,
                        borderRadius: BorderRadius.circular(10),
                        delay: Duration(milliseconds: index * 150 + 50),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Profile image placeholder
                  Center(
                    child: _AnimatedShimmerBox(
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(20),
                      delay: Duration(milliseconds: index * 150 + 100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name placeholder
                  Center(
                    child: _AnimatedShimmerBox(
                      width: 120,
                      height: 18,
                      borderRadius: BorderRadius.circular(9),
                      delay: Duration(milliseconds: index * 150 + 150),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Specialization placeholder
                  Center(
                    child: _AnimatedShimmerBox(
                      width: 90,
                      height: 14,
                      borderRadius: BorderRadius.circular(7),
                      delay: Duration(milliseconds: index * 150 + 200),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Stats placeholders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(3, (i) => Column(
                      children: [
                        _AnimatedShimmerBox(
                          width: 20,
                          height: 20,
                          borderRadius: BorderRadius.circular(10),
                          delay: Duration(milliseconds: index * 150 + 250 + (i * 25)),
                        ),
                        const SizedBox(height: 4),
                        _AnimatedShimmerBox(
                          width: 25,
                          height: 12,
                          borderRadius: BorderRadius.circular(6),
                          delay: Duration(milliseconds: index * 150 + 275 + (i * 25)),
                        ),
                      ],
                    )),
                  ),
                  const SizedBox(height: 16),
                  
                  // Button placeholder
                  _AnimatedShimmerBox(
                    width: double.infinity,
                    height: 36,
                    borderRadius: BorderRadius.circular(12),
                    delay: Duration(milliseconds: index * 150 + 350),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Simple grid shimmer for professional cards
  static Widget buildProfessionalGridShimmer({
    int itemCount = 6,
    int crossAxisCount = 2,
  }) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile image
                  _AnimatedShimmerBox(
                    width: 60,
                    height: 60,
                    borderRadius: BorderRadius.circular(15),
                    delay: Duration(milliseconds: index * 150),
                  ),
                  const SizedBox(height: 12),
                  
                  // Name
                  _AnimatedShimmerBox(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.circular(8),
                    delay: Duration(milliseconds: index * 150 + 50),
                  ),
                  const SizedBox(height: 8),
                  
                  // Specialization
                  _AnimatedShimmerBox(
                    width: 80,
                    height: 12,
                    borderRadius: BorderRadius.circular(6),
                    delay: Duration(milliseconds: index * 150 + 100),
                  ),
                  const Spacer(),
                  
                  // Button
                  _AnimatedShimmerBox(
                    width: double.infinity,
                    height: 32,
                    borderRadius: BorderRadius.circular(10),
                    delay: Duration(milliseconds: index * 150 + 150),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }

  /// Professional loading state similar to CategoryShimmer style
  static Widget buildProfessionalListShimmer({int itemCount = 6}) {
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: 88.h,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16.0, left: 20.0, right: 20.0),
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
                color: Colors.white.withOpacity(0.8),
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}