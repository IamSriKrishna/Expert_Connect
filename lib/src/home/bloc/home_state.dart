part of 'home_bloc.dart';

enum HomeStateStatus {
  initial,
  loading,
  loaded,
  failed,
  success,
  empty,
  updated,
}

class HomeState extends Equatable {
  final HomeStateStatus status;
  final HomeStateStatus vendorStatus;
  final List<Category> category;
  final List<Vendor> vendors;
  final List<Vendor> featuredVendors;
  final List<Vendor> topRatedVendors;
  final HomeStateStatus searchStatus;
  final List<SubCategory> subCategories;
  final List<Vendor> mostPopularVendors;
  final List<NotificationModel> notifications;
  final HomeStateStatus notificationsStatus;
  final List<AreaOfExpertise> areasOfExpertise;
  final List<ReviewModel> reviews;
  final List<Vendor> searchResults;
  final BannerDetailsResponse bannerDetails;
  final HomeStateStatus bannerStatus;
  final List<AppointmentTypeModel> appointmentTypeModel;
  final Vendor vendor;
  final VendorAvailabeSlot vendorAvailabeSlot;
  final String message;
  final String paymentMethod;

  const HomeState({
    required this.category,
    required this.vendors,
    required this.featuredVendors,
    required this.areasOfExpertise,
    required this.vendorAvailabeSlot,
    required this.bannerDetails,
    required this.bannerStatus,
    required this.subCategories,
    required this.topRatedVendors,
    required this.mostPopularVendors,
    required this.paymentMethod,
    required this.reviews,
    required this.notifications,
    required this.notificationsStatus,
    required this.vendor,
    required this.appointmentTypeModel,
    required this.status,
    required this.vendorStatus,
    required this.message,
    required this.searchResults,
    required this.searchStatus,
  });

  factory HomeState.initial() {
    return HomeState(
      category: [],
      vendors: [],
      featuredVendors: [],
      mostPopularVendors: [],
      bannerDetails: BannerDetailsResponse.initial(),
      bannerStatus: HomeStateStatus.initial,
      topRatedVendors: [],
      appointmentTypeModel: [],
      reviews: [],
      subCategories: [],
      vendor: Vendor.initial(),
      vendorAvailabeSlot: VendorAvailabeSlot.initial(),
      status: HomeStateStatus.initial,
      areasOfExpertise: [],
      vendorStatus: HomeStateStatus.initial,
      message: "",
      paymentMethod: "online",
      searchResults: [],
      searchStatus: HomeStateStatus.initial,
      notifications: [],
      notificationsStatus: HomeStateStatus.initial,
    );
  }

  HomeState copyWith({
    HomeStateStatus Function()? status,
    HomeStateStatus Function()? vendorStatus,
    List<SubCategory> Function()? subCategories,
    List<AreaOfExpertise> Function()? areasOfExpertise,
    List<Category> Function()? category,
    List<Vendor> Function()? vendors,
    List<Vendor> Function()? featuredVendors,
    List<Vendor> Function()? mostPopularVendors,
    List<Vendor> Function()? topRatedVendors,
    List<ReviewModel> Function()? reviews,
    List<AppointmentTypeModel> Function()? appointmentTypeModel,
    BannerDetailsResponse Function()? bannerDetails,
    HomeStateStatus Function()? bannerStatus,
    VendorAvailabeSlot Function()? vendorAvailabeSlot,
    Vendor Function()? vendor,
    List<Vendor> Function()? searchResults,
    HomeStateStatus Function()? searchStatus,
    List<NotificationModel> Function()? notifications,
    HomeStateStatus Function()? notificationsStatus,
    String Function()? message,
    String Function()? paymentMethod,
  }) {
    return HomeState(
      searchResults: searchResults != null
          ? searchResults()
          : this.searchResults,
      searchStatus: searchStatus != null ? searchStatus() : this.searchStatus,
      category: category != null ? category() : this.category,
      bannerDetails: bannerDetails != null
          ? bannerDetails()
          : this.bannerDetails,
      bannerStatus: bannerStatus != null ? bannerStatus() : this.bannerStatus,
      notifications: notifications != null
          ? notifications()
          : this.notifications,
      notificationsStatus: notificationsStatus != null
          ? notificationsStatus()
          : this.notificationsStatus,
      reviews: reviews != null ? reviews() : this.reviews,
      paymentMethod: paymentMethod != null
          ? paymentMethod()
          : this.paymentMethod,
      appointmentTypeModel: appointmentTypeModel != null
          ? appointmentTypeModel()
          : this.appointmentTypeModel,
      areasOfExpertise: areasOfExpertise != null
          ? areasOfExpertise()
          : this.areasOfExpertise,
      vendors: vendors != null ? vendors() : this.vendors,
      mostPopularVendors: mostPopularVendors != null
          ? mostPopularVendors()
          : this.mostPopularVendors,
      subCategories: subCategories != null
          ? subCategories()
          : this.subCategories,
      topRatedVendors: topRatedVendors != null
          ? topRatedVendors()
          : this.topRatedVendors,
      vendorAvailabeSlot: vendorAvailabeSlot != null
          ? vendorAvailabeSlot()
          : this.vendorAvailabeSlot,
      vendor: vendor != null ? vendor() : this.vendor,
      featuredVendors: featuredVendors != null
          ? featuredVendors()
          : this.featuredVendors,
      status: status != null ? status() : this.status,
      vendorStatus: vendorStatus != null ? vendorStatus() : this.vendorStatus,
      message: message != null ? message() : this.message,
    );
  }

  bool get isCategoryLoading => status == HomeStateStatus.loading;
  bool get isCategoryLoaded => status == HomeStateStatus.loaded;
  bool get isCategoryFailed => status == HomeStateStatus.failed;

  bool get isVendorLoading => vendorStatus == HomeStateStatus.loading;
  bool get isVendorLoaded => vendorStatus == HomeStateStatus.loaded;
  bool get isVendorFailed => vendorStatus == HomeStateStatus.failed;

  bool get isLoading => isCategoryLoading || isVendorLoading;
  bool get hasData => category.isNotEmpty || vendors.isNotEmpty;

  bool get isNotificationsLoading =>
      notificationsStatus == HomeStateStatus.loading;
  bool get isNotificationsLoaded =>
      notificationsStatus == HomeStateStatus.loaded;
  bool get isNotificationsFailed =>
      notificationsStatus == HomeStateStatus.failed;

  bool get isBannerLoading => bannerStatus == HomeStateStatus.loading;
  bool get isBannerLoaded => bannerStatus == HomeStateStatus.loaded;
  bool get isBannerFailed => bannerStatus == HomeStateStatus.failed;

  bool get isSearchLoading => searchStatus == HomeStateStatus.loading;
  bool get isSearchLoaded => searchStatus == HomeStateStatus.loaded;
  bool get isSearchFailed => searchStatus == HomeStateStatus.failed;
  bool get isSearchEmpty => searchStatus == HomeStateStatus.empty;
  @override
  List<Object?> get props => [
    status,
    vendorStatus,
    category,
    vendors,
    subCategories,
    vendorAvailabeSlot,
    vendor,
    notificationsStatus,
    featuredVendors,
    appointmentTypeModel,
    bannerDetails,
    bannerStatus,
    paymentMethod,
    notifications,
    message,
    searchResults,
    searchStatus,
    areasOfExpertise,
    reviews,
    mostPopularVendors,
    topRatedVendors,
  ];
}
