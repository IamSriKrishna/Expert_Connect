import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/widgets/common_builder/document_upload_builder.dart';
import 'package:expert_connect/src/widgets/common_builder/text_field_builder.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpWidgets {
  static AuthStateManager authStatemanage = AuthStateManager();

  static Widget welcomeText() {
    return CommonWidgets.sliverPadding(
      20,
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonWidgets.text(
              text: "Hi ${authStatemanage.userFullName.capitalizeWords()}",
              fontSize: 24.sp,
              fontWeight: TextWeight.medium,
            ),
            CommonWidgets.text(
              text: "We're here to solve your issues",
              fontSize: 18.sp,
              fontWeight: TextWeight.regular,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  static Widget fields() {
    return CommonWidgets.sliverPadding(
      0,
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            TextFieldBuilder(
              name: "Full Name",
              initial: authStatemanage.userFullName.capitalizeWords(),
            ),
            SizedBox(height: 15.h),
            TextFieldBuilder(name: "Profession"),
            SizedBox(height: 15.h),
            TextFieldBuilder(
              name: "Please enter your issues",
              minLines: 8,
              isHint: false,
            ),
            SizedBox(height: 15.h),
            DocumentUploadBuilder(name: "Documents"),
          ],
        ),
      ),
    );
  }
}
