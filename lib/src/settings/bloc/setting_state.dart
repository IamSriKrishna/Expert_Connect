part of 'setting_bloc.dart';

enum SettingStateStatus { initial, loading, success, failed }

enum LocationUpdateStatus { initial, success, failed }

enum UserProfileUpdateStatus { initial, loading, success, failed }

class SettingState extends Equatable {
  final SettingStateStatus status;
  final LocationUpdateStatus locationUpdateStatus;
  final String message;
  final TransactionSummary transaction;
  final TransactionResponse wallet;
  final UserProfileUpdateStatus userProfileUpdateStatus;
  final bool profileImageUpdated;
  final UserModel userProfile;

  const SettingState({
    required this.status,
    required this.locationUpdateStatus,
    required this.message,
    required this.userProfileUpdateStatus,
    required this.transaction,
    required this.wallet,
    required this.profileImageUpdated,
    required this.userProfile,
  });

  factory SettingState.initial() {
    return SettingState(
      status: SettingStateStatus.initial,
      locationUpdateStatus: LocationUpdateStatus.initial,
      message: "",
      profileImageUpdated: false,
      transaction: TransactionSummary.initial(),
      wallet: TransactionResponse.initial(),
      userProfileUpdateStatus: UserProfileUpdateStatus.initial,
      userProfile: UserModel.initial(),
    );
  }

  SettingState copyWith({
    SettingStateStatus Function()? status,
    LocationUpdateStatus Function()? locationUpdateStatus,
    String Function()? message,
    TransactionSummary Function()? transaction,
    UserProfileUpdateStatus Function()? userProfileUpdateStatus,
    UserModel Function()? userProfile,
    bool Function()? profileImageUpdated,
    TransactionResponse Function()? wallet,
  }) {
    return SettingState(
      status: status != null ? status() : this.status,
      userProfileUpdateStatus: userProfileUpdateStatus != null
          ? userProfileUpdateStatus()
          : this.userProfileUpdateStatus,
      locationUpdateStatus: locationUpdateStatus != null
          ? locationUpdateStatus()
          : this.locationUpdateStatus,
      message: message != null ? message() : this.message,
      profileImageUpdated: profileImageUpdated != null
          ? profileImageUpdated()
          : this.profileImageUpdated,
      userProfile: userProfile != null ? userProfile() : this.userProfile,
      transaction: transaction != null ? transaction() : this.transaction,
      wallet: wallet != null ? wallet() : this.wallet,
    );
  }

  @override
  List<Object?> get props => [
    status,
    locationUpdateStatus,
    message,
    transaction,
    userProfile,
    profileImageUpdated,
    userProfileUpdateStatus,
    wallet,
  ];
}
