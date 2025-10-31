import 'package:equatable/equatable.dart';
import 'package:expert_connect/src/appointment/repo/appointment_repo.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/appointment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'appointment_state.dart';
part 'appointment_event.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentImpl _appointmentImpl;

  final AuthStateManager _authStateManager;
  final Logger _logger = Logger();
  
  AppointmentBloc(
    final AppointmentImpl appointmentImpl, {
    AuthStateManager? authStateManager,
  }) : _appointmentImpl = appointmentImpl,
       _authStateManager = authStateManager ?? AuthStateManager(),
       super(AppointmentState.initial()) {
    on<FetchAppointment>(_onFetchAppointment);
    on<StartMeeting>(_onStartMeeting);
    on<EndMeeting>(_onEndMeeting);
  }

  Future<void> _onFetchAppointment(
    FetchAppointment event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      if (!_authStateManager.isLoggedIn || _authStateManager.user?.id == null) {
        _logger.w("User not logged in or user ID is null");
        emit(state.copyWith(status: () => AppointmentStatus.failed));
        return;
      }

      final userId = _authStateManager.user!.id;

      _logger.i("Fetching appointments for user ID: $userId");

      emit(state.copyWith(status: () => AppointmentStatus.loading));

      final appointments = await _appointmentImpl.listAppointment();

      _logger.i("Successfully fetched ${appointments.length} appointments");
      // await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          status: () => AppointmentStatus.loaded,
          data: () => appointments,
        ),
      );
    } catch (e) {
      _logger.e("Failed to load appointments: $e");
      emit(state.copyWith(status: () => AppointmentStatus.failed));
    }
  }

  Future<void> _onStartMeeting(
    StartMeeting event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      if (!_authStateManager.isLoggedIn || _authStateManager.user?.id == null) {
        _logger.w("User not logged in or user ID is null");
        emit(state.copyWith(
          meetingActivityStatus: () => MeetingActivityStatus.failed,
          meetingActivityError: () => "User not authenticated",
        ));
        return;
      }

      _logger.i("Starting meeting with ID: ${event.meetingId}");

      emit(state.copyWith(
        meetingActivityStatus: () => MeetingActivityStatus.starting,
        activeMeetingId: () => event.meetingId,
        meetingActivityError: () => null,
      ));

      final response = await _appointmentImpl.startMeeting(event.meetingId);

      _logger.i("Successfully started meeting: ${response.message}");
      
      emit(state.copyWith(
        meetingActivityStatus: () => MeetingActivityStatus.started,
        meetingActivityResponse: () => response,
        meetingActivityError: () => null,
      ));
    } catch (e) {
      _logger.e("Failed to start meeting: $e");
      emit(state.copyWith(
        meetingActivityStatus: () => MeetingActivityStatus.failed,
        meetingActivityError: () => e.toString(),
        activeMeetingId: () => null,
      ));
    }
  }

  Future<void> _onEndMeeting(
    EndMeeting event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      if (!_authStateManager.isLoggedIn || _authStateManager.user?.id == null) {
        _logger.w("User not logged in or user ID is null");
        emit(state.copyWith(
          meetingActivityStatus: () => MeetingActivityStatus.failed,
          meetingActivityError: () => "User not authenticated",
        ));
        return;
      }

      _logger.i("Ending meeting with ID: ${event.meetingId}");

      emit(state.copyWith(
        meetingActivityStatus: () => MeetingActivityStatus.ending,
        meetingActivityError: () => null,
      ));

      final response = await _appointmentImpl.endMeeting(event.meetingId);

      _logger.i("Successfully ended meeting: ${response.message}");
      
      emit(state.copyWith(
        meetingActivityStatus: () => MeetingActivityStatus.ended,
        meetingActivityResponse: () => response,
        activeMeetingId: () => null,
        meetingActivityError: () => null,
      ));
    } catch (e) {
      _logger.e("Failed to end meeting: $e");
      emit(state.copyWith(
        meetingActivityStatus: () => MeetingActivityStatus.failed,
        meetingActivityError: () => e.toString(),
      ));
    }
  }
}