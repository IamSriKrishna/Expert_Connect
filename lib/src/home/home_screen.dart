import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/widgets/home_shimmer_widget.dart';
import 'package:expert_connect/src/home/widgets/home_widgets.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearchActive = false;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String value) {
    setState(() {
      isSearchActive = value.isNotEmpty;
      searchQuery = value.toLowerCase().trim();
    });

    // Trigger search through BLoC when there's a query
    if (value.trim().isNotEmpty) {
      context.read<HomeBloc>().add(SearchVendors(searchQuery: value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeTabControllerCubit, int>(
      builder: (context, state) {
        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            return RefreshIndicator(
              onRefresh: ()async{
                context.read<HomeBloc>().add(FetchFeaturedProfessionalVendors());
                context.read<HomeBloc>().add(FetchMostPopularVendors());
                context.read<HomeBloc>().add(FetchBannerDetails());
                context.read<HomeBloc>().add(FetchCategoriesList());
                context.read<HomeBloc>().add(FetchUserNotifications());
              },
              child: Scaffold(
                body: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: [
                    CommonWidgets.appBar(
                      count: homeState.notifications
                          .where((e) => e.readAt == null)
                          .length,
                    ),
              
                    // Pass the search callback to searchBar
                    HomeWidgets.searchBar(
                      onSearchChanged: onSearchChanged,
                      controller: searchController,
                    ),
              
                    // Hide these widgets when search is active
                    if (!isSearchActive) ...[
                      // HomeWidgets.filters(),
                      HomeWidgets.category(),
                      homeState.vendors.isNotEmpty
                          ? HomeWidgets.featuredProfessional()
                          : SliverToBoxAdapter(),
                      homeState.isVendorLoading
                          ? ShimmerWidgets.featuredWidgetsShimmer()
                          : homeState.featuredVendors.isNotEmpty
                          ? HomeWidgets.featuredWidgets(state: homeState)
                          : SliverToBoxAdapter(),
                      homeState.bannerDetails.bannerDetails.banner.isNotEmpty
                          ? HomeWidgets.getExpertAdviceCard(homeState: homeState)
                          : SliverToBoxAdapter(),
                      HomeWidgets.buildTabController(context, state: state),
              
                      homeState.isVendorLoading
                          ? ShimmerWidgets.buildTabContentShimmer()
                          : HomeWidgets.buildTabContent(
                              state: state,
                              homeState: homeState,
                            ),
                    ],
              
                    // Show search results when search is active
                    if (isSearchActive) ...[
                      // Show loading state
                      if (homeState.isSearchLoading)
                        ShimmerWidgets.featuredWidgetsShimmer(),
              
                      // Show empty state
                      if (homeState.isSearchEmpty ||
                          (homeState.isSearchLoaded &&
                              homeState.searchResults.isEmpty))
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16.h),
                                CommonWidgets.text(
                                  text: "No experts found",
                                  fontSize: 18.sp,
                                  fontWeight: TextWeight.semi,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(height: 8.h),
                                CommonWidgets.text(
                                  text: "Try searching with different keywords",
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ],
                            ),
                          ),
                        ),
              
                      // Show search results
                      if (homeState.isSearchLoaded &&
                          homeState.searchResults.isNotEmpty)
                        HomeWidgets.featuredWidgetsVertical(
                          vendors: homeState.searchResults,
                        ),
              
                      // Show error state
                      if (homeState.isSearchFailed)
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64.sp,
                                  color: Colors.red.shade400,
                                ),
                                SizedBox(height: 16.h),
                                CommonWidgets.text(
                                  text: "Search failed",
                                  fontSize: 18.sp,
                                  fontWeight: TextWeight.semi,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(height: 8.h),
                                CommonWidgets.text(
                                  text: homeState.message,
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: () {
                                    if (searchQuery.isNotEmpty) {
                                      context.read<HomeBloc>().add(
                                        SearchVendors(searchQuery: searchQuery),
                                      );
                                    }
                                  },
                                  child: Text("Retry"),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
