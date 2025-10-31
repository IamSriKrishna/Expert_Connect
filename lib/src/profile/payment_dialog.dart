// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/models/appointment_type_model.dart';
import 'package:expert_connect/src/profile/bloc/booking_bloc.dart';
import 'package:expert_connect/src/settings/bloc/setting_bloc.dart';
import 'package:expert_connect/src/settings/repo/setting_repo.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentSelectionModal extends StatefulWidget {
  final AppointmentTypeModel appointmentType;
  final BookingState bookingState;
  final int vendorId;
  final String description;

  const PaymentSelectionModal({
    super.key,
    required this.appointmentType,
    required this.description,
    required this.bookingState,
    required this.vendorId,
  });

  @override
  State<PaymentSelectionModal> createState() => _PaymentSelectionModalState();
}

class _PaymentSelectionModalState extends State<PaymentSelectionModal>
    with TickerProviderStateMixin {
  final PaymentMethod _selectedPaymentMethod = PaymentMethod.razorpay;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              SettingBloc(SettingRepoImpl())..add(FetchTransactionSummary()),
        ),
        BlocProvider.value(value: BlocProvider.of<HomeBloc>(context)),
        BlocProvider.value(value: BlocProvider.of<BookingBloc>(context)),
      ],
      child: _PaymentModalContent(
        appointmentType: widget.appointmentType,
        bookingState: widget.bookingState,
        vendorId: widget.vendorId,
        description: widget.description,
      ),
    );
  }
}

class _PaymentModalContent extends StatefulWidget {
  final AppointmentTypeModel appointmentType;
  final BookingState bookingState;
  final int vendorId;
  final String description;

  const _PaymentModalContent({
    required this.appointmentType,
    required this.bookingState,
    required this.vendorId,
    required this.description,
  });

  @override
  State<_PaymentModalContent> createState() => _PaymentModalContentState();
}

