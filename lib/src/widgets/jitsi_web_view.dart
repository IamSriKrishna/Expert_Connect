// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:logger/logger.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:async';

// class JitsiInAppWebView extends StatefulWidget {
//   final String meetingUrl;

//   const JitsiInAppWebView({super.key, required this.meetingUrl});

//   String get modifiedUrl {
//     Uri uri = Uri.parse(meetingUrl);
//     String modified = uri.toString();
    
//     if (!modified.contains('?')) {
//       modified += '?';
//     } else {
//       modified += '&';
//     }
    
//     // Enhanced configuration to bypass moderator waiting
//     modified += 'config.prejoinPageEnabled=false'
//                '&config.startWithAudioMuted=true'
//                '&config.startWithVideoMuted=true'
//                '&config.requireDisplayName=false'
//                '&config.enableWelcomePage=false'
//                '&config.enableClosePage=false'
//                '&config.lobbyEnabled=false'
//                '&config.autoJoin=true'
//                '&config.startScreenSharing=false'
//                '&config.disableModeratorIndicator=true'
//                '&config.enableUserRolesBasedOnToken=false'
//                '&interfaceConfig.SHOW_PROMOTIONAL_CLOSE_PAGE=false'
//                '&interfaceConfig.SHOW_JITSI_WATERMARK=false'
//                '&interfaceConfig.SHOW_WATERMARK_FOR_GUESTS=false'
//                '&appData.lobbyBypassed=true'
//                '&userInfo.displayName=User${DateTime.now().millisecondsSinceEpoch % 1000}';
    
//     return modified;
//   }

//   @override
//   State<JitsiInAppWebView> createState() => _JitsiInAppWebViewState();
// }

// class _JitsiInAppWebViewState extends State<JitsiInAppWebView> 
//     with TickerProviderStateMixin, WidgetsBindingObserver {
  
//   InAppWebViewController? _webViewController;
//   bool _isLoading = true;
//   bool _permissionsGranted = false;
//   bool _browserOpened = false;
//   bool _isDisposed = false; 
//   bool _hasNavigatedBack = false; // Add this flag to prevent multiple navigations
  
//   Timer? _meetingTimer;
//   Timer? _countdownTimer;
//   Timer? _loadingTimer;
//   Timer? _autoJoinTimer;
//   Duration _remainingTime = const Duration(hours: 1);
//   bool _meetingStarted = false;
  
//   AnimationController? _blinkController;
//   Animation<double>? _blinkAnimation;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _requestPermissions();
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     WidgetsBinding.instance.removeObserver(this);
//     _cleanupResources();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
//       _cleanupResources();
//     }
//   }

//   void _cleanupResources() {
//     _meetingTimer?.cancel();
//     _meetingTimer = null;
    
//     _countdownTimer?.cancel();
//     _countdownTimer = null;
    
//     _loadingTimer?.cancel();
//     _loadingTimer = null;
    
//     _autoJoinTimer?.cancel();
//     _autoJoinTimer = null;
    
//     if (_blinkController != null) {
//       _blinkController!.dispose();
//       _blinkController = null;
//       _blinkAnimation = null;
//     }
//   }

//   void _safeSetState(VoidCallback callback) {
//     if (!_isDisposed && mounted) {
//       setState(callback);
//     }
//   }

//   Future<void> _requestPermissions() async {
//     if (_isDisposed) return;
    
//     try {
//       final statuses = await [
//         Permission.camera,
//         Permission.microphone,
//       ].request();

//       _safeSetState(() {
//         _permissionsGranted = statuses[Permission.camera]!.isGranted &&
//             statuses[Permission.microphone]!.isGranted;
//       });
//     } catch (e) {
//       Logger().i('Error requesting permissions: $e');
//       _safeSetState(() {
//         _permissionsGranted = false;
//       });
//     }
//   }

//   void _startMeetingTimer() {
//     if (_meetingStarted || _isDisposed) return;
    
//     _meetingStarted = true;
    
//     // Timer for 1 hour (3600 seconds) - Change this to 240 seconds for testing
//     _meetingTimer = Timer(const Duration(seconds: 3600), () {
//       if (!_isDisposed && !_hasNavigatedBack) {
//         _exitMeeting();
//       }
//     });

