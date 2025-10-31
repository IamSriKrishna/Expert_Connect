part of 'booking_bloc.dart';

enum PaymentStatus { idle, processing, success, failed }

class BookingState extends Equatable {
  final DateTime selectedDate;
  final DateTime currentViewDate;
  final String? selectedTime;
  final Razorpay? razorpay;
  final List<String> months;
  final List<String> weekDays;
  final PaymentStatus paymentStatus;
  final String? paymentError;
  final String paymentId;

  const BookingState({
    required this.currentViewDate,
    required this.selectedDate,
    required this.selectedTime,
    required this.razorpay,
    required this.months,
    required this.weekDays,
    required this.paymentStatus,
    required this.paymentId,
    this.paymentError,
  });

  factory BookingState.initial() {
    return BookingState(
      currentViewDate: DateTime.now(),
      selectedDate: DateTime.now(),
      selectedTime: null,
      razorpay: null,
      months: AppConstant.months,
      weekDays: AppConstant.weekDays,
      paymentStatus: PaymentStatus.idle,
      paymentId: "",
      paymentError: null,
    );
  }

  BookingState copyWith({
    DateTime Function()? currentViewDate,
    DateTime Function()? selectedDate,
    String? Function()? selectedTime,
    Razorpay? Function()? razorpay,
    List<String> Function()? months,
    List<String> Function()? weekDays,
    PaymentStatus Function()? paymentStatus,
    String? Function()? paymentError,
    String Function()? paymentId,
  }) {
    return BookingState(
      currentViewDate: currentViewDate != null
          ? currentViewDate()
          : this.currentViewDate,
      selectedDate: selectedDate != null ? selectedDate() : this.selectedDate,
      selectedTime: selectedTime != null ? selectedTime() : this.selectedTime,
      razorpay: razorpay != null ? razorpay() : this.razorpay,
      months: months != null ? months() : this.months,
      weekDays: weekDays != null ? weekDays() : this.weekDays,
      paymentStatus: paymentStatus != null
          ? paymentStatus()
          : this.paymentStatus,
      paymentError: paymentError != null ? paymentError() : this.paymentError,
      paymentId: paymentId != null ? paymentId() : this.paymentId,
    );
  }

  @override
  List<Object?> get props => [
    currentViewDate,
    selectedDate,
    selectedTime,
    months,
    razorpay,
    weekDays,
    paymentStatus,
    paymentError,
    paymentId,
  ];
}
