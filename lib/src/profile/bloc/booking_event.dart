part of 'booking_bloc.dart';

class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class UpdateSelectedDate extends BookingEvent {
  final DateTime selectedDate;

  const UpdateSelectedDate({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

class UpdateCurrentViewDate extends BookingEvent {
  final DateTime currentViewDate;

  const UpdateCurrentViewDate({required this.currentViewDate});

  @override
  List<Object?> get props => [currentViewDate];
}

class UpdateSelectedTime extends BookingEvent {
  final String? selectedTime;

  const UpdateSelectedTime({required this.selectedTime});

  @override
  List<Object?> get props => [selectedTime];
}

class InitializeRazorpay extends BookingEvent {
  final Razorpay razorpay;

  const InitializeRazorpay({required this.razorpay});

  @override
  List<Object?> get props => [razorpay];
}

class ClearRazorpay extends BookingEvent {
  const ClearRazorpay();

  @override
  List<Object?> get props => [];
}

class InitiatePayment extends BookingEvent {
  final AppointmentTypeModel type;
  final bool isPartialPayment;
  final double? walletAmountUsed;

  const InitiatePayment({
    required this.type,
    this.isPartialPayment = false,
    this.walletAmountUsed,
  });

  @override
  List<Object?> get props => [type, isPartialPayment, walletAmountUsed];
}

class PaymentSuccess extends BookingEvent {
  final PaymentSuccessResponse response;
  
  const PaymentSuccess({required this.response});
  
  @override
  List<Object?> get props => [response];
}

class PaymentError extends BookingEvent {
  final PaymentFailureResponse response;
  
  const PaymentError({required this.response});
  
  @override
  List<Object?> get props => [response];
}

class ExternalWallet extends BookingEvent {
  final ExternalWalletResponse response;
  
  const ExternalWallet({required this.response});
  
  @override
  List<Object?> get props => [response];
}