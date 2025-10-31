import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/app_key.dart';
import 'package:expert_connect/src/app/app_image_path.dart';
import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/widgets/common_builder/password_builder.dart';
import 'package:expert_connect/src/widgets/common_builder/text_field_builder.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginWidgets {
  static Widget logo() {
    return Hero(
      tag: AppKey.splash,
      child: Container(
        height: 190.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.splashColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8.sp),
            bottomRight: Radius.circular(8.sp),
          ),
        ),
        child: Center(
          child: Image.asset(
            AppImagePath.splash,
            fit: BoxFit.cover,
            width: 280.w,
          ),
        ),
      ),
    );
  }

  static Widget welcomeText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 15.h),
      child: CommonWidgets.text(
        text: "Welcome!\nSign in your account",
        fontSize: 26.sp,
        color: AppColor.splashColor,
        fontFamily: TextFamily.interRegular,
        fontWeight: TextWeight.semi,
      ),
    );
  }

  static Widget fields() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: Column(
        children: [
          TextFieldBuilder(name: "Email Address"),
          SizedBox(height: 10),
          PasswordFieldBuilder(name: "Password"),
        ],
      ),
    );
  }

  static Widget forgetPassword() {
    return Padding(
      padding: EdgeInsets.only(
        left: 15.0.w,
        right: 20.w,
        top: 5.h,
        bottom: 5.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BlocProvider(
                create: (context) => SignedInCubit(),
                child: BlocBuilder<SignedInCubit, bool>(
                  builder: (context, state) {
                    return Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: state,
                      onChanged: (value) =>
                          context.read<SignedInCubit>().toggle(value!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(5.sp),
                      ),
                    );
                  },
                ),
              ),
              CommonWidgets.text(text: "Keep in signed in", fontSize: 12.sp),
            ],
          ),
          InkWell(
            onTap: () {
              Get.toNamed(RoutesName.forgetPasswordScreen);
            },
            child: CommonWidgets.text(
              text: "Forget Password?",
              fontSize: 12.sp,
              color: AppColor.splashColor,
              fontFamily: TextFamily.interRegular,
              fontWeight: TextWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget toSignUp() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonWidgets.text(
            text: "Don't have an account?",
            color: Colors.grey,
            fontFamily: TextFamily.manrope,
            fontWeight: TextWeight.bold,
            fontSize: 12.sp,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: GestureDetector(
              onTap: () => Get.toNamed(RoutesName.signUp),
              child: CommonWidgets.text(
                text: "Create One",
                color: AppColor.splashColor,
                fontWeight: TextWeight.bold,
                fontFamily: TextFamily.manrope,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