//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_isDisposed) {
//         timer.cancel();
//         return;
//       }
      
//       _safeSetState(() {
//         _remainingTime = _remainingTime - const Duration(seconds: 1);
//         if (_remainingTime.inSeconds <= 0) {
//           timer.cancel();
//           if (!_hasNavigatedBack) {
//             _exitMeeting();
//           }
//         }
//       });
//     });
//   }

//   void _handleBrowserOpened() {
//     if (_isDisposed) return;
    
//     _safeSetState(() {
//       _browserOpened = true;
//       _isLoading = false;
//     });
    
//     _loadingTimer?.cancel();
//     _loadingTimer = null;
//   }

//   // New method to handle auto-joining
//   void _attemptAutoJoin() {
//     if (_isDisposed || _webViewController == null) return;
    
//     _webViewController!.evaluateJavascript(source: '''
//       // Function to automatically join the meeting
//       function autoJoinMeeting() {
//         console.log('Attempting to auto-join meeting...');
        
//         // Look for "Join meeting" button
//         const joinButton = document.querySelector('button[data-testid="prejoin.joinMeeting"]') ||
//                           document.querySelector('button[aria-label*="Join"]') ||
//                           document.querySelector('button:contains("Join")') ||
//                           document.querySelector('.join-meeting-button') ||
//                           document.querySelector('[data-testid="lobby.joinMeetingButton"]');
        
//         if (joinButton && joinButton.style.display !== 'none') {
//           console.log('Found join button, clicking...');
//           joinButton.click();
//           return true;
//         }
        
//         // Look for "Start meeting" button (if user is moderator)
//         const startButton = document.querySelector('button[data-testid="lobby.startMeetingButton"]') ||
//                            document.querySelector('button[aria-label*="Start"]') ||
//                            document.querySelector('button:contains("Start")');
        
//         if (startButton && startButton.style.display !== 'none') {
//           console.log('Found start button, clicking...');
//           startButton.click();
//           return true;
//         }
        
//         // Look for "Enter meeting" button in lobby
//         const enterButton = document.querySelector('button[data-testid="lobby.enterMeetingButton"]') ||
//                            document.querySelector('button:contains("Enter")');
        
//         if (enterButton && enterButton.style.display !== 'none') {
//           console.log('Found enter button, clicking...');
//           enterButton.click();
//           return true;
//         }
        
//         return false;
//       }
      
//       // Try to join immediately
//       if (autoJoinMeeting()) {
//         console.log('Auto-join successful');
//       } else {
//         console.log('Auto-join failed, will retry...');
//       }
//     ''');
//   }

//   void _exitMeeting() {
//     if (_isDisposed || !mounted || _hasNavigatedBack) return;
    
//     _hasNavigatedBack = true; // Set flag to prevent multiple calls
//     _cleanupResources();
    
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(50),
//                 ),
//                 child: const Icon(
//                   Icons.access_time_rounded,
//                   color: Colors.white,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Meeting Time Ended',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF333333),
//                 ),
//               ),
//             ],
//           ),
//           content: const Text(
//             'Your 1-hour meeting session has completed. Thank you for joining!',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               color: Color(0xFF666666),
//               height: 1.4,
//             ),
//           ),
//           actions: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF667eea),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close dialog
//                   Navigator.of(context).pop(); // Go back to AppointmentScreen
//                 },
//                 child: const Text(
//                   'Exit Meeting',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Add this method to handle automatic navigation back without dialog
//   void _autoNavigateBack() {
//     if (_isDisposed || !mounted || _hasNavigatedBack) return;
    
//     _hasNavigatedBack = true;
//     _cleanupResources();
    
//     // Navigate back automatically without showing dialog
//     if (Navigator.canPop(context)) {
//       Navigator.of(context).pop();
//     }
//   }

//   Widget _buildLoadingScreen() {
//     return Container(
//       color: Colors.white,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               margin: const EdgeInsets.only(bottom: 24),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(40),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF667eea).withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.video_call_rounded,
//                 color: Colors.white,
//                 size: 40,
//               ),
//             ),
            