class _PaymentModalContentState extends State<_PaymentModalContent>
    with TickerProviderStateMixin {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.razorpay;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        return BlocListener<BookingBloc, BookingState>(
          listener: (context, bookingState) {
            _handlePaymentStateChanges(bookingState);
          },
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                child: Transform.translate(
                  offset: Offset(
                    0,
                    MediaQuery.of(context).size.height * _slideAnimation.value,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.74,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [_buildHeader(), _buildContent(state)],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.splashColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: AppColor.splashColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SettingState state) {
    if (state.status == SettingStateStatus.loading ||
        state.status == SettingStateStatus.initial) {
      return _buildShimmerContent();
    }
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingSummary(),
            const SizedBox(height: 24),
            _buildPaymentMethods(state),
            const SizedBox(height: 24),
            _buildPayButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.splashColor.withOpacity(0.1),
            AppColor.splashColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.splashColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                color: AppColor.splashColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Appointment Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Flexible(
                child: Text(
                  widget.appointmentType.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GST',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                '${widget.appointmentType.tax} %',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Amount',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                '₹${widget.appointmentType.price}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GST Amount',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                '₹${((widget.appointmentType.price * widget.appointmentType.tax) / 100)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '₹${CommonWidgets.calculateAmountWithTax(widget.appointmentType.price, widget.appointmentType.tax)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.splashColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(SettingState state) {
    final walletBalance = state.transaction.summary.currentBalance;
    final totalAmount = widget.appointmentType.price;

    final canUseSplit = walletBalance > 0 && walletBalance < totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodTile(
          method: PaymentMethod.razorpay,
          title: 'Online',
          subtitle: 'Pay with UPI, Cards, Net Banking',
          icon: Icons.credit_card_rounded,
          color: const Color(0xFF3395FF),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodTile(
          method: PaymentMethod.wallet,
          title: 'Wallet',
          subtitle: 'Available balance: ₹${walletBalance.toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF4CAF50),
          isDisabled: walletBalance < totalAmount,
        ),
        const SizedBox(height: 12),
        if (canUseSplit)
          _buildPaymentMethodTile(
            method: PaymentMethod.walletThenRazorpay,
            title: 'Wallet + Online',
            subtitle:
                'Use ₹${walletBalance.toStringAsFixed(0)} from wallet + '
                '₹${(totalAmount - walletBalance).toStringAsFixed(0)} via Online',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF9C27B0),
          ),
      ],
    );
  }

  Future<void> _handleWalletThenRazorpay() async {
  if (_isProcessingPayment) return;

  // Validate description is not empty
  if (widget.description.trim().isEmpty) {
    _showPaymentFailedMessage("Please provide a description for your appointment");
    return;
  }

  setState(() => _isProcessingPayment = true);
  final walletBalance = BlocProvider.of<SettingBloc>(context).state.transaction.summary.currentBalance;
  final totalAmount = widget.appointmentType.price;
  final remainingAmount = totalAmount - walletBalance;

  try {
    BlocProvider.of<HomeBloc>(context).add(UpdatePaymentMethod(paymentMethod: "split"));
    
    // ✅ Pass description here if your InitiatePayment event supports it
    BlocProvider.of<BookingBloc>(context).add(
      InitiatePayment(
        type: widget.appointmentType.copyWith(price: remainingAmount),
        isPartialPayment: true,
        walletAmountUsed: walletBalance.toDouble(),
      ),
    );
  } catch (e) {
    setState(() => _isProcessingPayment = false);
    _showPaymentFailedMessage("Payment failed: $e");
  }
}

  Widget _buildPaymentMethodTile({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isDisabled = false,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _selectedPaymentMethod = method;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[100] : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDisabled ? Colors.grey : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDisabled ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                  if (isDisabled && method == PaymentMethod.wallet)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Insufficient balance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected && !isDisabled)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  void _handlePaymentStateChanges(BookingState bookingState) {
    if (_selectedPaymentMethod == PaymentMethod.razorpay) {
      switch (bookingState.paymentStatus) {
        case PaymentStatus.processing:
          setState(() {
            _isProcessingPayment = true;
          });
          _showProcessingMessage();
          break;

        case PaymentStatus.success:
          setState(() {
            _isProcessingPayment = false;
          });
          _bookAppointmentAfterPayment(bookingState);
          break;

        case PaymentStatus.failed:
          setState(() {
            _isProcessingPayment = false;
          });
          _showPaymentFailedMessage(bookingState.paymentError);
          break;

        case PaymentStatus.idle:
          setState(() {
            _isProcessingPayment = false;
          });
          break;
      }
    }
  }

  // Enhanced Razorpay payment handling
  void _handleRazorpayPayment() {
    if (_isProcessingPayment) return;

    context.read<HomeBloc>().add(UpdatePaymentMethod(paymentMethod: "online"));

    context.read<BookingBloc>().add(
      InitiatePayment(
        type: widget.appointmentType.copyWith(
          price: CommonWidgets.calculateAmountWithTax(
            widget.appointmentType.price,
            widget.appointmentType.tax,
          ),
        ),
      ),
    );
  }

  void _bookAppointmentAfterPayment(BookingState bookingState) {
  if (bookingState.paymentId.isEmpty) {
    _showPaymentFailedMessage("Payment ID not found");
    return;
  }

  // Validate description is not empty
  if (widget.description.trim().isEmpty) {
    _showPaymentFailedMessage("Please provide a description for your appointment");
    return;
  }

  try {
    context.read<HomeBloc>().add(
      BookAppointment(
        vendorId: widget.vendorId,
        tax: widget.appointmentType.tax,
        type: widget.appointmentType.id,
        description: widget.description.trim(), // ✅ Using the passed description
        price: widget.appointmentType.price,
        appointmentDate: DateFormat("yyyy-MM-dd").format(widget.bookingState.selectedDate),
        appointmentTime: widget.bookingState.selectedTime!,
        razorpayPaymentId: bookingState.paymentId,
      ),
    );

    _showPaymentSuccessMessage();
    Get.offNamed(RoutesName.bottom);
  } catch (e) {
    _showPaymentFailedMessage("Failed to book appointment: $e");
  }
}

  void _handleWalletPayment() {
    if (_isProcessingPayment) return;

    // Validate description is not empty
    if (widget.description.trim().isEmpty) {
      _showPaymentFailedMessage(
        "Please provide a description for your appointment",
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      context.read<HomeBloc>().add(
        UpdatePaymentMethod(paymentMethod: "userwallet"),
      );

      context.read<HomeBloc>().add(
        BookAppointment(
          vendorId: widget.vendorId,
          description: widget.description
              .trim(), // ✅ Now using the passed description
          tax: widget.appointmentType.tax,
          type: widget.appointmentType.id,
          price: widget.appointmentType.price,
          appointmentDate: DateFormat(
            "yyyy-MM-dd",
          ).format(widget.bookingState.selectedDate),
          appointmentTime: widget.bookingState.selectedTime!,
          razorpayPaymentId: "wallet_payment",
        ),
      );

      _showPaymentSuccessMessage();
      Get.offNamed(RoutesName.bottom);
    } catch (e) {
      _showPaymentFailedMessage("Wallet payment failed: $e");
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  void _initiatePayment() {
    if (_isProcessingPayment) return;
    Navigator.pop(context);

    switch (_selectedPaymentMethod) {
      case PaymentMethod.wallet:
        _handleWalletPayment();
        break;
      case PaymentMethod.walletThenRazorpay:
        _handleWalletThenRazorpay();
        break;
      case PaymentMethod.razorpay:
        _handleRazorpayPayment();
    }
  }

  // Enhanced pay button with loading state
  Widget _buildPayButton(SettingState state) {
    final isWalletSelected = _selectedPaymentMethod == PaymentMethod.wallet;
    final isWalletDisabled =
        isWalletSelected &&
        state.transaction.summary.currentBalance < widget.appointmentType.price;

    final isButtonDisabled = isWalletDisabled || _isProcessingPayment;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : _initiatePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonDisabled
              ? Colors.grey[400]
              : AppColor.splashColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isProcessingPayment
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isWalletSelected
                        ? Icons.account_balance_wallet_rounded
                        : Icons.payment_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isWalletSelected
                        ? 'Pay with Wallet - ₹${CommonWidgets.calculateAmountWithTax(widget.appointmentType.price, widget.appointmentType.tax)}'
                        : _selectedPaymentMethod ==
                              PaymentMethod.walletThenRazorpay
                        ? "Pay with Online"
                        : 'Pay with Online - ₹${CommonWidgets.calculateAmountWithTax(widget.appointmentType.price, widget.appointmentType.tax)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Enhanced success message
  void _showPaymentSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Payment successful! Appointment booked.'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Enhanced failure message with error details
  void _showPaymentFailedMessage([String? errorMessage]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage ?? 'Payment Failed! Please try again.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show processing message
  void _showProcessingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Processing payment...'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ... (rest of the shimmer methods remain the same)
  Widget _buildShimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: const Color(0xFFE8E8E8),
      ),
      child: const _ShimmerAnimation(),
    );
  }

  Widget _buildShimmerContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBookingSummary(),
            const SizedBox(height: 24),
            _buildShimmerPaymentMethods(),
            const SizedBox(height: 24),
            _buildShimmerPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerBox(20, 20),
              const SizedBox(width: 8),
              _buildShimmerBox(140, 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildShimmerBox(50, 14), _buildShimmerBox(80, 14)],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildShimmerBox(30, 14), _buildShimmerBox(40, 14)],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildShimmerBox(90, 16), _buildShimmerBox(60, 18)],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(120, 18),
        const SizedBox(height: 16),
        _buildShimmerPaymentMethodTile(),
        const SizedBox(height: 12),
        _buildShimmerPaymentMethodTile(),
      ],
    );
  }

  Widget _buildShimmerPaymentMethodTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: _buildShimmerBox(24, 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(80, 16),
                const SizedBox(height: 4),
                _buildShimmerBox(150, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPayButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: _ShimmerAnimation()),
    );
  }
}

enum PaymentMethod { razorpay, wallet, walletThenRazorpay }

// Add this shimmer animation class
class _ShimmerAnimation extends StatefulWidget {
  const _ShimmerAnimation();

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF5F5F5),
                Color(0xFFE8E8E8),
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1, 0.0),
              end: Alignment(_animation.value, 0.0),
            ),
          ),
        );
      },
    );
  }
}
