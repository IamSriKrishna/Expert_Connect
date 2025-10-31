part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class FetchVendors extends HomeEvent {
  const FetchVendors();

  @override
  List<Object?> get props => [];
}

final class FetchFeaturedProfessionalVendors extends HomeEvent {
  const FetchFeaturedProfessionalVendors();

  @override
  List<Object?> get props => [];
}

final class FetchMostPopularVendors extends HomeEvent {
  const FetchMostPopularVendors();

  @override
  List<Object?> get props => [];
}

final class FetchTopRatedVendors extends HomeEvent {
  const FetchTopRatedVendors();

  @override
  List<Object?> get props => [];
}

final class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();

  @override
  List<Object?> get props => [];
}

final class FetchVendorByID extends HomeEvent {
  final int id;
  const FetchVendorByID({required this.id});

  @override
  List<Object?> get props => [id];
}

final class FetchVendorSlotBooking extends HomeEvent {
  final int id;
  final String date;
  const FetchVendorSlotBooking({required this.id, required this.date});

  @override
  List<Object?> get props => [id, date];
}

final class BookAppointment extends HomeEvent {
  final int vendorId;
  final String appointmentDate;
  final String appointmentTime;
  final String description;
  final int type;
  final double price;
  final double tax;
  final String razorpayPaymentId;

  const BookAppointment({
    required this.price,
    required this.vendorId,
    required this.type,
    required this.tax,
    required this.description,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.razorpayPaymentId,
  });

  @override
  List<Object?> get props => [
    vendorId,
    appointmentDate,
    tax,
    type,
    price,
    appointmentTime,
    razorpayPaymentId,
  ];
}

final class FetchVendorAreasOfExpertise extends HomeEvent {
  final int vendorId;
  const FetchVendorAreasOfExpertise({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

final class FetchSubCategories extends HomeEvent {
  final int categoryId;
  const FetchSubCategories({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

final class FetchVendorsBySubCategory extends HomeEvent {
  final int subCategoryId;
  const FetchVendorsBySubCategory({required this.subCategoryId});

  @override
  List<Object?> get props => [subCategoryId];
}

final class FetchBannerDetails extends HomeEvent {
  const FetchBannerDetails();

  @override
  List<Object?> get props => [];
}

final class FetchUserNotifications extends HomeEvent {
  const FetchUserNotifications();

  @override
  List<Object?> get props => [];
}

final class FetchCategoriesList extends HomeEvent {
  const FetchCategoriesList();

  @override
  List<Object?> get props => [];
}

final class MarkAllNotificationsAsRead extends HomeEvent {
  const MarkAllNotificationsAsRead();

  @override
  List<Object?> get props => [];
}

final class SubmitReview extends HomeEvent {
  final int vendorId;
  final int rating;
  final String review;
  const SubmitReview({
    required this.vendorId,
    required this.rating,
    required this.review,
  });

  @override
  List<Object?> get props => [vendorId, rating, review];
}

final class GetReview extends HomeEvent {
  final int vendorId;
  const GetReview({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

final class FetchVendorAppointmentType extends HomeEvent {
  final int vendorId;
  const FetchVendorAppointmentType({required this.vendorId});

  @override
  List<Object?> get props => [vendorId];
}

final class UpdatePaymentMethod extends HomeEvent {
  final String paymentMethod;
  const UpdatePaymentMethod({required this.paymentMethod});

  @override
  List<Object?> get props => [paymentMethod];
}

final class SearchVendors extends HomeEvent {
  final String searchQuery;

  const SearchVendors({required this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}
