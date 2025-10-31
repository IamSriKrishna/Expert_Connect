// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_constant.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/widgets/category_shimmer.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CategoryWidget {
  static Widget sideBar(HomeState state) {
     if(state.status == HomeStateStatus.loading){
      return CategoryShimmer.buildSideBarShimmerState();
    }
    return Container(
      width: 80.w,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: state.subCategories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48.h,
                  width: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4F46E5),
                        const Color(0xFF7C3AED),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.all_inclusive,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                CommonWidgets.text(
                  text: "All",
                  textAlign: TextAlign.center,
                  fontWeight: TextWeight.regular,
                  fontFamily: TextFamily.interRegular,
                  fontSize: 10.sp,
                  maxLines: 3,
                  color: const Color(0xFF64748B),
                ),
              ],
            );
          }

          final subCategory = state.subCategories[index - 1];
          return Padding(
            padding: EdgeInsets.only(top: 15.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48.h,
                  width: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getItemColor(index + 2),
                    boxShadow: [
                      BoxShadow(
                        color: _getItemColor(index + 2).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(subCategory.id),
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                CommonWidgets.text(
                  text: subCategory.subCategoryName,
                  textAlign: TextAlign.center,
                  fontWeight: TextWeight.regular,
                  fontFamily: TextFamily.interRegular,
                  fontSize: 10.sp,
                  maxLines: 3,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget mainContent(int categoryId, HomeState state,String categoryName) {
    if(state.status == HomeStateStatus.loading){
      return CategoryShimmer.buildProfessionalShimmerState();
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: state.subCategories.length,
          itemBuilder: (context, index) {
            final subCategories = state.subCategories[index];
            return InkWell(
              onTap: () {
                Get.toNamed(
                  RoutesName.viewProfile,
                  arguments: {
                    "category": subCategories.subCategoryName,
                    "id": subCategories.id,
                  },
                );
              },
              child: Container(
                height: 88.h,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getItemColor(index),
                              _getItemColor(index).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getItemColor(index).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            subCategories.subCategoryName[0].capitalizeWords(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              subCategories.subCategoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              categoryName,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF64748B),
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

  static IconData _getCategoryIcon(int index) {
    const icons = [
      Icons.medical_services_outlined,
      Icons.psychology_outlined,
      Icons.healing_outlined,
      Icons.local_hospital_outlined,
    ];
    return icons[index % icons.length];
  }

  static Color _getItemColor(int index) {
    const colors = [
      Color(0xFF4F46E5), // Indigo
      Color(0xFF059669), // Emerald
      Color(0xFFDC2626), // Red
      Color(0xFFD97706), // Amber
      Color(0xFF7C3AED), // Purple
    ];
    return colors[index % colors.length];
  }
}
