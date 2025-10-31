part of 'splash_screen_bloc.dart';

enum SplashStatus { initial, loading, loaded }

final class SplashState extends Equatable {
  final SplashStatus status;
  const SplashState({required this.status});

  factory SplashState.initial() {
    return SplashState(status: SplashStatus.initial);
  }

  SplashState copyWith({SplashStatus Function()? status}) {
    return SplashState(status: status != null ? status() : this.status);
  }

  @override
  List<Object?> get props => [status];
}
