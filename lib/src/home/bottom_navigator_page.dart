import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/home/widgets/bottom_widgets.dart';
import 'package:expert_connect/src/settings/bloc/setting_bloc.dart';
import 'package:expert_connect/src/settings/repo/setting_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class BottomNavigatorPage extends StatefulWidget {
  const BottomNavigatorPage({super.key});

  @override
  State<BottomNavigatorPage> createState() => _BottomNavigatorPageState();
}

class _BottomNavigatorPageState extends State<BottomNavigatorPage> {
  bool _hasInitializedLocation = false;

  Future<void> _initializeUserLocation(BuildContext context) async {
    if (_hasInitializedLocation) return;
    _hasInitializedLocation = true;

    try {
      final position = await _getCurrentLocation();
      final timezone = await _getCurrentTimezone();
      
      if (mounted) {
        context.read<SettingBloc>().add(
          UpdateUserLocation(
            userId: authStateManager.user!.id,
            latitude: position.latitude.toString(),
            longitude: position.longitude.toString(),
            timezone: timezone,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing user location: $e');
    }
  }

  Future<String> _getCurrentTimezone() async {
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      return currentTimeZone;
    } catch (e) {
      debugPrint('Error getting timezone: $e');
      return 'UTC';
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldPop = await BottomWidgets.showExitDialog(context);
        if (shouldPop == true && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => HomeTabControllerCubit()),
          BlocProvider(create: (context) => BottomCubit()),
          BlocProvider(
            create: (context) => SettingBloc(SettingRepoImpl())
              ..add(FetchTransactionSummary())
              ..add(FetchWalletSummary()),
          ),
          BlocProvider(
            create: (context) => HomeBloc(HomeRepoImpl())
              ..add(FetchCategoriesList())
              ..add(FetchVendors())
              ..add(FetchFeaturedProfessionalVendors())
              ..add(FetchMostPopularVendors())
              ..add(FetchTopRatedVendors())
              ..add(FetchUserNotifications())
              ..add(FetchBannerDetails()),
          ),
        ],
        child: Builder(
          builder: (context) {
            // Initialize location after providers are available
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeUserLocation(context);
            });

            return BlocBuilder<BottomCubit, int>(
              builder: (context, state) {
                return Scaffold(
                  body: BottomWidgets.body(state),
                  bottomNavigationBar: BottomWidgets.bottomNavigator(
                    state,
                    onTap: (value) => context.read<BottomCubit>().changeIndex(value),
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }
}