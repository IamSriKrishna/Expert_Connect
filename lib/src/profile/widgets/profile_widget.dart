// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_constant.dart';
import 'package:expert_connect/src/app/app_dailog.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileWidget {
  static Widget appBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: false,
      floating: true,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  static void show(
    BuildContext context,
    String vendorName,
    int vendorId,
    HomeState state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => BookingBottomSheet(
        vendorName: vendorName,
        vendorId: vendorId,
        state: state,
      ),
    );
  }

  static Widget vendorContentAndBooking(HomeState state, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: state.vendor.img == null
                        ? Border.all(color: Colors.blue.shade100, width: 3)
                        : null,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        "${AppUrl.imageUrl}/${state.vendor.img}",
                      ),
                    ),
                  ),
                  child: state.vendor.img != null
                      ? SizedBox.shrink()
                      : Center(
                          child: CommonWidgets.text(
                            text: state.vendor.name[0],
                            fontSize: 22.sp,
                            fontWeight: TextWeight.bold,
                            fontFamily: TextFamily.interBold,
                            color: Colors.blue.shade100,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            state.vendor.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: const Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstant.getSubCategoryNameById(
                          state.vendor.subCategoryId,
                        ).capitalizeWords(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: state.reviews.isEmpty
                                ? 0
                                : state.reviews
                                          .map((e) => e.rating)
                                          .reduce((a, b) => a + b) /
                                      state.reviews.length,
                            itemBuilder: (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${state.reviews.isEmpty ? 0 : state.reviews.map((e) => e.rating).reduce((a, b) => a + b) / state.reviews.length} (${state.reviews.length} ${state.reviews.length <= 1 ? "review" : "reviews"})',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.vendor.exp <= 0
                                ? '${state.vendor.exp} Year'
                                : '${state.vendor.exp} Years Exp.',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.vendor.cityName,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      show(context, state.vendor.name, state.vendor.id, state);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Book Consultation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(
                        RoutesName.messageScreen,
                        arguments: {
                          "vendorId": state.vendor.id,
                          "vendorName": state.vendor.name,
                          'isFromChatScreen': false,
                          
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      side: BorderSide(color: Colors.blue[800]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget aboutSection(HomeState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${AppConstant.getCategoryNameById(state.vendor.categoryId)} specialist ${state.vendor.name} has ${state.vendor.exp <= 0 ? '${state.vendor.exp} Year' : '${state.vendor.exp} Years'} of experience in ${AppConstant.getSubCategoryNameById(state.vendor.subCategoryId)}. ${state.vendor.name} is known for their expertise in legal matters and has helped numerous clients achieve favorable outcomes.',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // _buildInfoItem(
                //   Icons.school,
                //   'Education',
                //   'LLB,\nHarvard Law School',
                // ),
                // const SizedBox(width: 16),
                _buildInfoItem(
                  Icons.work,
                  'Experience',
                  state.vendor.exp <= 0
                      ? '${state.vendor.exp} Year'
                      : '${state.vendor.exp} Years Exp.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget consultationOptionsSection(
    HomeState state,
    dynamic selectedAppointment,
    dynamic loadingAppointment,
    bool isNavigating,
    Function(dynamic) onAppointmentSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultation Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...state.appointmentTypeModel.map(
              (e) => _buildConsultationOption(
                e.service.toLowerCase() == "audio"
                    ? Icons.phone
                    : e.service.toLowerCase() == 'video'
                    ? Icons.videocam
                    : Icons.chat_bubble_outline,
                e.type,
                '₹${e.price}/session',
                e.service.toLowerCase() == "audio"
                    ? Colors.green[100]!
                    : e.service.toLowerCase() == 'video'
                    ? Colors.purple[100]!
                    : Colors.blue[100]!,
                e,
                selectedAppointment,
                loadingAppointment,
                isNavigating,
                onAppointmentSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }


  static Widget expertiseSection(HomeState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Areas of Expertise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.areasOfExpertise
                  .map((e) => _buildExpertiseChip(e.areaOfExpertise))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  static Widget reviewsSection({required HomeState state}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Client Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...state.reviews.map(
              (review) => Column(
                children: [
                  _buildReviewItem(
                    review.userName,
                    review.userName[0].capitalizeWords(),
                    review.rating,
                    review.review,
                    review.createdAt,
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget experienceSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professional Experience',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildExperienceItem(
              'Senior Legal Consultant',
              'Law & Partners LLP',
              '2018 - Present',
            ),
            _buildExperienceItem(
              'Associate Attorney',
              'Justice Legal Group',
              '2014 - 2018',
            ),
            _buildExperienceItem(
              'Legal Intern',
              'Supreme Court of India',
              '2012 - 2014',
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoItem(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[800]),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildConsultationOption(
    IconData icon,
    String title,
    String price,
    Color bgColor,
    dynamic appointmentData,
    dynamic selectedAppointment,
    dynamic loadingAppointment,
    bool isNavigating,
    Function(dynamic) onTap,
  ) {
    bool isSelected = selectedAppointment?.id == appointmentData.id;
    bool isLoading = isNavigating && loadingAppointment?.id == appointmentData.id;
    
    return GestureDetector(
      onTap: isNavigating ? null : () => onTap(appointmentData),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLoading ? bgColor.withOpacity(0.8) : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                      ),
                    )
                  : Icon(
                      icon, 
                      size: 24, 
                      color: isSelected ? Colors.blue[800] : Colors.blue[800]
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLoading 
                          ? Colors.blue[800] 
                          : isSelected 
                              ? Colors.blue[800] 
                              : Colors.black87,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 12, 
                      color: isLoading 
                          ? Colors.blue[600]
                          : isSelected 
                              ? Colors.blue[600] 
                              : Colors.black54
                    ),
                    child: Text(
                      isLoading ? 'Opening booking...' : 'Instant booking available'
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          ),
                        )
                      : isSelected
                          ? Icon(
                              key: const ValueKey('selected'),
                              Icons.check_circle,
                              color: Colors.blue[600],
                              size: 20,
                            )
                          : const SizedBox(
                              key: ValueKey('empty'),
                              width: 20,
                              height: 20,
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  static Widget _buildExpertiseChip(String title) {
    return Chip(
      label: Text(
        title.capitalizeFirst!,
        style: TextStyle(fontSize: 14.sp, color: Colors.black87),
      ),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static Widget _buildReviewItem(
    String name,
    String imageUrl,
    int rating,
    String review,
    DateTime date,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.blue.shade100, width: 1),
          ),
          child: Center(
            child: CommonWidgets.text(
              text: imageUrl,
              fontSize: 14.sp,
              fontWeight: TextWeight.bold,
              fontFamily: TextFamily.interBold,
              color: Colors.blue.shade100,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(date),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              // const SizedBox(height: 4),
              // RatingBarIndicator(
              //   rating: rating.toDouble(),
              //   itemBuilder: (context, index) =>
              //       const Icon(Icons.star, color: Colors.amber),
              //   itemCount: 5,
              //   itemSize: 16,
              //   direction: Axis.horizontal,
              // ),
              const SizedBox(height: 8),
              Text(
                review,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildExperienceItem(
    String position,
    String company,
    String duration,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            position,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            company,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  static Widget reviewSubmissionSection(
    BuildContext context,
    int vendorId,
    HomeState homeState,
  ) {
    final TextEditingController reviewController = TextEditingController();
    double rating = 5.0;

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        // Clear form when review is successfully submitted
        if (state.status == HomeStateStatus.success &&
            state.message.contains("Successfully Submitted Review") == true) {
          reviewController.clear();
          rating = 5.0;
          // Optionally show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Review submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Your Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (value) {
                      setState(() {
                        rating = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your review here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    final isLoading = state.status == HomeStateStatus.loading;

                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (reviewController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please write a review'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              context.read<HomeBloc>().add(
                                SubmitReview(
                                  vendorId: vendorId,
                                  rating: rating.toInt(),
                                  review: _formatReviewText(
                                    rating.toInt(),
                                    reviewController.text,
                                    homeState,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit Review'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format review text
  static String _formatReviewText(
    int rating,
    String reviewText,
    HomeState homeState,
  ) {
    final stars = "⭐" * rating;
    final quality = rating == 5
        ? "Excellent"
        : rating == 4
        ? "Good"
        : rating == 3
        ? "Average"
        : rating == 2
        ? "Bad"
        : "Worst";

    final categoryName = AppConstant.getSubCategoryNameById(
      homeState.vendor.subCategoryId,
    );

    return "$stars $quality $categoryName\n\n$reviewText";
  }
}
