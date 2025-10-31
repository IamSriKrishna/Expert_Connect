// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/app_key.dart';
import 'package:expert_connect/src/app/app_image_path.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashWidgets {
  static void navigateToHome(BuildContext context) {
    Get.offNamed(RoutesName.login);
  }

  static Widget splashContent() {
    return Hero(
      tag: AppKey.splash,
      child: Container(
        color: AppColor.splashColor,
        child: Center(child: _buildLogo()),
      ),
    );
  }

  static Widget _buildLogo() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          AppImagePath.splash,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
        ),
      ),
    );
  }

  static Widget _buildFallbackLogo() {
    return Container(
      color: Colors.blue,
      child: const Icon(Icons.apps, size: 60, color: Colors.white),
    );
  }
}
