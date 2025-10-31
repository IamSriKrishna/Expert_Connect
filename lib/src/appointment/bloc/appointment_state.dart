

part of 'appointment_bloc.dart';

enum AppointmentStatus { initial, loading, loaded, failed }

enum MeetingActivityStatus {
  initial,
  starting,
  started,
  ending,
  ended,
  failed,
}

class AppointmentState extends Equatable {
  final AppointmentStatus status;
  final List<AppointmentData> data;
  final MeetingActivityStatus meetingActivityStatus;
  final MeetingActivityResponse? meetingActivityResponse;
  final int? activeMeetingId;
  final String? meetingActivityError;

  const AppointmentState({
    required this.status,
    required this.data,
    this.meetingActivityStatus = MeetingActivityStatus.initial,
    this.meetingActivityResponse,
    this.activeMeetingId,
    this.meetingActivityError,
  });

  factory AppointmentState.initial() {
    return const AppointmentState(
      status: AppointmentStatus.initial,
      data: [],
      meetingActivityStatus: MeetingActivityStatus.initial,
    );
  }

  AppointmentState copyWith({
    List<AppointmentData> Function()? data,
    AppointmentStatus Function()? status,
    MeetingActivityStatus Function()? meetingActivityStatus,
    MeetingActivityResponse? Function()? meetingActivityResponse,
    int? Function()? activeMeetingId,
    String? Function()? meetingActivityError,
  }) {
    return AppointmentState(
      status: status != null ? status() : this.status,
      data: data != null ? data() : this.data,
      meetingActivityStatus: meetingActivityStatus != null 
          ? meetingActivityStatus() 
          : this.meetingActivityStatus,
      meetingActivityResponse: meetingActivityResponse != null 
          ? meetingActivityResponse() 
          : this.meetingActivityResponse,
      activeMeetingId: activeMeetingId != null 
          ? activeMeetingId() 
          : this.activeMeetingId,
      meetingActivityError: meetingActivityError != null 
          ? meetingActivityError() 
          : this.meetingActivityError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    meetingActivityStatus,
    meetingActivityResponse,
    activeMeetingId,
    meetingActivityError,
  ];
}