//             const SizedBox(
//               width: 40,
//               height: 40,
//               child: CircularProgressIndicator(
//                 strokeWidth: 3,
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             const Text(
//               'Joining meeting automatically...',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF333333),
//               ),
//             ),
            
//             const SizedBox(height: 8),
            
//             const Text(
//               'Please wait while we set up everything',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF666666),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_permissionsGranted) {
//       return _PermissionRequestScreen(
//         onRetry: _requestPermissions,
//       );
//     }

//     return WillPopScope(
//       onWillPop: () async {
//         _hasNavigatedBack = true;
//         _cleanupResources();
//         return true;
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             InAppWebView(
//               initialUrlRequest: URLRequest(url: WebUri(widget.modifiedUrl)),
//               onWebViewCreated: (controller) {
//                 if (!_isDisposed) {
//                   _webViewController = controller;
//                 }
//               },
//               onLoadStart: (_, __) {
//                 if (_isDisposed) return;
                
//                 _safeSetState(() {
//                   _isLoading = true;
//                   _browserOpened = false;
//                 });
                
//                 _loadingTimer?.cancel();
//                 _loadingTimer = Timer(const Duration(seconds: 15), () {
//                   if (_isDisposed) return;
                  
//                   if (_isLoading && !_browserOpened) {
//                     _safeSetState(() {
//                       _isLoading = false;
//                       _browserOpened = true;
//                     });
//                   }
//                 });
//               },
//               onLoadStop: (_, __) async {
//                 if (_isDisposed || _webViewController == null) return;
                
//                 try {
//                   await _webViewController!.evaluateJavascript(source: '''
//                     // Enhanced auto-join script
//                     function findAndClickJoinButton() {
//                       // Find ALL links with the shared wrapper class
//                       const allLinks = document.querySelectorAll('a.css-9ebmqw-linkWrapper');
                      
//                       // Identify the correct "Join in browser" link by its text content
//                       let joinInBrowserLink = null;
//                       allLinks.forEach(link => {
//                         if (link.textContent.includes('Join in browser')) {
//                           joinInBrowserLink = link;
//                         }
//                       });
                      
//                       if (joinInBrowserLink) {
//                         // Create a synthetic click event
//                         const clickEvent = new MouseEvent('click', {
//                           bubbles: true,
//                           cancelable: true,
//                           view: window
//                         });
                        
//                         setTimeout(() => {
//                           joinInBrowserLink.dispatchEvent(clickEvent);
//                         }, 800);
//                       }
                      
//                       // Remove the App Store download link completely
//                       const appStoreLinks = document.querySelectorAll('a[href*="itunes.apple.com"]');
//                       appStoreLinks.forEach(link => link.remove());
//                     }
                    
//                     // Auto-join function for lobby/waiting screen
//                     function autoJoinFromLobby() {
//                       setTimeout(() => {
//                         // Look for various join buttons
//                         const joinButtons = [
//                           'button[data-testid="prejoin.joinMeeting"]',
//                           'button[data-testid="lobby.joinMeetingButton"]',
//                           'button[data-testid="lobby.startMeetingButton"]',
//                           'button[aria-label*="Join"]',
//                           'button[aria-label*="Start"]',
//                           'button:contains("Join meeting")',
//                           'button:contains("Start meeting")',
//                           '.join-meeting-button',
//                           '.start-meeting-button'
//                         ];
                        
//                         for (const selector of joinButtons) {
//                           const button = document.querySelector(selector);
//                           if (button && button.style.display !== 'none' && !button.disabled) {
//                             console.log('Auto-clicking join button:', selector);
//                             button.click();
//                             return true;
//                           }
//                         }
                        
//                         // If no button found, try again in 2 seconds
//                         setTimeout(autoJoinFromLobby, 2000);
//                       }, 1000);
//                     }
                    
//                     // Listen for meeting end events
//                     function listenForMeetingEnd() {
//                       // Listen for conference left events
//                       if (window.JitsiMeetJS) {
//                         window.JitsiMeetJS.events.conference.CONFERENCE_LEFT = 'conference.left';
//                         window.addEventListener('beforeunload', function() {
//                           window.flutter_inappwebview.callHandler('onMeetingLeft');
//                         });
//                       }
                      
//                       // Listen for page visibility changes (when user leaves)
//                       document.addEventListener('visibilitychange', function() {
//                         if (document.hidden) {
//                           setTimeout(() => {
//                             if (document.hidden) {
//                               window.flutter_inappwebview.callHandler('onMeetingLeft');
//                             }
//                           }, 5000);
//                         }
//                       });
//                     }
                    
//                     // Execute functions
//                     findAndClickJoinButton();
//                     autoJoinFromLobby();
//                     listenForMeetingEnd();
//                   ''');
                  
//                   // Set up auto-join timer
//                   _autoJoinTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//                     if (_isDisposed) {
//                       timer.cancel();
//                       return;
//                     }
//                     _attemptAutoJoin();
//                   });
                  
//                   Timer(const Duration(seconds: 5), () {
//                     if (!_isDisposed && !_browserOpened) {
//                       _handleBrowserOpened();
//                       _startMeetingTimer();
//                     }
//                   });
//                 } catch (e) {
//                   Logger().i('Error injecting JavaScript: $e');
//                   Timer(const Duration(seconds: 2), () {
//                     if (!_isDisposed && !_browserOpened) {
//                       _handleBrowserOpened();
//                       _startMeetingTimer();
//                     }
//                   });
//                 }
//               },
//               onConsoleMessage: (controller, consoleMessage) {
//                 if (_isDisposed) return;
                
//                 final message = consoleMessage.message.toLowerCase();
//                 if (message.contains('conference') || 
//                     message.contains('joined') ||
//                     message.contains('meeting') ||
//                     message.contains('auto-join') ||
//                     message.contains('lobby')) {
//                   if (!_browserOpened) {
//                     _handleBrowserOpened();
//                     _startMeetingTimer();
//                   }
//                 }
//               },
//               shouldOverrideUrlLoading: (controller, navigationAction) async {
//                 if (_isDisposed) return NavigationActionPolicy.CANCEL;
                
//                 final url = navigationAction.request.url?.toString() ?? '';
//                 if (url.contains('itunes.apple.com')) {
//                   return NavigationActionPolicy.CANCEL;
//                 }
                
//                 if (!_browserOpened && url.contains('meet.jit.si')) {
//                   _handleBrowserOpened();
//                   _startMeetingTimer();
//                 }
                
//                 return NavigationActionPolicy.ALLOW;
//               },
//               initialOptions: InAppWebViewGroupOptions(
//                 crossPlatform: InAppWebViewOptions(
//                   mediaPlaybackRequiresUserGesture: false,
//                   javaScriptEnabled: true,
//                   preferredContentMode: UserPreferredContentMode.MOBILE,
//                 ),
//                 android: AndroidInAppWebViewOptions(
//                   useHybridComposition: true,
//                   allowContentAccess: true,
//                   allowFileAccess: true,
//                   useWideViewPort: true,
//                   loadWithOverviewMode: true,
//                   supportMultipleWindows: false,
//                 ),
//                 ios: IOSInAppWebViewOptions(
//                   allowsInlineMediaPlayback: true,
//                   allowsBackForwardNavigationGestures: false,
//                 ),
//               ),
//               onJsAlert: (controller, jsAlertRequest) async {
//                 // Handle JavaScript alerts (meeting ended, etc.)
//                 if (jsAlertRequest.message!.toLowerCase().contains('meeting') ||
//                     jsAlertRequest.message!.toLowerCase().contains('ended') ||
//                     jsAlertRequest.message!.toLowerCase().contains('left')) {
//                   _autoNavigateBack();
//                 }
//                 return JsAlertResponse(handledByClient: false);
//               },
//             ),
            
//             if ((_isLoading || !_browserOpened) && !_isDisposed)
//               _buildLoadingScreen(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _PermissionRequestScreen extends StatelessWidget {
//   final VoidCallback onRetry;

//   const _PermissionRequestScreen({required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 margin: const EdgeInsets.only(bottom: 24),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(40),
//                 ),
//                 child: const Icon(
//                   Icons.videocam_off,
//                   size: 40,
//                   color: Colors.grey,
//                 ),
//               ),
//               const Text(
//                 'Camera & Microphone Access Required',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF333333),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'To join the video meeting, please grant access to your camera and microphone.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF666666),
//                   height: 1.4,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF667eea),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   onPressed: onRetry,
//                   child: const Text(
//                     'Grant Permissions',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: () => openAppSettings(),
//                 child: const Text(
//                   'Open Settings',
//                   style: TextStyle(
//                     color: Color(0xFF667eea),
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }