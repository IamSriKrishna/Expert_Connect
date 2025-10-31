// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/app_image_path.dart';
import 'package:expert_connect/src/appointment/appointment_screen.dart';
import 'package:expert_connect/src/article/article_screen.dart';
import 'package:expert_connect/src/chat/chat_screen.dart';
import 'package:expert_connect/src/home/home_screen.dart';
import 'package:expert_connect/src/settings/settings_screen.dart';
import 'package:flutter/material.dart';

class BottomWidgets {
  
  static Future<bool?> showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.exit_to_app_rounded,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Exit Application',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  'Are you sure you want to exit the app?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Exit button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.exit_to_app_rounded,
                              size: 18,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Exit App',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  static Widget bottomNavigator(int currentIndex, {void Function(int)? onTap}) {
    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
      currentIndex: currentIndex,
      selectedItemColor: AppColor.splashColor,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      onTap: onTap,
      items: _bottomItem(),
    );
  }

  static List<BottomNavigationBarItem> _bottomItem() {
    return [
      BottomNavigationBarItem(
        activeIcon: Image.asset(
          AppImagePath.home,
          color: AppColor.splashColor.withOpacity(0.5),
        ),
        icon: Image.asset(AppImagePath.home, color: Colors.grey),
        label: "Home",
      ),
      BottomNavigationBarItem(
        activeIcon: Image.asset(
          AppImagePath.chats,
          color: AppColor.splashColor,
        ),
        icon: Image.asset(AppImagePath.chats),
        label: "Chats",
      ),
      BottomNavigationBarItem(
        activeIcon: Image.asset(
          AppImagePath.booking,
          color: AppColor.splashColor,
        ),
        icon: Image.asset(AppImagePath.booking),
        label: "Bookings",
      ),
      // BottomNavigationBarItem(
      //   activeIcon: Image.asset(AppImagePath.help, color: AppColor.splashColor),
      //   icon: Image.asset(AppImagePath.help),
      //   label: "Help",
      // ),
      BottomNavigationBarItem(
        activeIcon: Icon(Icons.article, color: AppColor.splashColor.withOpacity(0.4)),
        icon: Icon(Icons.article,color: Colors.grey,),
        label: "Article",
      ),
      BottomNavigationBarItem(
        activeIcon: Image.asset(
          AppImagePath.profile,
          color: AppColor.splashColor,
        ),
        icon: Image.asset(AppImagePath.profile),
        label: "Profile",
      ),
    ];
  }

  static Widget body(int index){
    return [
      HomeScreen(),
      ChatScreen(),
      AppointmentScreen(),
      // HelpScreen(),
      ArticleScreen(),
      SettingsScreen(),
    ][index];
  }
}
