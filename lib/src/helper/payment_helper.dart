import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/models/appointment_type_model.dart';
import 'package:expert_connect/src/profile/bloc/booking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentHelper {
  static void initializeRazorpay(BuildContext context) {
    try {
      final razorpay = Razorpay();
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
        PaymentSuccessResponse response,
      ) {
        context.read<BookingBloc>().add(PaymentSuccess(response: response));
      });
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
        PaymentFailureResponse response,
      ) {
        context.read<BookingBloc>().add(PaymentError(response: response));
      });
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
        ExternalWalletResponse response,
      ) {
        context.read<BookingBloc>().add(ExternalWallet(response: response));
      });

      context.read<BookingBloc>().add(InitializeRazorpay(razorpay: razorpay));
    } catch (e) {
      Logger().e('Error initializing Razorpay: $e');
    }
  }

  static void Function(BuildContext, BookingState) listener({
    required int vendorId,
    required AppointmentTypeModel appointment,
    required HomeState homeState,
    required String description
  }) {
    return (context, state) {
      if (state.paymentStatus == PaymentStatus.success) {
        context.read<HomeBloc>().add(
          BookAppointment(
            vendorId: vendorId,
            tax: appointment.tax,
            description: description,
            type: appointment.id,
            price: appointment.price,
            appointmentDate: DateFormat(
              "yyyy-MM-dd",
            ).format(state.selectedDate),
            appointmentTime: state.selectedTime!,
            razorpayPaymentId: state.paymentId,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful! Appointment booked.'),
            backgroundColor: Colors.green,
          ),
        );
        Get.offNamed(RoutesName.bottom);
      } else if (state.paymentStatus == PaymentStatus.failed &&
          state.paymentError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${state.paymentError}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  
}

