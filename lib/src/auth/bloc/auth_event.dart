part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthForgetPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String confirmPassword;

  const AuthResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, otp, password, confirmPassword];
}

class AuthLoginRequested extends AuthEvent {
  final String password;
  final String email;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [password, email];
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

class AuthGoogleCallbackReceived extends AuthEvent {
  final String callbackUrl;

  const AuthGoogleCallbackReceived(this.callbackUrl);

  @override
  List<Object?> get props => [callbackUrl];
}

class AuthSignupRequested extends AuthEvent {
  final String name;
  final String email;
  final int pinCode;
  final String phone;
  final String password;
  final String confirmPassword;

  const AuthSignupRequested({
    required this.name,
    required this.email,
    required this.pinCode,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    pinCode,
    phone,
    password,
    confirmPassword,
  ];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthOTPVerificationRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthOTPVerificationRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class UpdateCity extends AuthEvent {
  final int cityId;

  const UpdateCity(this.cityId);

  @override
  List<Object?> get props => [cityId];
}

class CityFetched extends AuthEvent {
  final int stateId;

  const CityFetched(this.stateId);

  @override
  List<Object?> get props => [stateId];
}

class StateFetched extends AuthEvent {
  final int countryId;

  const StateFetched(this.countryId);

  @override
  List<Object?> get props => [countryId];
}

class CountryFetched extends AuthEvent {
  final int retryCount;

  const CountryFetched({this.retryCount = 0});

  @override
  List<Object?> get props => [retryCount];
}

class _RetryCountryFetch extends AuthEvent {
  final int retryCount;
  const _RetryCountryFetch(this.retryCount);

  @override
  List<Object?> get props => [retryCount];
}
