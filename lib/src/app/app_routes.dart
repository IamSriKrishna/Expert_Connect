import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/appointment/agora_screen.dart';
import 'package:expert_connect/src/appointment/bloc/appointment_bloc.dart';
import 'package:expert_connect/src/appointment/repo/appointment_repo.dart';
import 'package:expert_connect/src/article/about_article_screen.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/auth/forget_password.dart';
import 'package:expert_connect/src/auth/login_screen.dart';
import 'package:expert_connect/src/auth/otp_screen.dart';
import 'package:expert_connect/src/auth/repo/auth_repo.dart';
import 'package:expert_connect/src/auth/signup_screen.dart';
import 'package:expert_connect/src/chat/bloc/chat_bloc.dart';
import 'package:expert_connect/src/chat/repo/chat_repo.dart';
import 'package:expert_connect/src/home/bloc/home_bloc.dart';
import 'package:expert_connect/src/home/bottom_navigator_page.dart';
import 'package:expert_connect/src/home/category_screen.dart';
import 'package:expert_connect/src/home/message_screen.dart';
import 'package:expert_connect/src/home/notification_screen.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/profile/booking_screen.dart';
import 'package:expert_connect/src/profile/profile_screen.dart';
import 'package:expert_connect/src/profile/view_profile.dart';
import 'package:expert_connect/src/settings/bloc/setting_bloc.dart';
import 'package:expert_connect/src/settings/profile_screen.dart';
import 'package:expert_connect/src/settings/repo/setting_repo.dart';
import 'package:expert_connect/src/settings/transaction_screen.dart';
import 'package:expert_connect/src/splashscreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;
import 'package:get/get.dart';

class AppRoutes {
  static List<GetPage> get pages => [
    _page(name: RoutesName.splash, page: () => const SplashScreen()),
    _page(name: RoutesName.login, page: () => const LoginScreen()),
    _page(name: RoutesName.signUp, page: () => const SignupScreen()),
    _page(
      name: RoutesName.notificationScreen,
      page: () => BlocProvider(
        create: (context) => HomeBloc(HomeRepoImpl()),
        child: const NotificationScreen(),
      ),
    ),
    _page(
      name: RoutesName.forgetPasswordScreen,
      page: () => BlocProvider(
        create: (context) => AuthBloc(authRepository: AuthRepoImpl()),
        child: const ForgotPasswordScreen(),
      ),
    ),
    _page(
      name: RoutesName.profileScreen,
      page: () => BlocProvider(
        create: (context) => SettingBloc(SettingRepoImpl()),
        child: ProfileUpdateScreen(),
      ),
    ),
    _page(
      name: RoutesName.transactionScreen,
      page: () => BlocProvider(
        create: (context) =>
            SettingBloc(SettingRepoImpl())..add(FetchWalletSummary()),
        child: TransactionHistoryScreen(),
      ),
    ),
    _page(
      name: RoutesName.bottom,
      page: () => const BottomNavigatorPage(),
      transition: Transition.downToUp,
    ),
    _page(
      name: RoutesName.profile,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final id = arguments?['id'] ?? 0;

        return ProfileScreen(id: id);
      },
      transition: Transition.fade,
    ),
    _page(
      name: RoutesName.agoraCallScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final channelName = arguments?['channelName'] as String;
        final meetingDuration = arguments?['meeting_duration'] as int;
        final time = arguments?['time'] as String;
        final token = arguments?['token'] as String;
        final meetingId = arguments?['meetingId'] as int;
        // Validate required parameters
        if (channelName.isEmpty || token.isEmpty) {
          throw ArgumentError(
            'Channel name and token are required for Agora call',
          );
        }

        return BlocProvider(
          create: (context) => AppointmentBloc(AppointmentImpl()),
          child: AgoraCallScreen(
            channel: channelName,
            meetingDuration: meetingDuration,
            time: time,
            token: token,
            meetingId: meetingId,
          ),
        );
      },
      transition: Transition.cupertino,
    ),
    _page(
      name: RoutesName.otp,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final email = arguments?['email'] ?? '';

        return EmailOTPVerificationScreen(email: email);
      },
      transition: Transition.downToUp,
    ),
    _page(
      name: RoutesName.booking,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final id = arguments?['id'] ?? '';
        final appointmentType = arguments?['appointment_type'] ?? '';

        return AppointmentBookingScreen(
          id: id,
          appointmentTypeModel: appointmentType,
        );
      },
      transition: Transition.leftToRight,
    ),
    _page(
      name: RoutesName.category,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final id = arguments?['id'] ?? '';
        final category = arguments?['category'] ?? '';

        return CategoryScreen(id: id, category: category);
      },
      transition: Transition.leftToRight,
    ),
    _page(
      name: RoutesName.viewProfile,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final subCategoryId = arguments?['id'] ?? 0;
        final category = arguments?['category'] ?? '';

        return ViewProfile(subCategoryId: subCategoryId, category: category);
      },
      transition: Transition.leftToRight,
    ),
    _page(
      name: RoutesName.aboutArticleScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final article = arguments?['article'] ?? '';
        return AboutArticleScreen(article: article);
      },
      transition: Transition.downToUp,
    ),
    // Updated route configuration
    _page(
      name: RoutesName.messageScreen,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final vendorId = arguments?['vendorId'] ?? 0;
        final vendorName = arguments?['vendorName'] ?? '';
        final ChatBloc? chatBloc = arguments?['chatBloc'];
        final bool isFromChatScreen = arguments?['isFromChatScreen'] ?? false;

        if (chatBloc != null && isFromChatScreen) {
          return BlocProvider.value(
            value: chatBloc,
            child: MessageScreen(
              vendorId: vendorId,
              chatBloc: chatBloc,
              vendorName: vendorName,
              isFromChatScreen: isFromChatScreen,
            ),
          );
        } else {
          return BlocProvider(
            create: (context) =>
                ChatBloc(chatRepository: ChatRepoImpl())..add(FetchChatList()),
            child: MessageScreen(
              vendorId: vendorId,
              vendorName: vendorName,
              chatBloc: chatBloc,
              isFromChatScreen: isFromChatScreen,
            ),
          );
        }
      },
      transition: Transition.rightToLeft,
    ),
  ];

  static GetPage _page({
    required String name,
    required Widget Function() page,
    Transition transition = Transition.fadeIn,
  }) {
    return GetPage(
      name: name,
      page: page,
      transition: transition,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
