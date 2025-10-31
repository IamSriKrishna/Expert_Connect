import 'package:flutter/material.dart';

class ModernSuccessDialog extends StatefulWidget {
  final String message;
  final String? imageUrl;
  final VoidCallback? onClose;

  const ModernSuccessDialog({
    super.key,
    required this.message,
    this.imageUrl,
    this.onClose,
  });

  @override
  State<ModernSuccessDialog> createState() => _ModernSuccessDialogState();
}

class _ModernSuccessDialogState extends State<ModernSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _slideController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon with Animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00C851),
                      Color(0xFF00A041),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C851).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _checkAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CheckmarkPainter(_checkAnimation.value),
                      child: const SizedBox.expand(),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Success Title
            SlideTransition(
              position: _slideAnimation,
              child: const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Success Message
            SlideTransition(
              position: _slideAnimation,
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
          
            
            // Close Button
            SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  
  CheckmarkPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();
    
    // Define checkmark points
    final p1 = Offset(center.dx - 10, center.dy);
    final p2 = Offset(center.dx - 2, center.dy + 8);
    final p3 = Offset(center.dx + 10, center.dy - 6);
    
    if (progress > 0) {
      // First part of checkmark
      final firstProgress = (progress * 2).clamp(0.0, 1.0);
      final firstEnd = Offset.lerp(p1, p2, firstProgress)!;
      checkPath.moveTo(p1.dx, p1.dy);
      checkPath.lineTo(firstEnd.dx, firstEnd.dy);
      
      // Second part of checkmark
      if (progress > 0.5) {
        final secondProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
        final secondEnd = Offset.lerp(p2, p3, secondProgress)!;
        checkPath.lineTo(secondEnd.dx, secondEnd.dy);
      }
      
      canvas.drawPath(checkPath, paint);
    }
  }
  
  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

extension ModernSuccessDialogExtension on BuildContext {
  Future<void> showModernSuccessDialog({
    required String message,
    String? imageUrl,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => ModernSuccessDialog(
        message: message,
        imageUrl: imageUrl,
        onClose: onClose,
      ),
    );
  }
}
