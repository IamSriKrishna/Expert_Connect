// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/app_image_path.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum TextWeight { bold, semi, regular, medium, thin }

enum TextFamily {
  manropeBold,
  manrope,
  interRegular,
  interMedium,
  interThin,
  interBold,
}

class CommonWidgets {
  static Text text({
    String text = "",
    int? maxLines,
    double? fontSize,
    Color color = Colors.black,
    TextFamily fontFamily = TextFamily.manrope,
    TextWeight fontWeight = TextWeight.regular,
    TextDecoration decoration = TextDecoration.none,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        decoration: decoration,
        fontWeight: _getFontWeight(fontWeight),
        fontFamily: _getFontFamily(fontFamily),
      ),
    );
  }
// Update your CommonWidgets.btn method to this:

static Widget btn({
  required void Function()? onPressed,
  bool isAuth = true,
  String text = "Login",
  bool isEnabled = true, // New parameter for enabling/disabling
  Color? backgroundColor, // Allow custom background color
  Color? textColor, // Allow custom text color
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.0.h),
    child: Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: isAuth ? Size(320.w, 35.h) : Size(190.w, 30.h),
          backgroundColor: !isEnabled 
              ? Colors.grey.shade400 
              : (backgroundColor ?? Theme.of(Get.context!).primaryColor),
          disabledBackgroundColor: Colors.grey.shade400,
          elevation: isEnabled ? 2 : 0,
          shadowColor: isEnabled ? Colors.black26 : Colors.transparent,
        ),
        onPressed: isEnabled ? onPressed : null,
        child: CommonWidgets.text(
          text: StringCasingExtension(text).capitalize(),
          color: !isEnabled 
              ? Colors.grey.shade600 
              : (textColor ?? Colors.white),
          fontFamily: TextFamily.interMedium,
          fontSize: 16.sp,
          fontWeight: TextWeight.regular,
        ),
      ),
    ),
  );
}

  static Widget googleBtn({
    required void Function()? onPressed,
    bool isLoading = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0.h),
      child: Center(
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            fixedSize: Size(
              320.w,
              48.h,
            ), // Slightly taller for better touch target
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          icon: Image.asset(AppImagePath.google, width: 20, height: 20),
          label: CommonWidgets.text(
            text: StringCasingExtension("login with google").capitalize(),
            fontFamily: TextFamily.interMedium,
            fontSize: 16.sp,
            fontWeight: TextWeight.regular,
            color: isLoading ? Colors.grey.shade600 : Colors.black,
          ),
        ),
      ),
    );
  }

  static Widget dividerText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 15.h),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0.w),
            child: CommonWidgets.text(
              text: StringCasingExtension("or With").capitalize(),
              fontSize: 10.sp,
              fontFamily: TextFamily.manrope,
              fontWeight: TextWeight.bold,
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  static Widget appBar({String text = "Expert Connect", int count = 0}) {
    return SliverAppBar(
      expandedHeight: 52.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(),
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w, top: 5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.splashColor,
                  AppColor.splashColor.withOpacity(0.5),
                  AppColor.splashColor,
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'Inter',
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 200.w,
      actions: text == "Expert Connect"
          ? [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(RoutesName.notificationScreen);
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 35.h,
                        width: 35.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.splashColor.withOpacity(0.1),
                          border: Border.all(
                            color: AppColor.splashColor.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.splashColor.withOpacity(0.15),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColor.splashColor,
                              AppColor.splashColor.withOpacity(0.8),
                              AppColor.splashColor,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ),
                      // Notification badge
                      Positioned(
                        right: 5.w,
                        top: 5.h,
                        child: Container(
                          height: 12.h,
                          width: 12.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.shade500,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "$count",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          : null,
    );
  }

  static double calculateAmountWithTax(double price, double tax) {
    final double basePrice = price.toDouble();
    final double taxPercentage = tax.toDouble();
    final double taxAmount = (basePrice * taxPercentage) / 100;
    final double totalWithTax = basePrice + taxAmount;
    return totalWithTax;
  }

  static Widget sliverPadding(double? vertical, {required Widget sliver}) {
    return SliverPadding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: 10.w,
        vertical: vertical ?? 10.h,
      ),
      sliver: sliver,
    );
  }

  static FontWeight _getFontWeight(TextWeight fontFamily) {
    switch (fontFamily) {
      case TextWeight.bold:
        return FontWeight.bold;
      case TextWeight.medium:
        return FontWeight.w500;
      case TextWeight.regular:
        return FontWeight.normal;
      case TextWeight.semi:
        return FontWeight.w600;
      case TextWeight.thin:
        return FontWeight.w100;
    }
  }

  static String _getFontFamily(TextFamily fontFamily) {
    switch (fontFamily) {
      case TextFamily.interBold:
        return 'inter_bold';
      case TextFamily.interMedium:
        return 'inter_medium';
      case TextFamily.interRegular:
        return 'inter_regular';
      case TextFamily.interThin:
        return 'inter_thin';
      case TextFamily.manropeBold:
        return 'manrope_bold';
      case TextFamily.manrope:
        return 'manrope';
    }
  }
}
