import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/transaction_response.dart';
import 'package:expert_connect/src/models/transaction_summary.dart';
import 'package:expert_connect/src/models/user_models.dart';
import 'package:expert_connect/src/settings/repo/setting_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'setting_state.dart';
part 'setting_event.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final SettingRepo _settingRepo;

  final Logger _logger = Logger();
  SettingBloc(final SettingRepo settingRepo)
    : _settingRepo = settingRepo,
      super(SettingState.initial()) {
    on<FetchTransactionSummary>(_onFetchTransactionSummary);
    on<UpdateProfileImage>(_onUpdateProfileImage);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<FetchWalletSummary>(_onFetchWalletSummary);
    on<FetchUserProfile>(_onFetchUserProfile);
    on<ResetProfileImageUpdateFlag>(_onResetProfileImageUpdateFlag);
  }

  Future<void> _onUpdateUserProfile(
  UpdateUserProfile event,
  Emitter<SettingState> emit,
) async {
  emit(
    state.copyWith(
      userProfileUpdateStatus: () => UserProfileUpdateStatus.loading,
      status: () => SettingStateStatus.loading,
    ),
  );

  try {
    final success = await _settingRepo.updateUserProfile(
      name: event.name,
      country: event.country,
      state: event.state,
      phNumber: event.phNumber,
      city: event.city,
      pincode: event.pincode,
      profileImage: event.profileImage,
    );

    if (success) {
      // Fetch updated profile to reflect changes
      final updatedProfile = await _settingRepo.fetchUserProfile();

      emit(
        state.copyWith(
          userProfileUpdateStatus: () => UserProfileUpdateStatus.success,
          status: () => SettingStateStatus.success,
          userProfile: () => updatedProfile,
          message: () => "User profile updated successfully",
        ),
      );
    } else {
      emit(
        state.copyWith(
          userProfileUpdateStatus: () => UserProfileUpdateStatus.failed,
          status: () => SettingStateStatus.failed,
          message: () => "Failed to update vendor profile",
        ),
      );
    }
  } on SettingsRepo catch (e) {
    // Handle the custom SettingsRepo exception thrown from the repository
    _logger.e('SettingsRepo exception: ${e.message}');
    emit(
      state.copyWith(
        userProfileUpdateStatus: () => UserProfileUpdateStatus.failed,
        status: () => SettingStateStatus.failed,
        message: () => e.message,
      ),
    );
  } on DioException catch (e) {
    _logger.e('DioException updating vendor profile: ${e.response?.data}');
    
    String errorMessage = "Failed to update profile";
    
    // Extract specific error message from API response
    if (e.response?.data != null) {
      final responseData = e.response!.data;
      
      // Handle different error response formats
      if (responseData is Map) {
        // Check for nested error object: {error: {phone: [...]}}
        if (responseData['error'] is Map) {
          final errors = responseData['error'] as Map;
          
          // Build error message from all field errors
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              // Join multiple errors for the same field
              errorMessages.add(value.join(', '));
            } else if (value is String) {
              errorMessages.add(value);
            }
          });
          
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        } 
        // Check for direct error message: {message: "..."}
        else if (responseData['message'] != null) {
          errorMessage = responseData['message'].toString();
        }
        // Check for errors array: {errors: {...}}
        else if (responseData['errors'] is Map) {
          final errors = responseData['errors'] as Map;
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.join(', '));
            }
          });
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
          }
        }
      }
    }
    
    emit(
      state.copyWith(
        userProfileUpdateStatus: () => UserProfileUpdateStatus.failed,
        status: () => SettingStateStatus.failed,
        message: () => errorMessage,
      ),
    );
  } catch (e) {
    _logger.e('Error updating vendor profile: ${e.toString()}');
    emit(
      state.copyWith(
        userProfileUpdateStatus: () => UserProfileUpdateStatus.failed,
        status: () => SettingStateStatus.failed,
        message: () => "An unexpected error occurred: ${e.toString()}",
      ),
    );
  }
}

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(status: () => SettingStateStatus.loading));
    try {
      final userProfile = await _settingRepo.fetchUserProfile();
      emit(
        state.copyWith(
          status: () => SettingStateStatus.success,
          userProfile: () => userProfile,
          message: () => "Profile loaded successfully",
        ),
      );
    } catch (e) {
      _logger.e('Error fetching user profile: ${e.toString()}');
      emit(
        state.copyWith(
          status: () => SettingStateStatus.failed,
          message: () => e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<SettingState> emit,
  ) async {
    emit(state.copyWith(status: () => SettingStateStatus.loading));
    try {
      final success = await _settingRepo.updateProfileImage(
        profileImage: event.profileImage,
      );

      if (success) {
        emit(
          state.copyWith(
            status: () => SettingStateStatus.success,
            profileImageUpdated: () => true,
            message: () => "Profile image updated successfully",
          ),
        );
        add(FetchUserProfile());
      } else {
        emit(
          state.copyWith(
            status: () => SettingStateStatus.failed,
            message: () => "Failed to update profile image",
          ),
        );
      }
    } catch (e) {
      _logger.e('Error updating profile image: ${e.toString()}');
      emit(
        state.copyWith(
          status: () => SettingStateStatus.failed,
          message: () => e.toString(),
        ),
      );
    }
  }

  void _onResetProfileImageUpdateFlag(
    ResetProfileImageUpdateFlag event,
    Emitter<SettingState> emit,
  ) {
    emit(state.copyWith(profileImageUpdated: () => false));
  }

  Future<void> _onFetchTransactionSummary(
    FetchTransactionSummary event,
    Emitter<SettingState> emit,
  ) async {
    state.copyWith(status: () => SettingStateStatus.loading);
    try {
      final transaction = await _settingRepo.fetchTransactionSummary();
      await Future.delayed(Duration(seconds: 2));

      emit(
        state.copyWith(
          transaction: () => transaction,
          message: () => "Successfully Loaded Transaction Summary",
          status: () => SettingStateStatus.success,
        ),
      );
    } catch (e) {
      Logger().e('Error Loading Transaction Summary: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => SettingStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchWalletSummary(
    FetchWalletSummary event,
    Emitter<SettingState> emit,
  ) async {
    state.copyWith(status: () => SettingStateStatus.loading);
    try {
      final wallet = await _settingRepo.fetchwalletSummary();
      await Future.delayed(Duration(seconds: 3));

      emit(
        state.copyWith(
          wallet: () => wallet,
          message: () => "Successfully Loaded Wallet Summary",
          status: () => SettingStateStatus.success,
        ),
      );
    } catch (e) {
      Logger().e('Error Loading Transaction Wallet: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => SettingStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<SettingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: () => SettingStateStatus.loading,
        locationUpdateStatus: () => LocationUpdateStatus.initial,
      ),
    );

    try {
      final success = await _settingRepo.updateUserLocation(
        userId: authStateManager.user!.id,
        latitude: event.latitude,
        longitude: event.longitude,
        timezone: event.timezone,
      );

      if (success) {
        emit(
          state.copyWith(
            status: () => SettingStateStatus.success,
            locationUpdateStatus: () => LocationUpdateStatus.success,
            message: () => "Location updated successfully",
          ),
        );
        // Optionally refresh user profile to get updated location
        add(FetchUserProfile());
      } else {
        emit(
          state.copyWith(
            status: () => SettingStateStatus.failed,
            locationUpdateStatus: () => LocationUpdateStatus.failed,
            message: () => "Failed to update location",
          ),
        );
      }
    } catch (e) {
      _logger.e('Error updating user location: ${e.toString()}');
      emit(
        state.copyWith(
          status: () => SettingStateStatus.failed,
          locationUpdateStatus: () => LocationUpdateStatus.failed,
          message: () => e.toString(),
        ),
      );
    }
  }
}
