import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidgets {
  // Professional shimmer colors
  static const Color _baseColor = Color(0xFFE8E8E8);
  static const Color _highlightColor = Color(0xFFF5F5F5);
  static const Duration _period = Duration(milliseconds: 1200);

  // Professional gradient shimmer effect
  static Widget _buildGradientShimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      period: _period,
      direction: ShimmerDirection.ltr,
      child: child,
    );
  }

  // Enhanced shimmer container with subtle shadow
  static Widget _buildShimmerContainer({
    required double height,
    required double width,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        shape: shape,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  // Professional featured widgets shimmer
  static Widget featuredWidgetsShimmer() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 170.h,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: _buildGradientShimmer(
                child: Container(
                  width: 220.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFF0F0F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Professional profile image shimmer with subtle gradient
                            Container(
                              height: 60.h,
                              width: 70.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32.sw),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _baseColor,
                                    _highlightColor,
                                    _baseColor,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name shimmer with varied width
                                  _buildShimmerContainer(
                                    height: 16.h,
                                    width: double.infinity,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  SizedBox(height: 6.h),
                                  // Specialty shimmer
                                  _buildShimmerContainer(
                                    height: 12.h,
                                    width: 85.w,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  SizedBox(height: 8.h),
                                  // Rating section with star and number
                                  Row(
                                    children: [
                                      _buildShimmerContainer(
                                        height: 16.h,
                                        width: 16.w,
                                        shape: BoxShape.circle,
                                      ),
                                      SizedBox(width: 6.w),
                                      _buildShimmerContainer(
                                        height: 12.h,
                                        width: 32.w,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        // Professional button shimmer
                        Container(
                          width: double.infinity,
                          height: 42.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                _baseColor.withOpacity(0.8),
                                _highlightColor,
                                _baseColor.withOpacity(0.8),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Professional tab content shimmer
  static Widget buildTabContentShimmer() {
    return SliverList.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildGradientShimmer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFF0F0F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.w, horizontal: 16.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Professional profile image with gradient
                        Container(
                          height: 60.h,
                          width: 70.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32.sw),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _baseColor,
                                _highlightColor,
                                _baseColor,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name with dynamic width
                              _buildShimmerContainer(
                                height: 16.h,
                                width: index.isEven ? double.infinity : 180.w,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              SizedBox(height: 6.h),
                              // Specialty
                              _buildShimmerContainer(
                                height: 12.h,
                                width: 110.w,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              SizedBox(height: 8.h),
                              // Rating and tag row
                              Row(
                                children: [
                                  // Star icon
                                  _buildShimmerContainer(
                                    height: 16.h,
                                    width: 16.w,
                                    shape: BoxShape.circle,
                                  ),
                                  SizedBox(width: 6.w),
                                  // Rating number
                                  _buildShimmerContainer(
                                    height: 12.h,
                                    width: 32.w,
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  SizedBox(width: 12.w),
                                  // Tag with pill shape
                                  Container(
                                    height: 22.h,
                                    width: 65.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      gradient: LinearGradient(
                                        colors: [
                                          _baseColor.withOpacity(0.6),
                                          _highlightColor,
                                          _baseColor.withOpacity(0.6),
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    // Professional buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (buttonIndex) {
                        return Container(
                          width: 105.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                _baseColor.withOpacity(0.7),
                                _highlightColor,
                                _baseColor.withOpacity(0.7),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                            border: Border.all(
                              color: _baseColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Professional loading indicator for other sections
  static Widget buildSectionShimmer({
    required double height,
    EdgeInsets? padding,
    int itemCount = 3,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        height: height,
        padding: padding ?? EdgeInsets.all(16.w),
        child: _buildGradientShimmer(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return Container(
                width: 120.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}