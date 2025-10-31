import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CallManager {
  final RtcEngine engine;
  final String channel;
  final String token;
  final int meetingId;
  final String? participantName;
  int? remoteUid;
  Duration callDuration;
  Timer? callTimer;
  bool isMuted = false;
  bool isCameraOff = false;
  bool isScreenSharing = false;
  bool isSpeakerOn = true;

  CallManager({
    required this.engine,
    required this.channel,
    required this.token,
    required this.meetingId,
    this.participantName,
    this.remoteUid,
    required this.callDuration,
    this.callTimer,
  }) {
    if (callTimer == null) {
      _startCallTimer();
    }
  }

  Future<void> toggleScreenShare() async {
    if (isScreenSharing) {
      await stopScreenShare();
    } else {
      await startScreenShare();
    }
  }

  Future<void> startScreenShare() async {
    try {
      await engine.stopPreview();
      await engine.muteLocalVideoStream(true);

      await engine.startScreenCapture(
        const ScreenCaptureParameters2(
          captureAudio: true,
          captureVideo: true,
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(width: 1280, height: 720),
            frameRate: 15,
            bitrate: 1000,
          ),
        ),
      );

      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishCameraTrack: false,
          publishScreenTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      isScreenSharing = true;
    } catch (e) {
      debugPrint('Error starting screen share: $e');
    }
  }

  Future<void> stopScreenShare() async {
    try {
      await engine.stopScreenCapture();
      await engine.muteLocalVideoStream(false);
      await engine.startPreview();

      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishCameraTrack: true,
          publishScreenTrack: false,
          publishMicrophoneTrack: true,
        ),
      );

      isScreenSharing = false;
    } catch (e) {
      debugPrint('Error stopping screen share: $e');
    }
  }

  void _startCallTimer() {
    callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration = Duration(seconds: timer.tick);
    });
  }

  Future<void> toggleMute() async {
    await engine.muteLocalAudioStream(!isMuted);
    isMuted = !isMuted;
    HapticFeedback.selectionClick();
  }

  Future<void> toggleCamera() async {
    await engine.muteLocalVideoStream(!isCameraOff);
    isCameraOff = !isCameraOff;
    HapticFeedback.selectionClick();
  }

  Future<void> toggleSpeaker() async {
    try {
      await engine.setEnableSpeakerphone(!isSpeakerOn);
      isSpeakerOn = !isSpeakerOn;
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error toggling speaker: $e');
    }
  }

  Future<void> endCallCompletely(int meetingId) async {
    HapticFeedback.heavyImpact();
    callTimer?.cancel();
    await engine.leaveChannel();
    await engine.release();
    Get.back();
  }
}

class CallManagerProvider extends InheritedWidget {
  final CallManager callManager;

  const CallManagerProvider({
    super.key,
    required this.callManager,
    required super.child,
  });

  static CallManagerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CallManagerProvider>();
  }

  @override
  bool updateShouldNotify(CallManagerProvider oldWidget) {
    return callManager != oldWidget.callManager;
  }
}

class MiniCallOverlay extends StatefulWidget {
  final VoidCallback onMaximize;
  final VoidCallback onEndCall;

  const MiniCallOverlay({
    Key? key,
    required this.onMaximize,
    required this.onEndCall,
  }) : super(key: key);

  @override
  State<MiniCallOverlay> createState() => _MiniCallOverlayState();
}

