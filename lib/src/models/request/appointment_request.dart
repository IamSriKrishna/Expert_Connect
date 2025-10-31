class AppointmentRequest {
  final int vendorId;
  final int userId;
  final String appointmentDate;
  final String appointmentTime;
  final int type;
  final double price;
  final double tax;
  final String description;
  final String paymentMethod;
  final String userEmail;
  final String razorpayPaymentId;

  AppointmentRequest({
    required this.vendorId,
    required this.userId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.type,
    required this.price,
    required this.tax,
    required this.description,
    required this.paymentMethod,
    required this.userEmail,
    required this.razorpayPaymentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'user_id': userId,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'type': type,
      "payment_method":paymentMethod,
      'price': price,
      'tax': tax,
      'description': description,
      'user_email': userEmail,
      'razorpay_payment_id': razorpayPaymentId,
    };
  }
}
