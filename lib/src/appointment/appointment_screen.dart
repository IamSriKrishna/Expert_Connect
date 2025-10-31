// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/appointment/bloc/appointment_bloc.dart';
import 'package:expert_connect/src/appointment/repo/appointment_repo.dart';
import 'package:expert_connect/src/appointment/widgets/appointment_shimmer.dart';
import 'package:expert_connect/src/models/appointment_model.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<bool> _checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool cameraGranted =
        statuses[Permission.camera] == PermissionStatus.granted;
    bool microphoneGranted =
        statuses[Permission.microphone] == PermissionStatus.granted;

    return cameraGranted && microphoneGranted;
  }

  Future<void> _handlePermissionDenied() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Permissions Required',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To join the video call, we need access to:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              _buildPermissionItem(Icons.videocam, 'Camera', 'for video calls'),
              SizedBox(height: 8),
              _buildPermissionItem(Icons.mic, 'Microphone', 'for audio calls'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Color(0xFF718096))),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              icon: Icon(Icons.settings, size: 16),
              label: Text('Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4299E1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(0xFF4299E1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Color(0xFF4299E1), size: 14),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 11, color: Color(0xFF718096)),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // Updated methods that work with your current data structure
  // Replace the problematic methods with these:

  bool _canJoinMeeting(String dateStr, String timeStr, int status) {
    // Only allow joining if status is 1 (scheduled) or 2 (rescheduled)
    if (status != 1 && status != 2) return false;

    try {
      final now = DateTime.now();
      final appointmentDateTime = _parseAppointmentDateTime(dateStr, timeStr);
      final meetingEndTime = appointmentDateTime.add(Duration(hours: 1));

      return now.isAfter(appointmentDateTime) && now.isBefore(meetingEndTime);
    } catch (e) {
      return false;
    }
  }

  DateTime _parseAppointmentDateTime(String dateStr, String timeStr) {
    try {
      // Parse the date (e.g., "3 August 2025")
      final dateParts = dateStr.split(' ');
      final day = int.parse(dateParts[0]);
      final month = _getMonthNumber(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Parse the time (e.g., "01:30 PM")
      final timeParts = timeStr.split(' ');
      final isPM = timeParts[1].toUpperCase() == 'PM';
      final hourMinute = timeParts[0].split(':');
      var hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      // Convert to 24-hour format
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now().add(
        Duration(days: 365),
      ); // Far future date if parsing fails
    }
  }

  int _getMonthNumber(String month) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return months[month] ?? 1;
  }

  String _getTimeStatus(String dateStr, String timeStr) {
    try {
      final now = DateTime.now();
      final appointmentDateTime = _parseAppointmentDateTime(dateStr, timeStr);
      final meetingEndTime = appointmentDateTime.add(Duration(hours: 1));

      if (now.isBefore(appointmentDateTime)) {
        // Future appointment
        final difference = appointmentDateTime.difference(now);

        if (difference.inDays > 0) {
          return 'Starts in ${difference.inDays}d ${difference.inHours % 24}h';
        } else if (difference.inHours > 0) {
          return 'Starts in ${difference.inHours}h ${difference.inMinutes % 60}m';
        } else if (difference.inMinutes > 0) {
          return 'Starts in ${difference.inMinutes}m';
        } else {
          return 'Starting soon';
        }
      } else if (now.isAfter(meetingEndTime)) {
        // Past appointment (expired)
        final timeSinceEnd = now.difference(meetingEndTime);

        if (timeSinceEnd.inDays > 0) {
          return 'Expired ${timeSinceEnd.inDays}d ago';
        } else if (timeSinceEnd.inHours > 0) {
          return 'Expired ${timeSinceEnd.inHours}h ago';
        } else {
          return 'Recently expired';
        }
      } else {
        // Current appointment (active)
        final timeLeft = meetingEndTime.difference(now);

        if (timeLeft.inMinutes > 0) {
          return 'Active (${timeLeft.inMinutes}m left)';
        } else {
          return 'Expiring soon';
        }
      }
    } catch (e) {
      return 'Time unavailable';
    }
  }

  Widget _buildAppointmentCard(AppointmentData data, int index) {
    final canJoin = _canJoinMeeting(data.date, data.time, data.status);
    final timeStatus = _getTimeStatus(data.date, data.time);

    bool isExpired =
        timeStatus.contains('Expired') || timeStatus.contains('ago');
    bool isActive = timeStatus.contains('Active');
    bool isFuture =
        timeStatus.contains('Starts in') ||
        timeStatus.contains('Starting soon');

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (data.status == 1 || data.status == 2) {
              // Scheduled or Rescheduled
              if (canJoin) {
                await _showJoinOptions(data);
              } else {
                await _showTimeRestrictionDialog(data.date, data.time);
              }
            } else {
              // For pending, completed, or cancelled - show status dialog
              await _showStatusDialog(data);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? Color(0xFF10B981).withOpacity(0.15)
                      : isExpired
                      ? Color(0xFFEF4444).withOpacity(0.1)
                      : Color(0xFF4F46E5).withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and status
                  Row(
                    children: [
                      _buildModernAvatar(data.vendorName),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.vendorName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              data.service,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // _buildModernStatusChip(
                      //   timeStatus,
                      //   isActive,
                      //   isExpired,
                      //   isFuture,
                      // ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Date and time info with modern design
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            Icons.calendar_today_outlined,
                            'Date',
                            data.date,
                            Color(0xFF4F46E5),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Color(0xFFE2E8F0),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            Icons.access_time_outlined,
                            'Time',
                            data.time,
                            Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Action button
                  _buildModernActionButton(
                    canJoin,
                    isExpired,
                    isActive,
                    data.status,
                    data,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAvatar(String name) {
    String initials = name
        .split(' ')
        .map((word) => word[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatusChip(
    String status,
    bool isActive,
    bool isExpired,
    bool isFuture,
  ) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (isActive) {
      backgroundColor = Color(0xFF10B981);
      textColor = Colors.white;
      icon = Icons.play_circle_filled;
    } else if (isExpired) {
      backgroundColor = Color(0xFFEF4444);
      textColor = Colors.white;
      icon = Icons.schedule;
    } else if (isFuture) {
      backgroundColor = Color(0xFFF59E0B);
      textColor = Colors.white;
      icon = Icons.upcoming;
    } else {
      backgroundColor = Color(0xFF6B7280);
      textColor = Colors.white;
      icon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 14),
          SizedBox(width: 6),
          Text(
            status.length > 15 ? status.substring(0, 12) + '...' : status,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: accentColor, size: 16),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton(
    bool canJoin,
    bool isExpired,
    bool isActive,
    int status,
    AppointmentData appointment,
  ) {
    // Handle different statuses
    switch (status) {
      case 0: // Pending
        return Container(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {}, // Will be handled by card tap
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, size: 20),
                SizedBox(width: 8),
                Text(
                  'Pending Approval',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );

      case 1: // Scheduled
      case 2: // Rescheduled
        if (isExpired) {
          return Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, color: Color(0xFF9CA3AF), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Meeting Expired',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canJoin
                ? () {
                    _joinMeetingInApp(appointment);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canJoin ? Color(0xFF10B981) : Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(canJoin ? Icons.videocam : Icons.schedule, size: 20),
                SizedBox(width: 8),
                Text(
                  canJoin
                      ? 'Join Meeting'
                      : (status == 2 ? 'Rescheduled' : 'Scheduled'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );

      case 3: // Completed
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 8),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

      case 4: // Cancelled
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFEF4444).withOpacity(0.3)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 8),
                Text(
                  'Cancelled',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E7EB)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline, color: Color(0xFF9CA3AF), size: 20),
                SizedBox(width: 8),
                Text(
                  'Unknown Status',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Future<void> _showTimeRestrictionDialog(
    String appointmentDate,
    String appointmentTime,
  ) async {
    String status = _getTimeStatus(appointmentDate, appointmentTime);
    IconData icon;
    Color iconColor;
    String title;
    String message;

    if (status.contains('Starts in') || status.contains('Starting soon')) {
      icon = Icons.schedule;
      iconColor = Color(0xFFF59E0B);
      title = 'Meeting Not Started';
      message =
          'This meeting will start at the scheduled time and will be available for 1 hour.\n\n$status';
    } else if (status.contains('Expired') || status.contains('ago')) {
      icon = Icons.access_time_filled;
      iconColor = Color(0xFFEF4444);
      title = 'Meeting Expired';
      message =
          'This meeting was available for 1 hour after the scheduled time and has now expired.\n\n$status';
    } else {
      icon = Icons.error;
      iconColor = Color(0xFF9CA3AF);
      title = 'Meeting Unavailable';
      message = 'Unable to determine meeting availability.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              height: 1.4,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4299E1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showJoinOptions(AppointmentData appointment) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.videocam, color: Colors.white, size: 24),
            ),
            SizedBox(height: 16),
            Text(
              'Join Video Call',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Choose how you\'d like to join:',
              style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildJoinButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _joinMeetingInApp(appointment);
                    },
                    icon: Icons.videocam,
                    label: 'Join In-App',
                    isPrimary: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildJoinButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // _openInExternalBrowser(appointment);
                    },
                    icon: Icons.open_in_browser,
                    label: 'Browser',
                    isPrimary: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Color(0xFF718096))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Color(0xFF4299E1) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Color(0xFF4299E1),
          elevation: 0,
          side: isPrimary
              ? null
              : BorderSide(color: Color(0xFF4299E1), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Future<void> _joinMeetingInApp(AppointmentData appointment) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          margin: EdgeInsets.all(40),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4299E1)),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Checking permissions...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      bool permissionsGranted = await _checkAndRequestPermissions();

      // Close the loading dialog first
      Navigator.of(context).pop();

      if (permissionsGranted) {
        Logger().d("vendorToken:${appointment.vendorToken}");
        Get.toNamed(
          RoutesName.agoraCallScreen,
          arguments: {
            'channelName': appointment.agoraChannel,
            'token': appointment.userToken,
            'clientName': appointment.username,
            'appointmentId': appointment.appointmentId,
            'meetingId': appointment.appointmentId,
            'isVideo': true,
            "time": appointment.time,
            "meeting_duration": appointment.meetingDuration,
          },
        );
      } else {
        await _handlePermissionDenied();
      }
    } catch (e) {
      // Ensure dialog is closed in case of error
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorSnackBar('Error checking permissions');
    }
  }
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(message, style: TextStyle(fontSize: 13)),
          ],
        ),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AppointmentBloc(AppointmentImpl())..add(FetchAppointment()),
      child: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                CommonWidgets.appBar(text: "Appointment"),
                if (state.status == AppointmentStatus.loading)
                  AppointmentShimmer.buildAppointmentListShimmer(),
                if (state.status == AppointmentStatus.failed)
                  SliverFillRemaining(child: _buildEmptyState()),
                if (state.data.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverList.builder(
                      itemCount: state.data.length,
                      itemBuilder: (context, index) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildAppointmentCard(
                              state.data[index],
                              index,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Color(0xFFE2E8F0), width: 2),
            ),
            child: Icon(
              Icons.calendar_today,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No Appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'You don\'t have any appointments scheduled.',
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusDialog(AppointmentData appointment) async {
    String title;
    String message;
    IconData icon;
    Color primaryColor;
    Color backgroundColor;
    List<Widget> actions = [];

    switch (appointment.status) {
      case 0: // Pending
        title = 'Appointment Pending';
        message =
            'Your appointment request is being reviewed by the expert. You\'ll receive a notification once it\'s confirmed.';
        icon = Icons.hourglass_empty_rounded;
        primaryColor = Color(0xFFF59E0B);
        backgroundColor = Color(0xFFFEF3C7);
        actions = [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel Request',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('OK'),
          ),
        ];
        break;

      case 1: // Scheduled
        title = 'Appointment Confirmed';
        message =
            'Your appointment has been confirmed! The meeting will be available from the scheduled time and remain active for 1 hour.';
        icon = Icons.event_available_rounded;
        primaryColor = Color(0xFF10B981);
        backgroundColor = Color(0xFFD1FAE5);
        actions = [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add reschedule logic here
            },
            child: Text(
              'Reschedule',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Got it'),
          ),
        ];
        break;

      case 2: // Rescheduled
        title = 'Appointment Rescheduled';
        message =
            'Your appointment has been rescheduled to a new time. The meeting will be available from the new scheduled time.';
        icon = Icons.update_rounded;
        primaryColor = Color(0xFF3B82F6);
        backgroundColor = Color(0xFFDBEAFE);
        actions = [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Show appointment details
            },
            child: Text(
              'View Details',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Understood'),
          ),
        ];
        break;

      case 3: // Completed
        title = 'Appointment Completed';
        message =
            'This appointment has been successfully completed. Thank you for using our service!';
        icon = Icons.check_circle_rounded;
        primaryColor = Color(0xFF059669);
        backgroundColor = Color(0xFFECFDF5);
        actions = [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add feedback/rating logic here
            },
            child: Text(
              'Leave Review',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Close'),
          ),
        ];
        break;

      case 4: // Cancelled
        title = 'Appointment Cancelled';
        message =
            'This appointment has been cancelled. If you need to reschedule, please book a new appointment.';
        icon = Icons.cancel_rounded;
        primaryColor = Color(0xFFEF4444);
        backgroundColor = Color(0xFFFEE2E2);
        actions = [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add book new appointment logic here
            },
            child: Text('Book New', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('OK'),
          ),
        ];
        break;

      default:
        title = 'Unknown Status';
        message = 'Unable to determine appointment status.';
        icon = Icons.help_outline_rounded;
        primaryColor = Color(0xFF6B7280);
        backgroundColor = Color(0xFFF3F4F6);
        actions = [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('OK'),
          ),
        ];
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with colored background
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Appointment info card
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4F46E5),
                                        Color(0xFF7C3AED),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      appointment.vendorName[0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appointment.vendorName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      Text(
                                        appointment.service,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        appointment.date,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        appointment.time,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16),

                      // Message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 24),

                      // Actions
                      Row(
                        children: actions.map((action) {
                          int index = actions.indexOf(action);
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                left: index == 0 ? 0 : 6,
                                right: index == actions.length - 1 ? 0 : 6,
                              ),
                              child: action,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
