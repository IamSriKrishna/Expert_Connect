import 'dart:io' show Platform;

import 'package:expert_connect/src/appointment/bloc/appointment_bloc.dart';
import 'package:expert_connect/src/appointment/widgets/mini_call_screen.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

const String appId = 'd1322e203b5643a494a5aff757ad5f1b';

class AgoraCallScreen extends StatefulWidget {
  final String token;
  final String channel;
  final int meetingId;
  final String? participantName;
  final String time;
  final int meetingDuration;

  const AgoraCallScreen({
    super.key,
    required this.channel,
    required this.token,
    required this.meetingId,
    required this.time,
    required this.meetingDuration,
    this.participantName,
  });

  @override
  State<AgoraCallScreen> createState() => _AgoraCallScreenState();
}

class _AgoraCallScreenState extends State<AgoraCallScreen>
    with TickerProviderStateMixin {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isCallConnected = false;
  bool _showControls = true;
  bool _isScreenSharing = false;
  bool _isDisposed = false;
  Timer? _autoEndTimer;
  DateTime? _meetingEndTime;

  late RtcEngine _engine;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  Timer? _hideControlsTimer;
  Timer? _callTimer;

  Duration _callDuration = Duration.zero;
  String _connectionStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAgora();
    _startHideControlsTimer();
    _setupAutoEndTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPrivacyNoticeDialog();
    });
  }

  Future<void> _showPrivacyNoticeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.videocam_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Privacy Notice',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFEDF2F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Color(0xFF4299E1),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your privacy is protected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'This video call is not being recorded. Your conversation remains private and confidential.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF718096),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFD1FAE5), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_rounded,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'We value your privacy. This call is end-to-end encrypted for your security.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF047857),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A5568),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4299E1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Continue to Call',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setupAutoEndTimer() {
    try {
      final timeFormat = DateFormat('h:mm a');
      final now = DateTime.now();
      final meetingTime = timeFormat.parse(widget.time);

      final meetingStart = DateTime(
        now.year,
        now.month,
        now.day,
        meetingTime.hour,
        meetingTime.minute,
      );

      _meetingEndTime = meetingStart.add(
        Duration(minutes: widget.meetingDuration),
      );

      final timeUntilEnd = _meetingEndTime!.difference(now);

      if (timeUntilEnd.isNegative) {
        _autoEndCall();
        return;
      }

      _autoEndTimer = Timer(timeUntilEnd, () {
        _autoEndCall();
      });

      debugPrint(
        'Meeting will auto-end at: ${DateFormat('h:mm a').format(_meetingEndTime!)}',
      );
      debugPrint('Auto-end timer set for: ${timeUntilEnd.inMinutes} minutes');
    } catch (e) {
      debugPrint('Error setting up auto-end timer: $e');
    }
  }

  void _autoEndCall() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting time has ended'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _endCallCompletely();
        }
      });
    }
  }

  Future<void> _startScreenShare() async {
    try {
      debugPrint('Starting screen share...');

      // Step 1: Stop camera preview and disable camera track
      await _engine.stopPreview();
      await _engine.enableLocalVideo(false);

      // Step 2: Start screen capture with Android-optimized settings
      await _engine.startScreenCapture(
        const ScreenCaptureParameters2(
          captureAudio: false, // Set to false for better compatibility
          captureVideo: true,
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(
              width: 720,
              height: 1280,
            ), // Portrait orientation
            frameRate: 15,
            bitrate: 1500,
          ),
        ),
      );

      // Step 3: Small delay to ensure screen capture is ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Update channel media options - CRITICAL ORDER
      await _engine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishCameraTrack: false,
          publishScreenTrack: true,
          publishScreenCaptureVideo: true,
          publishScreenCaptureAudio: false,
          publishMicrophoneTrack: !_isMuted, // Keep mic state
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (mounted) {
        setState(() {
          _isScreenSharing = true;
          _isCameraOff = true; // Mark camera as off since we're sharing screen
        });
      }

      HapticFeedback.selectionClick();
      _startHideControlsTimer();

      debugPrint('✅ Screen sharing started successfully');

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Screen sharing started'),
            backgroundColor: Colors.green.withOpacity(0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error starting screen share: $e');

      // Rollback on error
      try {
        await _engine.stopScreenCapture();
        await _engine.enableLocalVideo(true);
        await _engine.startPreview();
        await _engine.updateChannelMediaOptions(
          const ChannelMediaOptions(
            publishCameraTrack: true,
            publishScreenTrack: false,
          ),
        );
      } catch (rollbackError) {
        debugPrint('Error during rollback: $rollbackError');
      }

      if (mounted) {
        setState(() {
          _isScreenSharing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start screen sharing: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _stopScreenShare() async {
    try {
      debugPrint('Stopping screen share...');

      // Step 1: Stop screen capture
      await _engine.stopScreenCapture();

      // Step 2: Re-enable camera
      await _engine.enableLocalVideo(true);

      // Step 3: Small delay
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 4: Restart camera preview
      await _engine.startPreview();

      // Step 5: Update channel to publish camera again
      await _engine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishCameraTrack: true,
          publishScreenTrack: false,
          publishScreenCaptureVideo: false,
          publishScreenCaptureAudio: false,
          publishMicrophoneTrack: !_isMuted,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (mounted) {
        setState(() {
          _isScreenSharing = false;
          _isCameraOff = false; // Re-enable camera
        });
      }

      HapticFeedback.selectionClick();
      _startHideControlsTimer();

      debugPrint('✅ Screen sharing stopped successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Screen sharing stopped'),
            backgroundColor: Colors.orange.withOpacity(0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error stopping screen share: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop screen sharing: ${e.toString()}'),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    }
  }

  Future<void> _toggleScreenShare() async {
    if (_isScreenSharing) {
      await _stopScreenShare();
    } else {
      // Check for system alert window permission on Android
      if (Platform.isAndroid) {
        final systemAlertWindowPermission = await Permission.systemAlertWindow
            .request();

        if (systemAlertWindowPermission != PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Screen sharing permission is required'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: openAppSettings,
                ),
              ),
            );
          }
          return;
        }
      }

      await _startScreenShare();
    }
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  Future<bool> _onWillPop() async {
    if (_isCallConnected && _remoteUserJoined) {
      // Minimize to mini mode
      _minimizeToMiniMode();
      return true;
    } else {
      await _endCallCompletely();
      return true;
    }
  }

  void _minimizeToMiniMode() {
    // Create call manager
    final callManager = CallManager(
      engine: _engine,
      channel: widget.channel,
      token: widget.token,
      meetingId: widget.meetingId,
      participantName: widget.participantName,
      remoteUid: _remoteUid,
      callDuration: _callDuration,
      callTimer: _callTimer,
    );

    // Transfer current states
    callManager.isMuted = _isMuted;
    callManager.isCameraOff = _isCameraOff;
    callManager.isSpeakerOn = _isSpeakerOn;
    callManager.isScreenSharing = _isScreenSharing;

    // Cancel timers only (don't dispose animation controllers manually)
    _hideControlsTimer?.cancel();

    // Show mini overlay
    _showMiniOverlay(callManager);

    // Navigate back (dispose will be called automatically by Flutter)
    Navigator.of(context).pop();
  }

  void _showMiniOverlay(CallManager callManager) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => CallManagerProvider(
        callManager: callManager,
        child: MiniCallOverlay(
          onMaximize: () {
            overlayEntry.remove();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CallManagerProvider(
                  callManager: callManager,
                  child: AgoraCallResumeScreen(
                    engine: _engine,
                    meetingId: widget.meetingId,
                  ),
                ),
              ),
            );
          },
          onEndCall: () {
            overlayEntry.remove();
            callManager.endCallCompletely(widget.meetingId);
          },
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  Future<void> _initAgora() async {
    try {
      final permissions = await [
        Permission.microphone,
        Permission.camera,
      ].request();

      if (permissions[Permission.microphone] != PermissionStatus.granted ||
          permissions[Permission.camera] != PermissionStatus.granted) {
        _showPermissionDialog();
        return;
      }

      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        const RtcEngineContext(
          appId: appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      _registerEventHandlers();

      await _engine.enableVideo();
      await _engine.enableAudio();
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _engine.startPreview();

      try {
        await _engine.setEnableSpeakerphone(_isSpeakerOn);
      } catch (e) {
        debugPrint('Speaker setting failed (safe to ignore): $e');
      }

      await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channel,
        uid: authStateManager.user!.id,
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing Agora: $e');
      _updateConnectionStatus('Connection failed');
      _showErrorDialog('Failed to initialize video call. Please try again.');
    }
  }

  void _registerEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
            _isCallConnected = true;
            _connectionStatus = 'Connected';
          });
          _startCallTimer();
          HapticFeedback.lightImpact();
        },

        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
            _remoteUserJoined = true;
            _connectionStatus = widget.participantName ?? 'Participant joined';
          });

          context.read<AppointmentBloc>().add(
            StartMeeting(meetingId: widget.meetingId),
          );

          HapticFeedback.lightImpact();
        },

        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("Remote user $remoteUid left channel");
              setState(() {
                _remoteUid = null;
                _remoteUserJoined = false;
                _connectionStatus = 'Participant left';
              });
            },

        onConnectionStateChanged:
            (
              RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason,
            ) {
              _updateConnectionStatus(_getConnectionStatusText(state));
            },

        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('Token will expire, should refresh token');
          _updateConnectionStatus('Reconnecting...');
        },

        // CRITICAL: Monitor local video state changes
        onLocalVideoStateChanged:
            (
              VideoSourceType source,
              LocalVideoStreamState state,
              LocalVideoStreamReason reason,
            ) {
              debugPrint('📹 Local video state changed:');
              debugPrint('  Source: $source');
              debugPrint('  State: $state');
              debugPrint('  Reason: $reason');

              if (source == VideoSourceType.videoSourceScreen) {
                debugPrint('🖥️ SCREEN SHARE event detected!');

                if (state ==
                    LocalVideoStreamState.localVideoStreamStateStopped) {
                  debugPrint('⚠️ Screen share stopped');
                } else if (state ==
                    LocalVideoStreamState.localVideoStreamStateCapturing) {
                  debugPrint('✅ Screen share is capturing');
                } else if (state ==
                    LocalVideoStreamState.localVideoStreamStateEncoding) {
                  debugPrint('✅ Screen share is encoding and streaming');
                } else if (state ==
                    LocalVideoStreamState.localVideoStreamStateFailed) {
                  debugPrint('❌ Screen share FAILED - Reason: $reason');

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Screen sharing failed. Please try again.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },

        // Monitor remote video state
        onRemoteVideoStateChanged:
            (
              RtcConnection connection,
              int remoteUid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed,
            ) {
              debugPrint('📺 Remote video state changed:');
              debugPrint('  Remote UID: $remoteUid');
              debugPrint('  State: $state');
              debugPrint('  Reason: $reason');
            },

        // Monitor when remote user publishes/unpublishes screen
        onUserInfoUpdated: (int uid, UserInfo info) {
          debugPrint('👤 User info updated: uid=$uid');
        },
      ),
    );
  }

  void _updateConnectionStatus(String status) {
    if (mounted) {
      setState(() {
        _connectionStatus = status;
      });
    }
  }

  String _getConnectionStatusText(ConnectionStateType state) {
    switch (state) {
      case ConnectionStateType.connectionStateConnected:
        return 'Connected';
      case ConnectionStateType.connectionStateReconnecting:
        return 'Reconnecting...';
      case ConnectionStateType.connectionStateFailed:
        return 'Connection failed';
      case ConnectionStateType.connectionStateDisconnected:
        return 'Disconnected';
      default:
        return 'Connecting...';
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = Duration(seconds: timer.tick);
        });
      }
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _isCallConnected) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  Future<void> _toggleMute() async {
    await _engine.muteLocalAudioStream(!_isMuted);
    setState(() {
      _isMuted = !_isMuted;
    });
    HapticFeedback.selectionClick();
    _startHideControlsTimer();
  }

  Future<void> _toggleCamera() async {
    await _engine.muteLocalVideoStream(!_isCameraOff);
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
    HapticFeedback.selectionClick();
    _startHideControlsTimer();
  }

  Future<void> _toggleSpeaker() async {
    try {
      await _engine.setEnableSpeakerphone(!_isSpeakerOn);
      setState(() {
        _isSpeakerOn = !_isSpeakerOn;
      });
      HapticFeedback.selectionClick();
      _startHideControlsTimer();
    } catch (e) {
      debugPrint('Error toggling speaker: $e');
    }
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
    HapticFeedback.selectionClick();
    _startHideControlsTimer();
  }

  Future<void> _minimizeCall() async {
    HapticFeedback.lightImpact();
    _minimizeToMiniMode();
  }

  Future<void> _endCallCompletely() async {
    HapticFeedback.heavyImpact();

    context.read<AppointmentBloc>().add(
      EndMeeting(meetingId: widget.meetingId),
    );
    Navigator.pop(context);
    await _dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Camera and microphone permissions are required for video calls.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    // Prevent double disposal
    if (_isDisposed) return;
    _isDisposed = true;

    // Safely dispose animation controllers
    _pulseController.dispose();
    _fadeController.dispose();

    _hideControlsTimer?.cancel();
    _callTimer?.cancel();
    _autoEndTimer?.cancel();
    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              _buildMainVideoArea(),
              _buildTopStatusBar(),
              _buildLocalVideoPreview(),
              _buildBottomControls(),
              if (!_isCallConnected) _buildConnectionOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainVideoArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _remoteUserJoined
          ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: widget.channel),
              ),
            )
          : _buildWaitingScreen(),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade900, Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 120 + (_pulseController.value * 20),
                  height: 120 + (_pulseController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      0.1 - (_pulseController.value * 0.1),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white70,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              _connectionStatus,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            if (_isCallConnected)
              Text(
                'Waiting for ${widget.participantName ?? 'participant'} to join...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatusBar() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24,
          right: 24,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isCallConnected
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isCallConnected ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCallConnected ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCallConnected
                        ? _formatDuration(_callDuration)
                        : _connectionStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _minimizeCall,
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideoPreview() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 100,
      right: 16,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.7,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isScreenSharing
                  ? Colors.blue.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _localUserJoined
                ? Stack(
                    children: [
                      if (_isScreenSharing)
                        Container(
                          color: Colors.blue.shade900,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.screen_share,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sharing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (!_isCameraOff)
                        AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey.shade900,
                          child: const Center(
                            child: Icon(
                              Icons.videocam_off,
                              color: Colors.white70,
                              size: 32,
                            ),
                          ),
                        ),
                      if (_isMuted)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.mic_off,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  )
                : Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white70,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: _showControls ? MediaQuery.of(context).padding.bottom + 32 : -200,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              isActive: !_isMuted,
              onPressed: _toggleMute,
              backgroundColor: _isMuted ? Colors.red : null,
            ),
            _buildControlButton(
              icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
              isActive: !_isCameraOff,
              onPressed: _toggleCamera,
              backgroundColor: _isCameraOff ? Colors.red : null,
            ),
            _buildControlButton(
              icon: _isScreenSharing
                  ? Icons.stop_screen_share
                  : Icons.screen_share,
              isActive: _isScreenSharing,
              onPressed: _toggleScreenShare,
              backgroundColor: _isScreenSharing ? Colors.blue : null,
            ),
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              isActive: true,
              onPressed: _isScreenSharing ? () {} : _switchCamera,
            ),
            _buildControlButton(
              icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              isActive: _isSpeakerOn,
              onPressed: _toggleSpeaker,
            ),
            _buildControlButton(
              icon: Icons.call_end,
              isActive: false,
              onPressed: _endCallCompletely,
              backgroundColor: Colors.red,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
    double size = 24,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                backgroundColor ??
                (isActive
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1)),
            border: Border.all(
              color: isActive
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  Widget _buildConnectionOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: 24),
              Text(
                _connectionStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we connect you...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
