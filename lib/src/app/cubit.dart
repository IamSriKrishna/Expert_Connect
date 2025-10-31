import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordVisibilityCubit extends Cubit<bool> {
  PasswordVisibilityCubit() : super(true);

  void toggleVisibility() {
    emit(!state);
  }
}

class SignedInCubit extends Cubit<bool> {
  SignedInCubit() : super(false);
  void toggle(bool value) {
    emit(value);
  }
}

class BottomCubit extends Cubit<int> {
  BottomCubit() : super(0);
  void changeIndex(int value) {
    emit(value);
  }
}

class HomeTabControllerCubit extends Cubit<int>{
  HomeTabControllerCubit() : super(0);
  void changeTab(int value) {
    emit(value);
  }
}

// Shimmer State
class ShimmerState {
  final AnimationController? controller;
  final bool isActive;

  const ShimmerState({
    this.controller,
    this.isActive = false,
  });

  ShimmerState copyWith({
    AnimationController? controller,
    bool? isActive,
  }) {
    return ShimmerState(
      controller: controller ?? this.controller,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Shimmer Cubit
class ShimmerCubit extends Cubit<ShimmerState> {
  ShimmerCubit() : super(const ShimmerState());

  void initializeController(TickerProvider vsync) {
    if (state.controller != null) {
      state.controller!.dispose();
    }
    
    final controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );
    
    emit(state.copyWith(controller: controller, isActive: true));
    
    // Add a small delay to ensure the widget is mounted
    Future.microtask(() {
      if (!isClosed && state.controller != null) {
        state.controller!.repeat();
      }
    });
  }

  void startAnimation() {
    if (!isClosed && state.controller != null && !state.isActive) {
      state.controller!.repeat();
      emit(state.copyWith(isActive: true));
    }
  }

  void stopAnimation() {
    if (!isClosed && state.controller != null && state.isActive) {
      state.controller!.stop();
      emit(state.copyWith(isActive: false));
    }
  }

  void pauseAnimation() {
    if (!isClosed && state.controller != null && state.isActive) {
      state.controller!.stop();
      emit(state.copyWith(isActive: false));
    }
  }

  void resumeAnimation() {
    if (!isClosed && state.controller != null && !state.isActive) {
      state.controller!.repeat();
      emit(state.copyWith(isActive: true));
    }
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}
