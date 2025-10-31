import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class BookingBottomSheet extends StatefulWidget {
  final String vendorName;
  final int vendorId;
  final HomeState state;

  const BookingBottomSheet({
    super.key,
    required this.vendorName,
    required this.state,
    required this.vendorId,
  });

  @override
  State<BookingBottomSheet> createState() => BookingBottomSheetState();
}

class BookingBottomSheetState extends State<BookingBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String? selectedCallType;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleCallTypeSelection(String type) {
    setState(() {
      selectedCallType = type;
    });

    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  void _proceedWithBooking() async {
    if (selectedCallType == null) return;

    setState(() {
      isProcessing = true;
    });
    Logger().d("Selected Type is $selectedCallType");

    final selectedAppointment = widget.state.appointmentTypeModel.firstWhere(
      (e) => e.type.toLowerCase() == selectedCallType!.toLowerCase(),
    );
    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 1500));
    // Navigator.pop(context);

    Get.toNamed(
      RoutesName.booking,
      arguments: {
        "id": widget.vendorId,
        "appointment_type": selectedAppointment,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appointmentTypes = widget.state.appointmentTypeModel;
    final shouldScroll = appointmentTypes.length > 4;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: GestureDetector(
        onTap: () {},
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: EdgeInsets.only(
              top: screenHeight * 0.3,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue[600]!,
                                    Colors.blue[400]!,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.video_call,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Book Consultation',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'with ${widget.vendorName}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close, color: Colors.grey[400]),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Call Type Selection
                        if (appointmentTypes.isNotEmpty)
                          Text(
                            'Choose consultation type',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        if (appointmentTypes.isEmpty)
                          Text(
                            'No consultation type',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Consultation Types List
                        if (appointmentTypes.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: shouldScroll 
                                  ? screenHeight * 0.25  // Limit height when scrollable
                                  : double.infinity,
                            ),
                            child: shouldScroll
                                ? ListView.separated(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: appointmentTypes.length,
                                    separatorBuilder: (context, index) => 
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final e = appointmentTypes[index];
                                      return _buildCallTypeCard(
                                        type: e.service.toLowerCase() == "video".toLowerCase()
                                            ? "video"
                                            : "voice",
                                        title: e.type,
                                        subtitle: e.service.toLowerCase() == "video".toLowerCase()
                                            ? 'Face-to-face consultation'
                                            : 'Audio-only consultation',
                                        icon: e.service.toLowerCase() == "video".toLowerCase()
                                            ? Icons.videocam
                                            : Icons.phone,
                                        gradient: e.service.toLowerCase() == "video".toLowerCase()
                                            ? [Colors.blue[600]!, Colors.blue[400]!]
                                            : [Colors.green[600]!, Colors.green[400]!],
                                        price: '₹${e.price}',
                                      );
                                    },
                                  )
                                : Column(
                                    children: appointmentTypes.map((e) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildCallTypeCard(
                                          type: e.service.toLowerCase() == "video".toLowerCase()
                                              ? "video"
                                              : "voice",
                                          title: e.type,
                                          subtitle: e.service.toLowerCase() == "video".toLowerCase()
                                              ? 'Face-to-face consultation'
                                              : 'Audio-only consultation',
                                          icon: e.service.toLowerCase() == "video".toLowerCase()
                                              ? Icons.videocam
                                              : Icons.phone,
                                          gradient: e.service.toLowerCase() == "video".toLowerCase()
                                              ? [Colors.blue[600]!, Colors.blue[400]!]
                                              : [Colors.green[600]!, Colors.green[400]!],
                                          price: '₹${e.price}',
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),

                        const SizedBox(height: 24),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: selectedCallType != null && !isProcessing
                                ? _proceedWithBooking
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedCallType != null
                                  ? Colors.blue[700]
                                  : Colors.grey[300],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: selectedCallType != null ? 4 : 0,
                              shadowColor: Colors.blue.withOpacity(0.3),
                            ),
                            child: isProcessing
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Processing...',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Continue to Book',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required String price,
  }) {
    final isSelected = selectedCallType == title;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => _handleCallTypeSelection(title),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Price and Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue[600]!
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: isSelected ? Colors.blue[600] : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}