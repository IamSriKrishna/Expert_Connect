import 'package:expert_connect/src/app/app_color.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AwesomeLoadingWidget extends StatefulWidget {
  final bool isLogin;
  const AwesomeLoadingWidget({super.key, required this.isLogin});

  @override
  State<AwesomeLoadingWidget> createState() => _AwesomeLoadingWidgetState();
}

class _AwesomeLoadingWidgetState extends State<AwesomeLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _textController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Continuous pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Create animations
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _particleController.repeat();

    // Delay text animation
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _fadeAnimation,
        _pulseAnimation,
        _rotationAnimation,
        _particleAnimation,
        _textOpacityAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main loading animation container
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColor.primaryColor.withOpacity(0.1),
                          AppColor.backgroundColor.withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating ring with gradient
                        Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    AppColor.primaryColor,
                                    AppColor.primaryColor.withOpacity(0.3),
                                    AppColor.splashColor,
                                    AppColor.primaryColor.withOpacity(0.1),
                                  ],
                                  stops: [0.0, 0.3, 0.7, 1.0],
                                ),
                              ),
                              child: Container(
                                margin: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Middle pulsing ring
                        Transform.scale(
                          scale: _pulseAnimation.value * 0.7,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.primaryColor.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Inner core with gradient
                        Transform.scale(
                          scale: _pulseAnimation.value * 0.4,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColor.primaryColor,
                                  AppColor.splashColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primaryColor.withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Floating particles
                        ...List.generate(6, (index) {
                          final angle =
                              (index * math.pi * 2 / 6) +
                              (_particleAnimation.value * math.pi * 2);
                          final radius =
                              50 +
                              (math.sin(
                                    _particleAnimation.value * math.pi * 2,
                                  ) *
                                  5);

                          return Transform.translate(
                            offset: Offset(
                              math.cos(angle) * radius,
                              math.sin(angle) * radius,
                            ),
                            child: Transform.scale(
                              scale:
                                  0.5 +
                                  (math.sin(
                                        _particleAnimation.value * math.pi * 4 +
                                            index,
                                      ) *
                                      0.3),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.primaryColor.withOpacity(0.6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.primaryColor.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Modern loading text with animation
                  Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppColor.primaryColor,
                              AppColor.splashColor,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            widget.isLogin
                                ? 'Signing you in...'
                                : 'Creating Account For you...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Modern progress dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final delay = index * 0.2;
                            final animationValue =
                                (_pulseController.value + delay) % 1.0;
                            final scale =
                                1.0 +
                                (math.sin(animationValue * math.pi) * 0.4);
                            final opacity =
                                0.4 +
                                (math.sin(animationValue * math.pi) * 0.6);

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.primaryColor.withOpacity(
                                      opacity,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 12),

                        // Subtle loading message
                        Opacity(
                          opacity: _textOpacityAnimation.value * 0.7,
                          child: Text(
                            'Please wait a moment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColor.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
