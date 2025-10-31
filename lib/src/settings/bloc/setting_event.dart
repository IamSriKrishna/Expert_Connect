part of 'setting_bloc.dart';

final class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

final class FetchTransactionSummary extends SettingEvent {
  const FetchTransactionSummary();

  @override
  List<Object?> get props => [];
}

final class FetchWalletSummary extends SettingEvent {
  const FetchWalletSummary();

  @override
  List<Object?> get props => [];
}

final class UpdateProfileImage extends SettingEvent {
  final MultipartFile profileImage;

  const UpdateProfileImage(this.profileImage);

  @override
  List<Object?> get props => [profileImage];
}

final class FetchUserProfile extends SettingEvent {
  const FetchUserProfile();

  @override
  List<Object?> get props => [];
}

final class UpdateUserLocation extends SettingEvent {
  final int userId;
  final String latitude;
  final String longitude;
  final String timezone;

  const UpdateUserLocation({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  @override
  List<Object?> get props => [userId, latitude, longitude, timezone];
}

final class UpdateUserProfile extends SettingEvent {
  final String name;
  final int country;
  final int state;
  final int city;
  final String phNumber;
  final String pincode;
  final MultipartFile? profileImage;

  const UpdateUserProfile({
    required this.name,
    required this.country,
    required this.state,
    required this.phNumber,
    required this.city,
    required this.pincode,
    this.profileImage,
  });

  @override
  List<Object?> get props => [
    name,
    country,
    state,
    city,
    pincode,
    phNumber,
    profileImage,
  ];
}

final class ResetProfileImageUpdateFlag extends SettingEvent {
  const ResetProfileImageUpdateFlag();

  @override
  List<Object?> get props => [];
}
