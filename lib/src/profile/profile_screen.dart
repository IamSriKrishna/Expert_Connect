import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/profile/widgets/profile_shimmer.dart';
import 'package:expert_connect/src/profile/widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart'; // Add this import

class ProfileScreen extends StatefulWidget {
  final int id;
  const ProfileScreen({super.key, required this.id});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // Add this variable to track selected appointment
  dynamic selectedAppointment;
  // Add loading state for smooth transition
  bool isNavigating = false;
  dynamic loadingAppointment;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc(HomeRepoImpl())
            ..add(FetchVendorByID(id: widget.id))
            ..add(GetReview(vendorId: widget.id))
            ..add(FetchVendorAppointmentType(vendorId: widget.id))
            ..add(FetchVendorAreasOfExpertise(vendorId: widget.id)),
        ),
        BlocProvider(
          create: (context) => ShimmerCubit()..initializeController(this),
        ),
      ],
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, homeState) {
          if (homeState.vendorStatus == HomeStateStatus.loaded) {
            context.read<ShimmerCubit>().stopAnimation();
          }
        },
        builder: (context, homeState) {
          Logger().d("home status:${homeState.status}");
          if (homeState.vendorStatus == HomeStateStatus.loading ||
              homeState.vendor.name.toLowerCase() == "no-name") {
            return BlocBuilder<ShimmerCubit, ShimmerState>(
              builder: (context, shimmerState) {
                if (homeState.vendorStatus == HomeStateStatus.loading ||
                    homeState.vendor.name.toLowerCase() == "no-name") {
                  return ProfileShimmer.body(shimmerState.controller!, context);
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          }

          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                ProfileWidget.appBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ProfileWidget.vendorContentAndBooking(homeState, context),
                      ProfileWidget.aboutSection(homeState),
                      if (homeState.appointmentTypeModel.isNotEmpty)
                        // Pass the callback and selected appointment to the widget
                        ProfileWidget.consultationOptionsSection(
                          homeState,
                          selectedAppointment,
                          loadingAppointment,
                          isNavigating,
                          (appointment) async {
                            setState(() {
                              selectedAppointment = appointment;
                              isNavigating = true;
                              loadingAppointment = appointment;
                            });
                            
                            await Future.delayed(const Duration(milliseconds: 1200));
                            
                            Get.toNamed(
                              RoutesName.booking,
                              arguments: {
                                "id": widget.id,
                                "appointment_type": selectedAppointment,
                              },
                            );
                            
                            // Reset loading state when returning to this screen
                            if (mounted) {
                              setState(() {
                                isNavigating = false;
                                loadingAppointment = null;
                              });
                            }
                          },
                        ),
                      if (homeState.areasOfExpertise.isNotEmpty)
                        ProfileWidget.expertiseSection(homeState),
                      if (1 != 1) ProfileWidget.experienceSection(),
                      ProfileWidget.reviewsSection(state: homeState),
                      ProfileWidget.reviewSubmissionSection(
                        context,
                        widget.id,
                        homeState,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}