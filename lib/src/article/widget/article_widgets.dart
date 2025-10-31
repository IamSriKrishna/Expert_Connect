// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/article/bloc/article_bloc.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/models/article_vendor_list.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ArticleWidgets {
  static Widget appBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: false,
      pinned: false,
      elevation: 0,
      title: ShaderMask(
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
        child: CommonWidgets.text(
          text: "EC Corner",
          fontFamily: TextFamily.manropeBold,
          fontSize: 24.sp,
          color: Colors.white,
        ),
      ),
      leading: null,
    );
  }

  static Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern illustration container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade400,
                    AppColor.primaryColor.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.article_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 32),

            // Title
            Text(
              'No Articles Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 12),

            // Subtitle
            Text(
              'Discover amazing articles from our\nexperts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            SizedBox(height: 32),

            // Action button (optional)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    AppColor.primaryColor.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Add refresh functionality
                  context.read<ArticleBloc>().add(GetArticleVendorList());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget preview({required ArticleVendorList article}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Hero(
        tag: article.id,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.toNamed(
                RoutesName.aboutArticleScreen,
                arguments: {"article": article},
              );
            },
            borderRadius: BorderRadius.circular(20.r),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 480.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),

                      image: DecorationImage(
                        fit: BoxFit.cover,

                        image: NetworkImage(
                          "${AppUrl.imageUrl}/${article.image}",
                        ),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.3, 1.0],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.r),
                          bottomRight: Radius.circular(20.r),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category Tag
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF667eea).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CommonWidgets.text(
                              text: article.tags[0],
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontFamily: TextFamily.interMedium,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Title
                          CommonWidgets.text(
                            text: article.title,
                            fontSize: 22.sp,
                            color: Colors.white,
                            fontFamily: TextFamily.interBold,
                            maxLines: 3,
                          ),

                          SizedBox(height: 8.h),

                          // Description
                          CommonWidgets.text(
                            text: article.content,
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: TextFamily.interRegular,
                            maxLines: 2,
                          ),

                          SizedBox(height: 16.h),

                          // Author and Date
                          Row(
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF667eea).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(50.r),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        "${AppUrl.imageUrl}/${article.vendor.img}",
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonWidgets.text(
                                      text: article.vendor.name
                                          .capitalizeWords(),
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontFamily: TextFamily.interMedium,
                                    ),
                                    SizedBox(height: 2.h),
                                    CommonWidgets.text(
                                      text: DateFormat("MMMM dd, yyyy").format(
                                        DateTime.parse(article.updatedAt),
                                      ),
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.7),
                                      fontFamily: TextFamily.interRegular,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget floatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(RoutesName.createArticleScreen);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: Icon(Icons.edit, color: Colors.white),
        label: CommonWidgets.text(
          text: "Write",
          color: Colors.white,
          fontSize: 16.sp,
          fontFamily: TextFamily.interMedium,
        ),
      ),
    );
  }
}