class _MiniCallOverlayState extends State<MiniCallOverlay> {
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(
          size.width - 170,
          size.height - 250,
        );
      });
    });
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final callManager = CallManagerProvider.of(context)?.callManager;
    if (callManager == null) return Container();

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position = Offset(
                _position.dx + details.delta.dx,
                _position.dy + details.delta.dy,
              );
            });
          }
        },
        onPanEnd: (details) {
          _isDragging = false;
          _snapToEdge();
        },
        onTap: () {
          // Single tap shows/hides controls
          _toggleControls();
        },
        onDoubleTap: () {
          // Double tap maximizes the call
          widget.onMaximize();
        },
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 150,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  // Video feed
                  if (callManager.remoteUid != null)
                    AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: callManager.engine,
                        canvas: VideoCanvas(uid: callManager.remoteUid),
                        connection: RtcConnection(channelId: callManager.channel),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white70, size: 40),
                      ),
                    ),

                  // Call duration badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDuration(callManager.callDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Mute/Camera off indicators
                  if (callManager.isMuted || callManager.isCameraOff)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (callManager.isMuted)
                            Container(
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.mic_off, color: Colors.white, size: 12),
                            ),
                          if (callManager.isCameraOff)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.videocam_off, color: Colors.white, size: 12),
                            ),
                        ],
                      ),
                    ),

                  // Maximize hint
                  Positioned(
                    top: 36,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onMaximize,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.open_in_full, color: Colors.white, size: 12),
                      ),
                    ),
                  ),

                  // Bottom controls (shown conditionally)
                  if (_showControls)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMiniButton(
                              icon: callManager.isMuted ? Icons.mic_off : Icons.mic,
                              onPressed: () {
                                callManager.toggleMute();
                                setState(() {});
                              },
                              backgroundColor: callManager.isMuted ? Colors.red : null,
                            ),
                            _buildMiniButton(
                              icon: callManager.isCameraOff ? Icons.videocam_off : Icons.videocam,
                              onPressed: () {
                                callManager.toggleCamera();
                                setState(() {});
                              },
                              backgroundColor: callManager.isCameraOff ? Colors.red : null,
                            ),
                            _buildMiniButton(
                              icon: Icons.call_end,
                              onPressed: widget.onEndCall,
                              backgroundColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Tap to expand hint (when controls are hidden)
                  if (!_showControls)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Double tap to expand',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _snapToEdge() {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;

    setState(() {
      if (_position.dx < centerX) {
        _position = Offset(16, _position.dy);
      } else {
        _position = Offset(screenSize.width - 166, _position.dy);
      }

      _position = Offset(
        _position.dx,
        _position.dy.clamp(50.0, screenSize.height - 250),
      );
    });
  }

  Widget _buildMiniButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.white.withOpacity(0.3),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class AgoraCallResumeScreen extends StatefulWidget {
  final RtcEngine engine;
  final int meetingId;

  const AgoraCallResumeScreen({
    Key? key,
    required this.engine,
    required this.meetingId,
  }) : super(key: key);

  @override
  State<AgoraCallResumeScreen> createState() => _AgoraCallResumeScreenState();
}

class _AgoraCallResumeScreenState extends State<AgoraCallResumeScreen> {
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
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

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callManager = CallManagerProvider.of(context)?.callManager;
    if (callManager == null) {
      return const Scaffold(
        body: Center(child: Text('Call not found')),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              // Main video area
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: callManager.remoteUid != null
                    ? AgoraVideoView(
                        controller: VideoViewController.remote(
                          rtcEngine: callManager.engine,
                          canvas: VideoCanvas(uid: callManager.remoteUid),
                          connection: RtcConnection(channelId: callManager.channel),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.deepPurple.shade900, Colors.black],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                          ),
                        ),
                      ),
              ),

              // Top bar with duration and close button
              AnimatedOpacity(
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
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(callManager.callDuration),
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
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Local video preview
              if (_showControls)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 100,
                  right: 16,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
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
                      child: !callManager.isCameraOff
                          ? AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: callManager.engine,
                                canvas: const VideoCanvas(uid: 0),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade900,
                              child: const Center(
                                child: Icon(Icons.videocam_off, color: Colors.white70, size: 32),
                              ),
                            ),
                    ),
                  ),
                ),

              // Bottom controls
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: _showControls ? MediaQuery.of(context).padding.bottom + 32 : -200,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                        icon: callManager.isMuted ? Icons.mic_off : Icons.mic,
                        onPressed: () {
                          callManager.toggleMute();
                          setState(() {});
                        },
                        isActive: !callManager.isMuted,
                        backgroundColor: callManager.isMuted ? Colors.red : null,
                      ),
                      _buildControlButton(
                        icon: callManager.isCameraOff ? Icons.videocam_off : Icons.videocam,
                        onPressed: () {
                          callManager.toggleCamera();
                          setState(() {});
                        },
                        isActive: !callManager.isCameraOff,
                        backgroundColor: callManager.isCameraOff ? Colors.red : null,
                      ),
                      _buildControlButton(
                        icon: callManager.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                        onPressed: () {
                          callManager.toggleSpeaker();
                          setState(() {});
                        },
                        isActive: callManager.isSpeakerOn,
                      ),
                      _buildControlButton(
                        icon: Icons.call_end,
                        onPressed: () => callManager.endCallCompletely(widget.meetingId),
                        isActive: false,
                        backgroundColor: Colors.red,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
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
            color: backgroundColor ??
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }
}