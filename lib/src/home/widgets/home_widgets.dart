// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/app_constant.dart';
import 'package:expert_connect/src/app/app_key.dart';
import 'package:expert_connect/src/app/app_image_path.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeWidgets {
  // Update your searchBar method in HomeWidgets class
  static Widget searchBar({
    Function(String)? onSearchChanged,
    TextEditingController? controller,
    int? resultCount,
    bool showResultCount = false,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search experts by name...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 20.sp,
                  ),
                  suffixIcon: controller?.text.isNotEmpty == true
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade500,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            controller?.clear();
                            onSearchChanged?.call("");
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
          ),

          // Show result count when searching
          if (showResultCount && controller?.text.isNotEmpty == true)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  CommonWidgets.text(
                    text: resultCount == 0
                        ? "No results found"
                        : "$resultCount expert${resultCount == 1 ? '' : 's'} found",
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static Widget filters() {
    return CommonWidgets.sliverPadding(
      0,
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _filterItems(index: 0),
            _filterItems(text: "Rating"),
            _filterItems(text: "Location"),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColor.splashColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Image.asset(
                AppImagePath.filter,
                height: 20.h,
                width: 20.w,
                color: AppColor.splashColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget category() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 105.h,
            width: double.infinity,
            child: ListView.builder(
              key: AppKey.categoryKey,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: false,
              itemCount: state.category.length,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              itemBuilder: (context, index) {
                final category = state.category[index];

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(
                        RoutesName.category,
                        arguments: {
                          "id": category.id,
                          "category": category.categoryName,
                        },
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 56.h,
                          width: 56.w,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Image.network(
                            "${AppUrl.imageUrl}/${category.categoryImage}",
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CommonWidgets.text(
                          text: category.categoryName,
                          fontFamily: TextFamily.interRegular,
                          fontSize: 11.sp,
                          fontWeight: TextWeight.medium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Widget featuredProfessional() {
    return CommonWidgets.sliverPadding(
      5.0,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonWidgets.text(
                text: "Featured Professionals",
                fontSize: 18.sp,
                fontWeight: TextWeight.semi,
              ),
              // GestureDetector(
              //   onTap: () {},
              //   child: CommonWidgets.text(
              //     text: "View All",
              //     fontSize: 14.sp,
              //     color: AppColor.splashColor,
              //     fontWeight: TextWeight.medium,
              //     decoration: TextDecoration.underline,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget featuredWidgetsVertical({required List<dynamic> vendors}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final vendor = vendors[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(RoutesName.profile, arguments: {"id": vendor.id});
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: vendor.img == null || vendor.img!.isEmpty
                      ? Border.all(color: Colors.grey.shade200, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.splashColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    splashColor: AppColor.splashColor.withOpacity(0.1),
                    highlightColor: AppColor.splashColor.withOpacity(0.05),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(
                        RoutesName.profile,
                        arguments: {"id": vendor.id},
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Row(
                        children: [
                          // Enhanced Profile Image with Status Indicator
                          Stack(
                            children: [
                              Hero(
                                tag: "vendor_${vendor.id}",
                                child: vendor.img == null || vendor.img!.isEmpty
                                    ? Container(
                                        height: 65.h,
                                        width: 65.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColor.splashColor.withOpacity(
                                                0.1,
                                              ),
                                              AppColor.splashColor.withOpacity(
                                                0.2,
                                              ),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: AppColor.splashColor
                                                .withOpacity(0.2),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColor.splashColor
                                                  .withOpacity(0.15),
                                              blurRadius: 15,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: CommonWidgets.text(
                                            text: vendor.name[0].toUpperCase(),
                                            fontSize: 22,
                                            fontFamily: TextFamily.interBold,
                                            color: AppColor.splashColor,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 60.h,
                                        width: 65.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColor.splashColor
                                                .withOpacity(0.3),
                                            width: 2.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColor.splashColor
                                                  .withOpacity(0.15),
                                              blurRadius: 15,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            32.5.sw,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${AppUrl.imageUrl}/${vendor.img}",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey.shade200,
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColor.splashColor),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  color: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.grey.shade400,
                                                    size: 30.sp,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                              ),
                              // Online Status Indicator
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 16.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 15.w),

                          // Enhanced Content Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name with Verified Badge
                                Row(
                                  children: [
                                    Expanded(
                                      child: CommonWidgets.text(
                                        maxLines: 1,
                                        text: vendor.name,
                                        fontSize: 18.sp,
                                        fontWeight: TextWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            color: Colors.blue.shade600,
                                            size: 12.sp,
                                          ),
                                          SizedBox(width: 2.w),
                                          CommonWidgets.text(
                                            text: "PRO",
                                            fontSize: 10.sp,
                                            fontWeight: TextWeight.bold,
                                            color: Colors.blue.shade600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                // Specialty with Icon
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(4.w),
                                      decoration: BoxDecoration(
                                        color: AppColor.splashColor.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          6.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.favorite,
                                        color: AppColor.splashColor,
                                        size: 12.sp,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    CommonWidgets.text(
                                      text: AppConstant.getSubCategoryNameById(
                                        vendor.subCategoryId,
                                      ),
                                      fontSize: 14.sp,
                                      fontWeight: TextWeight.medium,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10.h),

                                // Enhanced Rating and Stats
                                Row(
                                  children: [
                                    // Rating
                                    vendor.ratingsAvgRating! != "no-ratings"
                                        ? Flexible(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.w,
                                                vertical: 3.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(6.r),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star_rounded,
                                                    color:
                                                        Colors.amber.shade600,
                                                    size: 14.sp,
                                                  ),
                                                  SizedBox(width: 3.w),
                                                  CommonWidgets.text(
                                                    text: vendor
                                                        .ratingsAvgRating
                                                        .toString()
                                                        .substring(0, 3),
                                                    fontSize: 12.sp,
                                                    fontWeight: TextWeight.bold,
                                                    color:
                                                        Colors.amber.shade800,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),

                                    SizedBox(width: 8.w),

                                    // Experience
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.work_outline,
                                            color: Colors.grey.shade500,
                                            size: 12.sp,
                                          ),
                                          SizedBox(width: 3.w),
                                          Flexible(
                                            child: CommonWidgets.text(
                                              text: vendor.exp <= 1
                                                  ? "${vendor.exp.toString()} Year"
                                                  : "${vendor.exp.toString()} Years",
                                              fontSize: 11.sp,
                                              color: Colors.grey.shade600,
                                              maxLines: 1,
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

                          SizedBox(width: 12.w),

                          // // Enhanced Action Button
                          // SizedBox(
                          //   width: 75.w,
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       HapticFeedback.mediumImpact();
                          //       Get.toNamed(
                          //         RoutesName.profile,
                          //         arguments: {"id": vendor.id},
                          //       );
                          //     },
                          //     style:
                          //         ElevatedButton.styleFrom(
                          //           backgroundColor: AppColor.splashColor,
                          //           foregroundColor: Colors.white,
                          //           elevation: 0,
                          //           shadowColor: Colors.transparent,
                          //           shape: RoundedRectangleBorder(
                          //             borderRadius: BorderRadius.circular(12.r),
                          //           ),
                          //           padding: EdgeInsets.symmetric(
                          //             vertical: 10.h,
                          //             horizontal: 6.w,
                          //           ),
                          //         ).copyWith(
                          //           overlayColor: MaterialStateProperty.all(
                          //             Colors.white.withOpacity(0.2),
                          //           ),
                          //         ),
                          //     child: Column(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Icon(
                          //           Icons.visibility_outlined,
                          //           size: 14.sp,
                          //           color: Colors.white,
                          //         ),
                          //         SizedBox(height: 1.h),
                          //         Text(
                          //           "View",
                          //           style: TextStyle(
                          //             fontSize: 10.sp,
                          //             fontWeight: FontWeight.w700,
                          //             letterSpacing: 0.3,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }, childCount: vendors.length),
    );
  }

  static Widget featuredWidgets({required HomeState state}) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 170.h,
        child: ListView.builder(
          key: AppKey.featuredKey,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10),
          itemCount: state.featuredVendors.length,
          itemBuilder: (context, index) {
            final vendor = state.featuredVendors[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Container(
                width: 220.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: vendor.img == null || vendor.img!.isEmpty
                      ? Border.all(color: Colors.grey.shade200)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          vendor.img == null || vendor.img!.isEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(32.sw),
                                  child: Container(
                                    height: 60.h,
                                    width: 60.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Center(
                                      child: CommonWidgets.text(
                                        text: vendor.name[0].capitalizeWords(),
                                        fontSize: 18,
                                        fontFamily: TextFamily.interBold,
                                      ),
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(32.sw),
                                  child: Container(
                                    height: 60.h,
                                    width: 60.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blueGrey,
                                      ),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          "${AppUrl.imageUrl}/${vendor.img}",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonWidgets.text(
                                  maxLines: 1,
                                  text: vendor.name,
                                  fontSize: 15.sp,
                                  fontWeight: TextWeight.semi,
                                ),
                                SizedBox(height: 4.h),
                                CommonWidgets.text(
                                  text: AppConstant.getSubCategoryNameById(
                                    vendor.subCategoryId,
                                  ),
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(height: 6.h),
                                vendor.ratingsAvgRating! != "no-ratings"
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 4.w),
                                          CommonWidgets.text(
                                            text: vendor.ratingsAvgRating
                                                .toString()
                                                .substring(0, 3),
                                            fontSize: 12.sp,
                                            fontWeight: TextWeight.medium,
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(
                              RoutesName.profile,
                              arguments: {"id": vendor.id},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.splashColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppColor.splashColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 14.h,
                              horizontal: 24.w,
                            ),
                          ),
                          child: Text(
                            "View Profile",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget getExpertAdviceCard({required HomeState homeState}) {
    return CommonWidgets.sliverPadding(
      null,
      sliver: SliverToBoxAdapter(
        child: InkWell(
          onTap: () {
            Get.toNamed(
              RoutesName.profile,
              arguments: {"id": homeState.bannerDetails.bannerDetails.vendorId},
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(10.r),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl:
                  "${AppUrl.imageUrl}/${homeState.bannerDetails.bannerDetails.banner}",
            ),
          ),
        ),
      ),
    );
  }

  static Widget _filterItems({
    String text = "All Professionals",
    int index = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: index == 0 ? AppColor.splashColor : Colors.grey.shade400,
          width: index == 0 ? 2 : 1,
        ),
        color: index == 0
            ? AppColor.splashColor.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
          child: CommonWidgets.text(
            text: text,
            fontSize: 12.sp,
            fontWeight: index == 0 ? TextWeight.bold : TextWeight.medium,
            color: index == 0 ? AppColor.splashColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  static Widget buildTabController(BuildContext context, {required int state}) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<HomeTabControllerCubit>().changeTab(0);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: state == 0
                        ? AppColor.splashColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "Most Popular",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: state == 0 ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<HomeTabControllerCubit>().changeTab(1);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: state == 1
                        ? AppColor.splashColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "Top Rated",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: state == 1 ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildTabContent({
    required int state,
    required HomeState homeState,
  }) {
    final currentData = state == 0
        ? homeState.mostPopularVendors
        : homeState.topRatedVendors;

    final tagText = state == 0 ? "Most Popular" : "Top Rated";
    final tagColor = state == 0
        ? const Color(0xFF2196F3)
        : const Color(0xFF4CAF50);
    final tagIcon = state == 0 ? Icons.trending_up : Icons.star_rate;

    // Check if data is empty
    if (currentData.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(
          tagText: tagText,
          tagColor: tagColor,
          tagIcon: tagIcon,
          state: state,
        ),
      );
    }

    return SliverList.builder(
      itemCount: currentData.length,
      itemBuilder: (context, index) {
        final professional = currentData[index];

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: GestureDetector(
            onTap: () {
              Get.toNamed(
                RoutesName.profile,
                arguments: {"id": professional.id},
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Colors.grey.shade100.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: tagColor.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            tagColor.withOpacity(0.05),
                            tagColor.withOpacity(0.01),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main Content
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Professional Avatar with Glow Effect
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        tagColor.withOpacity(0.1),
                                        tagColor.withOpacity(0.05),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: tagColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(3.w),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        50.sw,
                                      ),
                                      child: CachedNetworkImage(
                                        height: 59.h,
                                        width: 64.w,
                                        imageUrl:
                                            "${AppUrl.imageUrl}/${professional.img}",
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade100,
                                                    Colors.grey.shade50,
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person_outline,
                                                color: Colors.grey.shade400,
                                                size: 28,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.grey.shade100,
                                                    Colors.grey.shade50,
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person_outline,
                                                color: Colors.grey.shade400,
                                                size: 28,
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Animated Online Status
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 18.w,
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4CAF50),
                                          Color(0xFF66BB6A),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16.w),

                            // Professional Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name with Verification
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CommonWidgets.text(
                                          maxLines: 1,
                                          text: professional.name,
                                          fontSize: 18.sp,
                                          fontWeight: TextWeight.semi,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(6.w),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF2196F3),
                                              const Color(0xFF42A5F5),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF2196F3,
                                              ).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),

                                  // Profession with Icon
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        color: const Color(0xFF6B7280),
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: CommonWidgets.text(
                                          text:
                                              AppConstant.getSubCategoryNameById(
                                                professional.subCategoryId,
                                              ),
                                          fontSize: 13.sp,
                                          color: const Color(0xFF6B7280),
                                          fontWeight: TextWeight.medium,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Bottom Section with Tags and Button
                        Row(
                          children: [
                            // Rating Badge
                            professional.ratingsAvgRating! != "no-ratings"
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFFF8E1),
                                          const Color(0xFFFFF3C4),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFFE082,
                                        ).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: const Color(0xFFFF9800),
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        CommonWidgets.text(
                                          text: professional.ratingsAvgRating!
                                              .substring(0, 3),
                                          fontSize: 12.sp,
                                          fontWeight: TextWeight.semi,
                                          color: const Color(0xFFFF9800),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink(),
                            SizedBox(width: 8.w),

                            // Category Tag
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tagColor.withOpacity(0.1),
                                    tagColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: tagColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(tagIcon, color: tagColor, size: 12.sp),
                                  SizedBox(width: 4.w),
                                  CommonWidgets.text(
                                    text: tagText,
                                    fontSize: 10.sp,
                                    color: tagColor,
                                    fontWeight: TextWeight.semi,
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Action Button
                            tabContentBtn(
                              text: "View Profile",
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Get.toNamed(
                                  RoutesName.profile,
                                  arguments: {"id": professional.id},
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Empty State Widget
  static Widget _buildEmptyState({
    required String tagText,
    required Color tagColor,
    required IconData tagIcon,
    required int state,
  }) {
    final emptyTitle = state == 0
        ? "No Popular Vendors Yet"
        : "No Rated Vendors Yet";
    final emptySubtitle = state == 0
        ? "Be the first to discover amazing vendors in your area"
        : "No vendors have been rated yet. Check back soon!";

    return Padding(
      padding: EdgeInsets.only(left: 20.w,right: 20.w, bottom: 10.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50.withOpacity(0.3)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: Colors.grey.shade100.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: tagColor.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      tagColor.withOpacity(0.05),
                      tagColor.withOpacity(0.01),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: EdgeInsets.all(40.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Empty State Icon
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          tagColor.withOpacity(0.1),
                          tagColor.withOpacity(0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: tagColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      tagIcon,
                      size: 48.sp,
                      color: tagColor.withOpacity(0.7),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Empty Title
                  CommonWidgets.text(
                    text: emptyTitle,
                    fontSize: 20.sp,
                    fontWeight: TextWeight.semi,
                    color: const Color(0xFF1A1A1A),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8.h),

                  // Empty Subtitle
                  CommonWidgets.text(
                    text: emptySubtitle,
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: TextWeight.medium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),

                  SizedBox(height: 24.h),

                  // Category Tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tagColor.withOpacity(0.1),
                          tagColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: tagColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tagIcon, color: tagColor, size: 14.sp),
                        SizedBox(width: 6.w),
                        CommonWidgets.text(
                          text: tagText,
                          fontSize: 12.sp,
                          color: tagColor,
                          fontWeight: TextWeight.semi,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget tabContentBtn({
    String text = "View Profile",
    required void Function()? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          textStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 16.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(text),
          ],
        ),
      ),
    );
  }
}
