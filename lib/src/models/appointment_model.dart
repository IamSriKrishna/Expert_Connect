class AppointmentResponse {
  final bool success;
  final List<AppointmentData> indexdata;

  AppointmentResponse({required this.success, required this.indexdata});

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentResponse(
      success: json['success'].toString().toLowerCase() == 'true',
      indexdata: (json['indexdata'] as List)
          .map((e) => AppointmentData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'indexdata': indexdata.map((e) => e.toJson()).toList(),
    };
  }
}

class AppointmentData {
  final int appointmentId;
  final int userId;
  final String username;
  final String userEmail;
  final int vendorId;
  final String vendorName;
  final String date;
  final String time;
  final String description;
  final String service;
  final int type;
  final String appointmentType;
  final int status;
  final int meetingDuration;
  final String agoraChannel;
  final String vendorToken;
  final String userToken;

  AppointmentData({
    required this.appointmentId,
    required this.userId,
    required this.username,
    required this.userEmail,
    required this.meetingDuration,
    required this.vendorId,
    required this.vendorName,
    required this.date,
    required this.time,
    required this.description,
    required this.service,
    required this.type,
    required this.appointmentType,
    required this.status,
    required this.agoraChannel,
    required this.vendorToken,
    required this.userToken,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      appointmentId: json['appointment_id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      userEmail: json['user_email'] as String,
      vendorId: json['vendor_id'] as int,
      meetingDuration: json['meeting_duration'] as int,
      vendorName: json['vendorname'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      description: json['description'] as String,
      service: json['service'] as String,
      type: json['type'] as int,
      appointmentType: json['appointment_type'] as String,
      status: json['status'] as int,
      agoraChannel: json['agora_channel'] as String,
      vendorToken: json['vendor_token'] as String,
      userToken: json['user_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'user_id': userId,
      'meeting_duration': meetingDuration,
      'username': username,
      'user_email': userEmail,
      'vendor_id': vendorId,
      'vendorName': vendorName,
      'date': date,
      'time': time,
      'description': description,
      'service': service,
      'type': type,
      'appointment_type': appointmentType,
      'status': status,
      'agora_channel': agoraChannel,
      'vendor_token': vendorToken,
      'user_token': userToken,
    };
  }
}