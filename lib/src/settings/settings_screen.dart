// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/settings/bloc/setting_bloc.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  int? expandedIndex;
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  // Custom refresh indicator controller
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
    _animations = _controllers
        .map(
          (controller) =>
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
        )
        .toList();

    // Initialize refresh animation controller
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Start the refresh animation
    _refreshController.repeat();

    try {
      await Future.delayed(Duration(milliseconds: 1700));
      // Perform the actual refresh operations
      await Future.wait([
        Future.delayed(
          const Duration(milliseconds: 500),
        ), // Minimum animation time
        _performRefreshOperations(),
      ]);
    } finally {
      // Stop the refresh animation
      _refreshController.stop();
      _refreshController.reset();
    }
  }

  Future<void> _performRefreshOperations() async {
    final settingBloc = context.read<SettingBloc>();
    final currentUser = settingBloc.state.userProfile;

    try {
      // Get both location and timezone
      final position = await _getCurrentLocation();
      final timezone = await _getCurrentTimezone();

      settingBloc.add(FetchUserProfile());
      settingBloc.add(
        UpdateUserLocation(
          userId: currentUser.id,
          latitude: position.latitude.toString(),
          longitude: position.longitude.toString(),
          timezone: timezone,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Handle location errors gracefully
      debugPrint('Error getting location or timezone: $e');
      settingBloc.add(FetchUserProfile());
    }
  }

  Future<String> _getCurrentTimezone() async {
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      return currentTimeZone; // This will return something like "Asia/Kolkata"
    } catch (e) {
      debugPrint('Error getting timezone: $e');
      // Fallback to a default timezone if detection fails
      return 'Asia/Kolkata';
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  void _toggleExpansion(int index) {
    setState(() {
      if (expandedIndex == index) {
        _controllers[index].reverse();
        expandedIndex = null;
      } else {
        if (expandedIndex != null) {
          _controllers[expandedIndex!].reverse();
        }
        expandedIndex = index;
        _controllers[index].forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, settingState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              body: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xFF3B82F6),
                backgroundColor: Colors.white,
                displacement: 40,
                strokeWidth: 3.0,
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                child: SafeArea(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      CommonWidgets.appBar(text: "Settings"),

                      // Profile Header with Refresh Indicator
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF6366F1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'My Profile',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage your account settings',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Refresh status indicator
                              AnimatedBuilder(
                                animation: _refreshAnimation,
                                builder: (context, child) {
                                  return _refreshAnimation.value > 0
                                      ? Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF3B82F6,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Transform.rotate(
                                            angle:
                                                _refreshAnimation.value *
                                                2 *
                                                math.pi,
                                            child: const Icon(
                                              Icons.sync_rounded,
                                              color: Color(0xFF3B82F6),
                                              size: 16,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Menu Items as Sliver List
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final menuItems = [
                              {
                                'title': 'Personal Info',
                                'icon': Icons.person_outline,
                                'content': _buildPersonalInfoContent(state),
                              },
                              {
                                'title': 'User Wallet',
                                'icon': Icons.calendar_today_outlined,
                                'content': _buildWalletContent(settingState),
                              },
                              // {
                              //   'title': 'Preference',
                              //   'icon': Icons.settings_outlined,
                              //   'content': _buildPreferenceContent(),
                              // },
                              {
                                'title': 'Account',
                                'icon': Icons.account_circle_outlined,
                                'content': _buildAccountContent(),
                              },
                            ];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMenuItem(
                                index,
                                menuItems[index]['title'] as String,
                                menuItems[index]['icon'] as IconData,
                                menuItems[index]['content'] as Widget,
                              ),
                            );
                          }, childCount: 3),
                        ),
                      ),

                      // Pull to refresh instruction
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.swipe_down_rounded,
                                color: const Color(0xFF3B82F6).withOpacity(0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Pull down to refresh and sync your latest data and update your location',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Spacing
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    int index,
    String title,
    IconData icon,
    Widget content,
  ) {
    final isExpanded = expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _toggleExpansion(index),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isExpanded
                            ? Colors.white
                            : const Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF6B7280),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizeTransition(sizeFactor: _animations[index], child: content),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoContent(AuthState state) {
    final AuthStateManager authStateManager = AuthStateManager();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Name',
            authStateManager.userFullName.capitalizeWords(),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Phone Number', authStateManager.userPhone),
          const SizedBox(height: 16),
          _buildInfoRow('Email', authStateManager.userEmail),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.toNamed(RoutesName.profileScreen);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Upload Profile Picture',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletContent(SettingState state) {
    final int totalCredit = state.transaction.summary.totalCredit;
    final int totalDebit = state.transaction.summary.totalDebit;
    final int currentBalance = state.transaction.summary.currentBalance;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Current Balance Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${currentBalance.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Credit and Debit Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Credit',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalCredit.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Debit',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalDebit.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Check Summary Button
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.toNamed(RoutesName.transactionScreen);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Check Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountContent() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    await AuthStateManager().clearAuthData();
                    Get.offAllNamed(RoutesName.login);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
