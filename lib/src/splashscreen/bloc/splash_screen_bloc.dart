import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_screen_event.dart';
part 'splash_screen_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashState.initial()) {
    on<InitializeSplash>(_onInitializeSplash);
  }

  static const int _splashDuration = 3;

  Future<void> _onInitializeSplash(
    InitializeSplash event,
    Emitter<SplashState> emit,
  ) async {
    emit(state.copyWith(status: () => SplashStatus.loading));
    await Future.delayed(const Duration(seconds: _splashDuration));
    emit(state.copyWith(status: () => SplashStatus.loaded));
  }
}
