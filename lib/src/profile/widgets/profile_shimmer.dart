// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/profile/widgets/profile_widget.dart';
import 'package:flutter/material.dart';

class ProfileShimmer {
  static Scaffold body(
    AnimationController shimmerController,
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          ProfileWidget.appBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Enhanced Profile Card Skeleton with Professional Style
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Increased from 16
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), // Reduced opacity
                        blurRadius: 15, // Increased blur
                        offset: const Offset(0, 5), // Adjusted offset
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Enhanced Avatar Skeleton
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), // Changed from circular to rounded square
                                color: Colors.grey[200], // Lighter color
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                    _buildShimmerEffect(shimmerController),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Enhanced Name and Status Skeleton
                                  Row(
                                    children: [
                                      Container(
                                        height: 18, // Standardized height
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(9),
                                        ),
                                        child: _buildShimmerEffect(
                                          shimmerController,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 18,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(9),
                                        ),
                                        child: _buildShimmerEffect(
                                          shimmerController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Enhanced Profession Skeleton
                                  Container(
                                    height: 14,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: _buildShimmerEffect(
                                      shimmerController,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Enhanced Rating & Experience Skeleton
                                  Row(
                                    children: [
                                      Container(
                                        height: 14,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        child: _buildShimmerEffect(
                                          shimmerController,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 14,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        child: _buildShimmerEffect(
                                          shimmerController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Enhanced Location Skeleton
                                  Container(
                                    height: 14,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: _buildShimmerEffect(
                                      shimmerController,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Enhanced Buttons Skeleton
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 36, // Reduced height for more professional look
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12), // Increased border radius
                                ),
                                child: _buildShimmerEffect(shimmerController),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _buildShimmerEffect(shimmerController),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Section Skeletons
                _buildProfessionalSectionSkeleton(shimmerController),
                _buildProfessionalSectionSkeleton(shimmerController),
                _buildProfessionalSectionSkeleton(shimmerController),
                _buildProfessionalSectionSkeleton(shimmerController),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildShimmerEffect(AnimationController shimmerController) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          colors: [Colors.grey[200]!, Colors.grey[100]!, Colors.grey[200]!], // Lighter base colors
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: shimmerController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(shimmerController.value * 100 - 0, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0, 0.0),
                  end: Alignment(1.0, 0.0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.8), // Increased opacity for better effect
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Enhanced section skeleton with professional styling
  static Widget _buildProfessionalSectionSkeleton(AnimationController shimmerController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Increased border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Reduced shadow opacity
            blurRadius: 15, // Increased blur radius
            offset: const Offset(0, 5), // Adjusted shadow offset
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Title Skeleton
            Container(
              height: 18,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(9),
              ),
              child: _buildShimmerEffect(shimmerController),
            ),
            const SizedBox(height: 16),
            // Enhanced Content Lines Skeleton
            for (int i = 0; i < 3; i++) ...[
              Container(
                height: 14,
                width: double.infinity * (0.7 + (i * 0.1)),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(7),
                ),
                child: _buildShimmerEffect(shimmerController),
              ),
            ],
            const SizedBox(height: 12),
            // Added stats-like placeholders similar to professional loading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (i) => Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildShimmerEffect(shimmerController),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 25,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _buildShimmerEffect(shimmerController),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}