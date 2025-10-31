// File: lib/src/auth/bloc/auth_bloc.dart
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:expert_connect/src/auth/repo/auth_repo.dart';
import 'package:expert_connect/src/models/category.dart';
import 'package:expert_connect/src/models/city.dart';
import 'package:expert_connect/src/models/country.dart';
import 'package:expert_connect/src/models/state.dart';
import 'package:expert_connect/src/models/sub_category.dart';
import 'package:expert_connect/src/models/user_models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo _authRepository;
  final Logger _logger = Logger();

  static const int _maxRetries = 5;
  static const Duration _retryDelay = Duration(seconds: 2);

  Timer? _categoriesRetryTimer;
  Timer? _countriesRetryTimer;
  AuthBloc({required AuthRepo authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<CountryFetched>(_onCountryFetched);
    on<StateFetched>(_onStateFetched);
    on<CityFetched>(_onCityFetched);
    on<UpdateCity>(_onUpdateCity);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthOTPVerificationRequested>(_onOTPVerificationRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthForgetPasswordRequested>(_onForgetPasswordRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<_RetryCountryFetch>(_onRetryCountryFetch);
  }

  @override
  Future<void> close() {
    _categoriesRetryTimer?.cancel();
    _countriesRetryTimer?.cancel();
    return super.close();
  }


Future<void> _onGoogleLoginRequested(
  AuthGoogleLoginRequested event,
  Emitter<AuthState> emit,
) async {
  _logger.i('Google login attempt');

  emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

  try {
    // Initialize Google Sign-In with explicit configuration
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // For iOS, use the client ID from your GoogleService-Info.plist
      // For Android, this is automatically configured via google-services.json
    );

    // Clear any previous sign-in
    await googleSignIn.signOut();
    
    _logger.i('Starting Google Sign-In flow');

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      _logger.w('User cancelled Google sign-in');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Google sign-in cancelled',
      ));
      return;
    }

    _logger.i('Google user signed in: ${googleUser.email}');

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    _logger.i('Google auth obtained - Access Token: ${googleAuth.accessToken != null ? "Present" : "Missing"}');
    _logger.i('Google auth obtained - ID Token: ${googleAuth.idToken != null ? "Present" : "Missing"}');
    
    if (googleAuth.idToken == null) {
      _logger.e('Google ID token is null');
      
      // Try to get a fresh token
      final freshAuth = await googleUser.authentication;
      if (freshAuth.idToken == null) {
        throw AuthException(
          'Failed to get Google ID token. Please try again.',
          code: 'NO_ID_TOKEN',
        );
      }
      // Use fresh token if available
      _logger.i('Fresh ID token obtained,${googleAuth.idToken}');
    }
      _logger.i('Fresh ID token obtained,${googleAuth.idToken}');

    final idToken = googleAuth.idToken ?? (await googleUser.authentication).idToken;
    
    if (idToken == null) {
      throw AuthException(
        'Unable to obtain Google ID token after multiple attempts',
        code: 'NO_ID_TOKEN_RETRY_FAILED',
      );
    }

    _logger.i('Google auth successful, sending to backend');

    // Send the ID token to your backend
    final authResult = await _authRepository.googleLogin(
      idToken: idToken,
      userType: 'user', // or get this from somewhere else
    );

    if (authResult.success) {
      // Store the token if needed
      // if (authResult.token != null) {
      //   await _tokenStorage.saveToken(authResult.token!);
      // }
      
      _logger.i('Backend authentication successful');
      
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        userModel: authResult.user!,
        errorMessage: null,
      ));
    } else {
      _logger.e('Backend authentication failed: ${authResult.message}');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: authResult.message,
      ));
    }

  } on PlatformException catch (e) {
    _logger.e('Platform exception during Google auth: ${e.message}', error: e);
    String errorMessage = 'Google authentication failed';
    
    switch (e.code) {
      case 'sign_in_canceled':
        errorMessage = 'Google sign-in was cancelled';
        break;
      case 'sign_in_failed':
        errorMessage = 'Google sign-in failed. Please try again.';
        break;
      case 'network_error':
        errorMessage = 'Network error. Please check your connection.';
        break;
      default:
        errorMessage = 'Google authentication error: ${e.message}';
    }
    
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: errorMessage,
    ));
  } on AuthException catch (e) {
    _logger.e('Auth exception during Google auth: ${e.message}');
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: e.message,
    ));
  } catch (e) {
    _logger.e('Unexpected Google auth error', error: e);
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Google authentication failed: ${e.toString()}',
    ));
  }
}


  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.i('Password reset requested for email: ${event.email}');
    _logger.i('Password reset OTP: ${event.otp}');
    _logger.i('Password reset Password: ${event.password}');
    _logger.i('Password reset Confirm Password: ${event.confirmPassword}');
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      final success = await _authRepository.resetPassword(
        email: event.email,
        otp: event.otp,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      if (success) {
        _logger.i('Password reset completed successfully');
        emit(state.copyWith(status: AuthStatus.passwordResetComplete));
      } else {
        emit(state.copyWith(status: AuthStatus.failed));
      }
    } on AuthException catch (e) {
      _logger.e('Password reset failed: ${e.message}');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      _logger.e('Unexpected password reset error', error: e);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Failed to complete password reset',
        ),
      );
    }
  }

  Future<void> _onForgetPasswordRequested(
    AuthForgetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.i('Password reset requested for email: ${event.email}');
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final success = await _authRepository.forgetUserPassword(
        email: event.email,
      );
      if (success) {
        _logger.i('Password reset email sent successfully');
        emit(state.copyWith(status: AuthStatus.passwordResetInitiated));
      } else {
        _logger.i('Password reset Failed');
        emit(state.copyWith(status: AuthStatus.failed));
      }
    } on AuthException catch (e) {
      _logger.e('Password reset failed: ${e.message}');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      _logger.e('Unexpected password reset error', error: e);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Failed to initiate password reset',
        ),
      );
    }
  }

  Future<void> _onRetryCountryFetch(
    _RetryCountryFetch event,
    Emitter<AuthState> emit,
  ) async {
    add(CountryFetched(retryCount: event.retryCount));
  }

  void _scheduleRetry(VoidCallback retryCallback, Duration delay) {
    Timer(delay, retryCallback);
  }

  Future<void> _onUpdateCity(UpdateCity event, Emitter<AuthState> emit) async {
    _logger.i('Updated City: ${event.cityId}');
    emit(state.copyWith(selectedCityId: event.cityId));
  }

  Future<void> _onStateFetched(
    StateFetched event,
    Emitter<AuthState> emit,
  ) async {
    _logger.i('Fetching State for category');

    emit(
      state.copyWith(
        subCategoryStatus: DataStatus.loading,
        selectedCountryId: event.countryId,
        state: [],
      ),
    );

    try {
      final stateData = await _authRepository.getState(event.countryId);

      _logger.i(
        'Successfully fetched ${stateData.length} State for Country: ${event.countryId}',
      );

      emit(
        state.copyWith(
          state: stateData,
          subCategoryStatus: DataStatus.success,
          selectedCountryId: event.countryId,
        ),
      );
    } on AuthException catch (e) {
      _logger.e('state fetch failed: ${e.message}');
      emit(
        state.copyWith(
          subCategoryStatus: DataStatus.failure,
          errorMessage: e.message,
          state: [],
        ),
      );
    } catch (e) {
      _logger.e('Unexpected State fetch error', error: e);
      emit(
        state.copyWith(
          subCategoryStatus: DataStatus.failure,
          errorMessage: 'Failed to fetch State',
          state: [],
        ),
      );
    }
  }

  Future<void> _onCityFetched(
    CityFetched event,
    Emitter<AuthState> emit,
  ) async {
    _logger.i('Fetching City for State: ${event.stateId}');

    emit(
      state.copyWith(
        subCategoryStatus: DataStatus.loading,
        selectedStateId: event.stateId,
        city: [],
      ),
    );

    try {
      final city = await _authRepository.getCity(event.stateId);

      _logger.i(
        'Successfully fetched ${city.length} City for State: ${event.stateId}',
      );

      emit(
        state.copyWith(
          city: city,
          subCategoryStatus: DataStatus.success,
          selectedStateId: event.stateId,
        ),
      );
    } on AuthException catch (e) {
      _logger.e('City fetch failed: ${e.message}');
      emit(
        state.copyWith(
          subCategoryStatus: DataStatus.failure,
          errorMessage: e.message,
          city: [],
        ),
      );
    } catch (e) {
      _logger.e('Unexpected City fetch error', error: e);
      emit(
        state.copyWith(
          subCategoryStatus: DataStatus.failure,
          errorMessage: 'Failed to fetch City',
          city: [],
        ),
      );
    }
  }

  Future<void> _onCountryFetched(
    CountryFetched event,
    Emitter<AuthState> emit,
  ) async {
    _logger.i('Fetching countries (attempt ${event.retryCount + 1})');

    _countriesRetryTimer?.cancel();

    if (event.retryCount == 0) {
      emit(state.copyWith(subCategoryStatus: DataStatus.loading, country: []));
    }

    try {
      final countries = await _authRepository.getCountry();

      if (countries.isEmpty) {
        _logger.w('Countries data is null or empty');

        if (event.retryCount < _maxRetries) {
          _logger.i(
            'Retrying countries fetch in ${_retryDelay.inSeconds} seconds...',
          );

          _scheduleRetry(() {
            add(CountryFetched(retryCount: event.retryCount + 1));
          }, _retryDelay);

          return;
        } else {
          _logger.e('Max retries reached for countries fetch');
          emit(
            state.copyWith(
              subCategoryStatus: DataStatus.failure,
              errorMessage:
                  'Failed to fetch countries after $_maxRetries attempts',
              country: [],
            ),
          );
          return;
        }
      }

      _logger.i('Successfully fetched ${countries.length} countries');

      emit(
        state.copyWith(
          country: countries,
          subCategoryStatus: DataStatus.success,
          errorMessage: null,
        ),
      );
    } on AuthException catch (e) {
      _logger.e('Countries fetch failed: ${e.message}');

      if (event.retryCount < _maxRetries) {
        _logger.i('Retrying countries fetch due to error...');

        _scheduleRetry(() {
          add(CountryFetched(retryCount: event.retryCount + 1));
        }, _retryDelay);
      } else {
        emit(
          state.copyWith(
            subCategoryStatus: DataStatus.failure,
            errorMessage: e.message,
            country: [],
          ),
        );
      }
    } catch (e) {
      _logger.e('Unexpected countries fetch error', error: e);

      if (event.retryCount < _maxRetries) {
        _logger.i('Retrying countries fetch due to unexpected error...');

        _scheduleRetry(() {
          add(CountryFetched(retryCount: event.retryCount + 1));
        }, _retryDelay);
      } else {
        emit(
          state.copyWith(
            subCategoryStatus: DataStatus.failure,
            errorMessage: 'Failed to fetch countries',
            country: [],
          ),
        );
      }
    }
  }
