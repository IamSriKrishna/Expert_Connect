// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/models/appointment_type_model.dart';
import 'package:expert_connect/src/profile/bloc/booking_bloc.dart';
import 'package:expert_connect/src/profile/payment_dialog.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VendorBookingWidgets {
  // App Bar Widget
  static Widget appBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColor.splashColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Book Appointment',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  // Time Slot Section Widget
  static Widget timeSlotSection(
    HomeState homeState,
    BookingState bookingState,
    BuildContext context,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: _buildCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Book By Time'),
            const SizedBox(height: 16),
            _buildTimeSlotContent(homeState, bookingState, context),
          ],
        ),
      ),
    );
  }

  static Widget loading() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: SpinKitWaveSpinner(
          trackColor: AppColor.splashColor.withOpacity(0.2),
          color: AppColor.splashColor,
          size: 0.2.sw,
          waveColor: AppColor.splashColor.withOpacity(0.5),
        ),
      ),
    );
  }

  static Widget summaryWidget(BookingState state, AppointmentTypeModel type) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: _buildCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Appointment Summary'),
            const SizedBox(height: 16),
            _buildDateRow(state),
            const SizedBox(height: 12),
            _buildTimeRow(state),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            _buildFeeRow(type),
          ],
        ),
      ),
    );
  }

  static Widget bookAppointment(
    BookingState state,
    BuildContext context,
    AppointmentTypeModel type,
    int vendorId,
    TextEditingController descriptionController, // ✅ Accept controller
  ) {
    final onPressed = _getButtonOnPressed(
      state,
      context,
      type,
      vendorId,
      descriptionController,
    );
    
    debugPrint('🔘 Building button - onPressed is ${onPressed != null ? "enabled" : "disabled"}');
    debugPrint('🔘 Selected time: ${state.selectedTime}');
    debugPrint('🔘 Payment status: ${state.paymentStatus}');
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onPressed,
            style: _buildButtonStyle(state),
            child: _buildButtonContent(state, type),
          ),
        ),
      ),
    );
  }

  static VoidCallback? _getButtonOnPressed(
    BookingState state,
    BuildContext context,
    AppointmentTypeModel type,
    int vendorId,
    TextEditingController descriptionController, // ✅ Receive controller
  ) {
    final canBook = state.selectedTime != null &&
        state.paymentStatus != PaymentStatus.processing;

    if (!canBook) return null;

    return () {
      // ✅ Get fresh value from controller when button is pressed
      final description = descriptionController.text.trim();
      
      debugPrint('🔍 Button pressed - Description: "$description"');
      debugPrint('🔍 Can book: $canBook');
      debugPrint('🔍 Selected time: ${state.selectedTime}');

      // ✅ Validate before opening modal
      if (description.isEmpty) {
        debugPrint('⚠️ Description is empty, showing warning');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Please enter a description for your appointment',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      debugPrint('✅ Opening payment modal with description: "$description"');
      
      _showPaymentSelectionModal(
        context,
        state,
        type,
        vendorId,
        description, // ✅ Pass the validated description
      );
    };
  }

  static ButtonStyle _buildButtonStyle(BookingState state) {
    final isEnabled = state.selectedTime != null &&
        state.paymentStatus != PaymentStatus.processing;

    return ElevatedButton.styleFrom(
      backgroundColor: isEnabled ? AppColor.splashColor : Colors.grey[400],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    );
  }

  static Widget _buildButtonContent(
    BookingState state,
    AppointmentTypeModel type,
  ) {
    final isProcessing = state.paymentStatus == PaymentStatus.processing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isProcessing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else
          const Icon(Icons.payment, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Text(
          isProcessing
              ? 'Processing...'
              : 'Pay ${CommonWidgets.calculateAmountWithTax(type.price, type.tax)} & Book Appointment',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static void _showPaymentSelectionModal(
    BuildContext context,
    BookingState state,
    AppointmentTypeModel type,
    int vendorId,
    String description,
  ) {
    debugPrint('📱 Attempting to show payment modal');
    debugPrint('📱 Description: "$description"');
    debugPrint('📱 Vendor ID: $vendorId');
    debugPrint('📱 Appointment Type: ${type.type}');
    
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (modalContext) {
          debugPrint('🎯 Building modal content');
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<BookingBloc>()),
              BlocProvider.value(value: context.read<HomeBloc>()),
            ],
            child: PaymentSelectionModal(
              vendorId: vendorId,
              appointmentType: type,
              description: description,
              bookingState: state,
            ),
          );
        },
      ).then((value) {
        debugPrint('🎯 Modal closed with value: $value');
      }).catchError((error) {
        debugPrint('❌ Error showing modal: $error');
      });
    } catch (e) {
      debugPrint('❌ Exception showing modal: $e');
    }
  }

  // Private Helper Methods

  static BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  static Widget _buildTimeSlotContent(
    HomeState homeState,
    BookingState bookingState,
    BuildContext context,
  ) {
    switch (homeState.status) {
      case HomeStateStatus.failed:
        return _buildErrorContainer();
      case HomeStateStatus.success:
        return _buildTimeSlotDropdown(homeState, bookingState, context);
      default:
        return const SizedBox.shrink();
    }
  }

  static Widget _buildErrorContainer() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red[50],
      ),
      child: Center(
        child: Text(
          'No schedule found.',
          style: TextStyle(color: Colors.red[600], fontSize: 14),
        ),
      ),
    );
  }

  static Widget _buildTimeSlotDropdown(
    HomeState homeState,
    BookingState bookingState,
    BuildContext context,
  ) {
    final availableSlots = homeState.vendorAvailabeSlot.availableSlots;
    final hasSlots = availableSlots.isNotEmpty;
    final currentSelection = availableSlots.contains(bookingState.selectedTime)
        ? bookingState.selectedTime
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              hasSlots
                  ? 'Choose your preferred time...'
                  : 'No available slots for this date',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          value: currentSelection,
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AnimatedRotation(
              turns: currentSelection != null ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: currentSelection != null
                    ? AppColor.splashColor
                    : Colors.grey[500],
              ),
            ),
          ),
          items: availableSlots.map((String time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: CommonWidgets.text(
                  text: time,
                  color: Colors.grey.shade500,
                  fontWeight: TextWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            );
          }).toList(),
          onChanged: hasSlots
              ? (String? newValue) => _handleTimeSelection(newValue, context)
              : null,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          elevation: 4,
          style: TextStyle(
            color: AppColor.splashColor,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          selectedItemBuilder: (BuildContext context) {
            return availableSlots.map<Widget>((String item) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CommonWidgets.text(
                  text: item,
                  color: AppColor.splashColor,
                  fontWeight: TextWeight.bold,
                  fontSize: 14.sp,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  static void _handleTimeSelection(String? newValue, BuildContext context) {
    context.read<BookingBloc>().add(UpdateSelectedTime(selectedTime: newValue));
  }

  static Widget _buildDateRow(BookingState state) {
    return Row(
      children: [
        Icon(Icons.calendar_today, color: AppColor.splashColor, size: 20),
        const SizedBox(width: 12),
        Text(
          '${state.selectedDate.day}/${state.selectedDate.month}/${state.selectedDate.year}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  static Widget _buildTimeRow(BookingState state) {
    return Row(
      children: [
        Icon(Icons.access_time, color: AppColor.splashColor, size: 20),
        const SizedBox(width: 12),
        Text(
          state.selectedTime!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  static Widget _buildFeeRow(AppointmentTypeModel type) {
    final taxAmount = (type.price * (type.tax / 100));
    debugPrint("Tax is ${type.tax}");
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Consultation Fee + GST:',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Row(
          children: [
            Text(
              '₹${CommonWidgets.calculateAmountWithTax(type.price, type.tax)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.splashColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                '(₹${type.price} + ₹${taxAmount.toStringAsFixed(2)})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}