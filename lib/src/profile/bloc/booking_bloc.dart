import 'package:equatable/equatable.dart';
import 'package:expert_connect/src/app/app_constant.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/appointment_type_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

part 'booking_state.dart';
part 'booking_event.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final Logger _logger = Logger();

  BookingBloc() : super(BookingState.initial()) {
    on<UpdateSelectedDate>(_onUpdateSelectedDate);
    on<UpdateCurrentViewDate>(_onUpdateCurrentViewDate);
    on<UpdateSelectedTime>(_onUpdateSelectedTime);
    on<InitializeRazorpay>(_onInitializeRazorpay);
    on<ClearRazorpay>(_onClearRazorpay);
    on<InitiatePayment>(_onInitiatePayment);
    on<PaymentSuccess>(_onPaymentSuccess);
    on<PaymentError>(_onPaymentError);
    on<ExternalWallet>(_onExternalWallet);
  }

  Future<void> _onInitiatePayment(
  InitiatePayment event,
  Emitter<BookingState> emit,
) async {
  try {
    if (state.razorpay == null) {
      emit(state.copyWith(
        paymentStatus: () => PaymentStatus.failed,
        paymentError: () => 'Payment service not initialized',
      ));
      return;
    }

    emit(state.copyWith(paymentStatus: () => PaymentStatus.processing));

    final amountInPaise = (event.type.price * 100).round();
    var options = {
      'key': 'rzp_live_RQ80EGzFUFhMtM',//'rzp_test_RQAL2SMXMKx4J9',
      'amount': amountInPaise  ,
      'name': 'Expert Connect',
      'description': event.isPartialPayment 
          ? 'Remaining payment for appointment' 
          : 'Consultation Fee',
      'prefill': {
        'contact': authStateManager.user!.phone,
        'email': authStateManager.userEmail,
      },
      'notes': {
        'appointment_date': DateFormat('dd/MM/yyyy').format(state.selectedDate),
        'appointment_time': state.selectedTime,
        'service': 'Medical Consultation',
        'service_type': event.type.type,
        if (event.isPartialPayment) 
          'wallet_amount_used': event.walletAmountUsed.toString(),
        'total_amount': (event.isPartialPayment
            ? event.type.price + event.walletAmountUsed!
            : event.type.price).toString(),
      },
      'theme': {'color': '#3399cc'},
    };
    _logger.e("Options:$options");
    state.razorpay!.open(options);
  } catch (e) {
    emit(state.copyWith(
      paymentStatus: () => PaymentStatus.failed,
      paymentError: () => 'Failed to initiate payment: ${e.toString()}',
    ));
  }
}


  Future<void> _onPaymentSuccess(
    PaymentSuccess event,
    Emitter<BookingState> emit,
  ) async {
    try {
      // Validate payment response
      if (event.response.paymentId == null ||
          event.response.paymentId!.isEmpty) {
        emit(
          state.copyWith(
            paymentStatus: () => PaymentStatus.failed,
            paymentError: () => 'Invalid payment response',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          paymentStatus: () => PaymentStatus.success,
          paymentError: () => null,
          paymentId: () => event.response.paymentId!,
        ),
      );

      _logger.d("Payment successful: ${event.response.paymentId}");
    } catch (e) {
      emit(
        state.copyWith(
          paymentStatus: () => PaymentStatus.failed,
          paymentError: () =>
              'Failed to process payment success: ${e.toString()}',
        ),
      );
      _logger.e("Failed to handle payment success: $e");
    }
  }

  Future<void> _onPaymentError(
    PaymentError event,
    Emitter<BookingState> emit,
  ) async {
    try {
      final errorMessage = event.response.message ?? 'Payment failed';

      emit(
        state.copyWith(
          paymentStatus: () => PaymentStatus.failed,
          paymentError: () => errorMessage,
        ),
      );

      _logger.e("Payment failed: $errorMessage");
      _logger.e("Payment error code: ${event.response.code}");
    } catch (e) {
      emit(
        state.copyWith(
          paymentStatus: () => PaymentStatus.failed,
          paymentError: () => 'Payment processing error',
        ),
      );
      _logger.e("Failed to handle payment error: $e");
    }
  }

  Future<void> _onExternalWallet(
    ExternalWallet event,
    Emitter<BookingState> emit,
  ) async {
    try {
      _logger.d("External wallet selected: ${event.response.walletName}");
    } catch (e) {
      _logger.e("Failed to handle external wallet: $e");
    }
  }

  Future<void> _onUpdateSelectedDate(
    UpdateSelectedDate event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(paymentStatus: () => PaymentStatus.idle));
    try {
      emit(state.copyWith(selectedDate: () => event.selectedDate));
      _logger.d("Selected Date Updated ${state.selectedDate}");
    } catch (e) {
      _logger.e("Failed to Update Selected Date $e");
    }
  }

  Future<void> _onUpdateCurrentViewDate(
    UpdateCurrentViewDate event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(paymentStatus: () => PaymentStatus.idle));
    try {
      emit(state.copyWith(currentViewDate: () => event.currentViewDate));
      _logger.d("Current View Date Updated ${state.currentViewDate}");
    } catch (e) {
      _logger.e("Failed to Update Current View Date $e");
    }
  }

  Future<void> _onUpdateSelectedTime(
    UpdateSelectedTime event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(paymentStatus: () => PaymentStatus.idle));
    try {
      emit(state.copyWith(selectedTime: () => event.selectedTime));
      _logger.d("Selected Time Updated ${state.selectedTime}");
    } catch (e) {
      _logger.e("Failed to Update Selected Time $e");
    }
  }

  Future<void> _onInitializeRazorpay(
    InitializeRazorpay event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(state.copyWith(razorpay: () => event.razorpay));
      _logger.d("Razorpay Initialized");
    } catch (e) {
      _logger.e("Failed to Initialize Razorpay $e");
    }
  }

  Future<void> _onClearRazorpay(
    ClearRazorpay event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(state.copyWith(razorpay: () => null));
      _logger.d("Razorpay Cleared");
    } catch (e) {
      _logger.e("Failed to Clear Razorpay $e");
    }
  }
}