Future<void> _onLoginRequested(
  AuthLoginRequested event,
  Emitter<AuthState> emit,
) async {
  _logger.i('Login attempt for email: ${event.email}');

  emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

  try {
    final userModel = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    _logger.i('Login successful for user: ${userModel.id}');

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        userModel: userModel,
        errorMessage: null,
      ),
    );
  } on AuthException catch (e) {
    if (e.code == 'OTP_REQUIRED') {
      _logger.i('OTP verification required');
      emit(
        state.copyWith(
          status: AuthStatus.otpVerificationRequired,
          userModel: e.userModel,
          errorMessage: null,
        ),
      );
    } else {
      _logger.e('Login failed: ${e.message}');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    }
  } catch (e) {
    _logger.e('Unexpected login error', error: e);
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred during login',
      ),
    );
  }
}

  Future<void> _onOTPVerificationRequested(
    AuthOTPVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.i('OTP verification attempt for email: ${event.email}');

    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      await _authRepository.verifyEmailOTP(email: event.email, otp: event.otp);

      _logger.i('OTP verification successful for email: ${event.email}');

      emit(state.copyWith(status: AuthStatus.otpVerified, errorMessage: null));
    } on AuthException catch (e) {
      _logger.e('OTP verification failed: ${e.message}');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      _logger.e('Unexpected OTP verification error', error: e);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'An unexpected error occurred during OTP verification',
        ),
      );
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    _logger.i('Signup attempt for email: ${event.email}');

    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    try {
      await _authRepository.signup(
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
        pincode: event.pinCode,
        city: state.selectedCityId!,
        country: state.selectedCountryId!,
        state: state.selectedStateId!,
        name: event.name,
        phone: event.phone,
        // organisation: event.organisation,
      );

      _logger.i('Signup successful for email: ${event.email}');
      await Future.delayed(Duration(milliseconds: 2400));

      emit(state.copyWith(status: AuthStatus.registrationComplete));
    } on AuthException catch (e) {
      _logger.e('Signup failed: ${e.message}');
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      _logger.e('Unexpected signup error', error: e);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'An unexpected error occurred during signup',
        ),
      );
    }
  }

  void _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) {
    _logger.i('User logout requested');

    emit(const AuthState());

    _logger.i('User logged out successfully');
  }
}
