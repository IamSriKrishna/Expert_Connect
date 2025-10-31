import 'package:expert_connect/src/app/app_routes.dart';
import 'package:expert_connect/src/app/firebase_manager.dart';
import 'package:expert_connect/src/app/notification_service.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/auth/repo/auth_repo.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await firebaseManager.initialize();
  await authStateManager.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ChangeNotifierProvider.value(
          value: authStateManager,
          child: Consumer<AuthStateManager>(
            builder: (context, authManager, child) {
              if (authManager.isLoading) {
                return MaterialApp(
                  home: const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  debugShowCheckedModeBanner: false,
                );
              }

              // Initialize notifications after login
              if (authManager.isLoggedIn && authManager.user != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  NotificationHelper.initializeAfterLogin(
                    authManager.user!.id.toString(),
                  );
                });
              }

              return BlocProvider(
                create: (context) =>
                    AuthBloc(authRepository: AuthRepoImpl())
                      ..add(CountryFetched()),
                child: GetMaterialApp(
                  title: 'Expert Connect',
                  theme: ThemeData(
                    useMaterial3: false,
                    primarySwatch: Colors.blue,
                  ),
                  initialRoute: authManager.isLoggedIn
                      ? RoutesName.bottom
                      : RoutesName.splash,
                  getPages: AppRoutes.pages,
                  debugShowCheckedModeBanner: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
}