// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/models/article_vendor_list.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
class AboutArticleWidget {
  static Widget appBar({required ArticleVendorList article}) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 320.h,
      stretch: true,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black87,
          size: 20.sp,
        ),
      ),

      flexibleSpace: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double stretchFactor = constraints.maxHeight / 320.h;
            final double zoomScale = 1.0 + (stretchFactor - 1.0) * 0.5;

            return FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: Transform.scale(
                scale: zoomScale.clamp(1.0, 1.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: article.id,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24.r),
                            bottomRight: Radius.circular(24.r),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              "${AppUrl.imageUrl}/${article.image}",
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget showProfile({required ArticleVendorList article}) {
    return CommonWidgets.sliverPadding(
      20,
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  margin: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                       "${AppUrl.imageUrl}/${article.vendor.img!}",
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
                      text: article.vendor.name.capitalizeWords(),
                      fontSize: 18.sp,
                      fontFamily: TextFamily.interBold,
                      fontWeight: TextWeight.bold,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        CommonWidgets.text(
                          text: DateFormat(
                            "MMMM dd, yyyy",
                          ).format(DateTime.parse(article.updatedAt)),
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                          fontFamily: TextFamily.interRegular,
                          fontWeight: TextWeight.regular,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.more_vert,
                  size: 18.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
static Widget articleContent({required ArticleVendorList article}) {
  // Split the content into paragraphs
  List<String> paragraphs = article.content
      .split('\n')
      .where((paragraph) => paragraph.trim().isNotEmpty)
      .toList();

  return CommonWidgets.sliverPadding(
    0,
    sliver: SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article title
          CommonWidgets.text(
            text: _cleanHighlightedContent(article.title),
            fontSize: 24.sp,
            fontFamily: TextFamily.interBold,
            fontWeight: TextWeight.bold,
            color: Colors.black87,
            textAlign: TextAlign.left,
          ),

          SizedBox(height: 16.h),

          // Tags section
          if (article.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: article.tags.map((tag) => _buildTag(tag)).toList(),
            ),
            SizedBox(height: 20.h),
          ],

          // Dynamic content paragraphs with highlighted content inserted after first paragraph
          ...paragraphs.asMap().entries.map((entry) {
            int index = entry.key;
            String paragraph = entry.value;

            return Column(
              children: [
                _buildParagraph(paragraph),
                
                // Insert highlighted content after first paragraph (index 0)
                if (index == 0) ...[
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 4.w,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: CommonWidgets.text(
                              text: article.highlightedContent,
                              fontSize: 17.sp,
                              fontFamily: TextFamily.interMedium,
                              fontWeight: TextWeight.medium,
                              color: Colors.blue.shade900,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ] else if (index < paragraphs.length - 1) 
                  SizedBox(height: 20.h),
              ],
            );
          }),

          SizedBox(height: 24.h),
        ],
      ),
    ),
  );
}

static Widget _buildParagraph(String text) {
  return CommonWidgets.text(
    text: text,
    fontSize: 16.sp,
    fontFamily: TextFamily.interRegular,
    fontWeight: TextWeight.regular,
    color: Colors.black87,
    textAlign: TextAlign.justify,
  );
}

static Widget _buildTag(String tag) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: Colors.blue.shade300, width: 1),
    ),
    child: CommonWidgets.text(
      text: tag,
      fontSize: 12.sp,
      fontFamily: TextFamily.interMedium,
      fontWeight: TextWeight.medium,
      color: Colors.blue.shade700,
    ),
  );
}

static String _cleanHighlightedContent(String content) {
  // Remove markdown formatting and any incomplete text
  return content.replaceAll('**', '').replaceAll('*', '').trim();
}}
