// ignore_for_file: deprecated_member_use

import 'package:expert_connect/src/app/app_constant.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/models/vendors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ViewProfile extends StatefulWidget {
  final String category;
  final int subCategoryId;
  const ViewProfile({
    super.key,
    required this.subCategoryId,
    required this.category,
  });

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile>
    with TickerProviderStateMixin {
  String selectedCategory = 'Featured';
  bool isSearchFocused = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<String> categories = [
    'Featured',
    'Rating',
    'Location',
    'Experience',
  ];
  List<Vendor> filteredVendors = [];

  // 2. Add search method
  void _filterVendors(String query, List<Vendor> allVendors) {
    setState(() {
      if (query.isEmpty) {
        filteredVendors = allVendors;
      } else {
        filteredVendors = allVendors
            .where(
              (vendor) =>
                  vendor.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _searchController.addListener(() {
      // This will be handled in BlocBuilder
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Method to apply filters based on selected category
  List<Vendor> _applyFilters(List<Vendor> vendors) {
    List<Vendor> result = List.from(vendors);

    // Apply search filter first
    if (_searchController.text.isNotEmpty) {
      result = result
          .where(
            (vendor) => vendor.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    // Apply category-specific filters
    switch (selectedCategory) {
      case 'Rating':
        // Sort by rating (highest first) and filter vendors with rating > 0
        result = result
            .where(
              (vendor) =>
                  vendor.ratingsAvgRating != null &&
                  vendor.ratingsAvgRating!.isNotEmpty &&
                  double.tryParse(vendor.ratingsAvgRating!) != null &&
                  double.parse(vendor.ratingsAvgRating!) > 0,
            )
            .toList();

        result.sort((a, b) {
          double ratingA = double.tryParse(a.ratingsAvgRating ?? '0') ?? 0;
          double ratingB = double.tryParse(b.ratingsAvgRating ?? '0') ?? 0;
          return ratingB.compareTo(ratingA);
        });
        break;

      case 'Location':
        // Filter by matching city with user's city
        final userCity = authStateManager.user!.city;
        if (userCity != 0) {
          result = result.where((vendor) => vendor.city == userCity).toList();
        }
        break;

      case 'Experience':
        // Sort by experience (highest first) - assuming there's an experience field
        // If experience field doesn't exist, you can sort by yearsOfExperience or similar
        result.sort((a, b) => (b.exp ?? 0).compareTo(a.exp ?? 0));
        break;

      default: // Featured
        // Keep original order or implement featured logic
        break;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(HomeRepoImpl())
        ..add(FetchVendorsBySubCategory(subCategoryId: widget.subCategoryId)),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  centerTitle: true,
                  title: Text(
                    widget.category.capitalizeWords(),
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                  backgroundColor: Colors.transparent,
                ),

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildModernSearchBar(),
                      const SizedBox(height: 20),
                      _buildAnimatedFilterChips(),
                    ],
                  ),
                ),

                // Dynamic Section based on selected filter
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildDynamicSection(state),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicSection(HomeState state) {
    String title;

    switch (selectedCategory) {
      case 'Rating':
        title = 'Top Rated ${widget.category}';
        break;
      case 'Location':
        title = '${widget.category} Near You';
        break;
      case 'Experience':
        title = 'Most Experienced ${widget.category}';
        break;
      default: // Featured
        title = 'Featured ${widget.category}';
    }

    // Apply all filters (search + category filters)
    List<Vendor> displayVendors = _applyFilters(state.vendors);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              // Show search results count
              if (_searchController.text.isNotEmpty ||
                  selectedCategory != 'Featured')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${displayVendors.length} found',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.vendorStatus == HomeStateStatus.loading)
            _buildProfessionalLoadingState(),
          if (state.vendorStatus == HomeStateStatus.empty ||
              displayVendors.isEmpty)
            _buildProfessionalEmptyState(),
          if (displayVendors.isNotEmpty)
            SizedBox(
              height: 220.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayVendors.length,
                itemBuilder: (context, index) {
                  final vendor = displayVendors[index];
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(
                      right: index < displayVendors.length - 1 ? 16 : 0,
                      bottom: 10,
                    ),
                    child: _buildFeaturedLawyerCard(vendor),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLawyerCard(Vendor vendor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: vendor.availabilityStatus == "online"
                                  ?  Colors.green.shade100:Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: vendor.availabilityStatus == "online"
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vendor.availabilityStatus,
                            style: TextStyle(
                              color: vendor.availabilityStatus == "online"
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6),
                        const Color(0xFF60A5FA),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.network(
                          "${AppUrl.imageUrl}/${vendor.img}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  vendor.name.capitalizeWords(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstant.getSubCategoryNameById(vendor.subCategoryId),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                // Show rating when Rating filter is selected
                if (selectedCategory == 'Rating' &&
                    vendor.ratingsAvgRating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vendor.ratingsAvgRating!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],

                // Show city when Location filter is selected
                if (selectedCategory == 'Location' &&
                    vendor.city != authStateManager.user!.city) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          vendor.cityName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Show experience when Experience filter is selected
                if (selectedCategory == 'Experience' && vendor.exp != 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${vendor.exp} years',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(
                          RoutesName.profile,
                          arguments: {"id": vendor.id},
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'View Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalLoadingState() {
    return SizedBox(
      height: 240.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with status and favorite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Profile image placeholder
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name placeholder
                  Center(
                    child: Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Specialization placeholder
                  Center(
                    child: Container(
                      width: 90,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats placeholders
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      3,
                      (i) => Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 25,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Button placeholder
                  Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfessionalEmptyState() {
    bool isSearching = _searchController.text.isNotEmpty;
    bool isFiltering = selectedCategory != 'Featured';

    return Container(
      height: 240.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF60A5FA).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : isFiltering
                  ? Icons.filter_list_off_rounded
                  : Icons.person_search_rounded,
              size: 40,
              color: const Color(0xFF3B82F6).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching
                ? 'No Results Found'
                : isFiltering
                ? 'No Matching ${widget.category} Found'
                : 'No ${widget.category} Found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isSearching
                  ? 'No ${widget.category.toLowerCase()} found for "${_searchController.text}". Try a different search term.'
                  : isFiltering && selectedCategory == 'Location'
                  ? 'No ${widget.category.toLowerCase()} found in your city. Try selecting a different filter.'
                  : isFiltering && selectedCategory == 'Rating'
                  ? 'No rated ${widget.category.toLowerCase()} found. Try selecting a different filter.'
                  : isFiltering && selectedCategory == 'Experience'
                  ? 'No experienced ${widget.category.toLowerCase()} found. Try selecting a different filter.'
                  : 'We couldn\'t find any ${widget.category.toLowerCase()} matching your current criteria.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              if (isSearching) {
                _searchController.clear();
                setState(() => isSearchFocused = false);
              } else if (isFiltering) {
                setState(() => selectedCategory = 'Featured');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                ),
              ),
              child: Text(
                isSearching
                    ? 'Clear Search'
                    : isFiltering
                    ? 'Clear Filter'
                    : 'Try Different Filter',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onTap: () => setState(() => isSearchFocused = true),
          onChanged: (query) {
            // This will trigger rebuild and filtering in BlocBuilder
            setState(() {});
          },
          onSubmitted: (_) => setState(() => isSearchFocused = false),
          decoration: InputDecoration(
            hintText: 'Search ${widget.category.toLowerCase()}...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search_rounded,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
            suffixIcon: isSearchFocused
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => isSearchFocused = false);
                    },
                    icon: const Icon(Icons.clear_rounded),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = selectedCategory == categories[index];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(left: index == 0 ? 0 : 12, right: 0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : Colors.grey.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
}
