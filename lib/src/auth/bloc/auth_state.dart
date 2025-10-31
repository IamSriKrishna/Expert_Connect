part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registrationComplete,
  passwordResetInitiated,
  waitingForGoogleCallback,
  otpVerified,
  failed,
  passwordResetComplete,
  gettingGoogleAuthUrl,
  emailNotVerified,
  otpVerificationRequired,
}

enum DataStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel userModel;
  final String? errorMessage;
  final String language;
  final List<Category> categories;
  final DataStatus categoryStatus;
  final List<Country> country;
  final List<State> state;
  final int? selectedCityId;
  final List<City> city;
  final int? selectedCountryId;
  final int? selectedStateId;
  final List<SubCategory> subCategories;
  final DataStatus subCategoryStatus;
  final int? selectedCategoryId;
  final int? selectedSubCategoryId;
  final String? googleAuthUrl; // Add this property

  const AuthState({
    this.status = AuthStatus.initial,
    UserModel? userModel,
    this.language = "",
    this.errorMessage,
    this.categories = const [],
    this.city = const [],
    this.country = const [],
    this.state = const [],
    this.selectedCountryId,
    this.selectedCityId,
    this.selectedStateId,
    this.categoryStatus = DataStatus.initial,
    this.subCategories = const [],
    this.subCategoryStatus = DataStatus.initial,
    this.selectedCategoryId,
    this.selectedSubCategoryId,
    this.googleAuthUrl, // Add to constructor
  }) : userModel = userModel ?? const UserModel();

  AuthState copyWith({
    AuthStatus? status,
    UserModel? userModel,
    String? errorMessage,
    String? language,
    List<Category>? categories,
    List<Country>? country,
    List<City>? city,
    List<State>? state,
    DataStatus? categoryStatus,
    List<SubCategory>? subCategories,
    DataStatus? subCategoryStatus,
    int? selectedCountryId,
    int? selectedCityId,
    int? selectedStateId,
    int? selectedCategoryId,
    int? selectedSubCategoryId,
    String? googleAuthUrl, // Add to copyWith
  }) {
    return AuthState(
      status: status ?? this.status,
      language: language ?? this.language,
      userModel: userModel ?? this.userModel,
      errorMessage: errorMessage,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      categories: categories ?? this.categories,
      categoryStatus: categoryStatus ?? this.categoryStatus,
      subCategories: subCategories ?? this.subCategories,
      selectedStateId: selectedStateId ?? this.selectedStateId,
      selectedCityId: selectedCityId ?? this.selectedCityId,
      selectedCountryId: selectedCountryId ?? this.selectedCountryId,
      subCategoryStatus: subCategoryStatus ?? this.subCategoryStatus,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedSubCategoryId:
          selectedSubCategoryId ?? this.selectedSubCategoryId,
      googleAuthUrl: googleAuthUrl ?? this.googleAuthUrl, // Add to copyWith
    );
  }

  bool get isInitial => status == AuthStatus.initial;
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isRegistrationComplete => status == AuthStatus.registrationComplete;
  bool get isWaitingForGoogleCallback =>
      status == AuthStatus.waitingForGoogleCallback;

  bool get isCategoriesLoading => categoryStatus == DataStatus.loading;
  bool get isOtpVerified => status == AuthStatus.otpVerified;
  bool get isCategoriesLoaded => categoryStatus == DataStatus.success;
  bool get isCategoriesError => categoryStatus == DataStatus.failure;
  bool get isPasswordResetComplete =>
      status == AuthStatus.passwordResetComplete;
  bool get isSubCategoriesLoading => subCategoryStatus == DataStatus.loading;
  bool get isSubCategoriesLoaded => subCategoryStatus == DataStatus.success;
  bool get isSubCategoriesError => subCategoryStatus == DataStatus.failure;
  bool get isGettingGoogleAuthUrl => status == AuthStatus.gettingGoogleAuthUrl;

  @override
  List<Object?> get props => [
    status,
    googleAuthUrl,
    userModel,
    errorMessage,
    categories,
    language,
    categoryStatus,
    subCategories,
    subCategoryStatus,
    selectedCategoryId,
    selectedCityId,
    selectedStateId,
    selectedCountryId,
    selectedSubCategoryId,
  ];
}
