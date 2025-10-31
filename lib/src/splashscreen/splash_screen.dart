import 'package:expert_connect/src/splashscreen/bloc/splash_screen_bloc.dart';
import 'package:expert_connect/src/splashscreen/widgets/splash_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashBloc()..add(InitializeSplash()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state.status == SplashStatus.loaded) {
            SplashWidgets.navigateToHome(context);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SplashWidgets.splashContent(),
        ),
      ),
    );
  }
}
