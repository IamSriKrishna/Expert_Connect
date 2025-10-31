

part of 'appointment_bloc.dart';

class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class FetchAppointment extends AppointmentEvent {
  const FetchAppointment();

  @override
  List<Object?> get props => [];
}

class StartMeeting extends AppointmentEvent {
  final int meetingId;
  
  const StartMeeting({required this.meetingId});

  @override
  List<Object?> get props => [meetingId];
}

class EndMeeting extends AppointmentEvent {
  final int meetingId;
  
  const EndMeeting({required this.meetingId});

  @override
  List<Object?> get props => [meetingId];
}
