import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/auth/widgets/login_loading.dart';
import 'package:expert_connect/src/auth/widgets/login_widgets.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state.status == AuthStatus.authenticated) {
          // Success feedback

          Get.offAllNamed(RoutesName.bottom);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome! Login successful.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state.status == AuthStatus.otpVerificationRequired) {
          // Navigate to OTP screen
          Get.offAllNamed(
            RoutesName.otp,
            arguments: {
              'email': state.userModel.email,
              'user': state.userModel,
            },
          );
        }  else if (state.status == AuthStatus.unauthenticated &&
            state.errorMessage != null) {
          // Error feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ),
          );
        } else if (state.status == AuthStatus.waitingForGoogleCallback) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Complete authentication in your browser...'),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 10),
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isGoogleLoading =
              state.status == AuthStatus.gettingGoogleAuthUrl ||
              state.status == AuthStatus.waitingForGoogleCallback;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                FormBuilder(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LoginWidgets.logo(),
                        LoginWidgets.welcomeText(),
                        LoginWidgets.fields(),
                        LoginWidgets.forgetPassword(),

                        // Regular login button
                        CommonWidgets.btn(
                          onPressed: () {
                            if (formKey.currentState?.saveAndValidate() ??
                                false) {
                              final formData = formKey.currentState!.value;
                              context.read<AuthBloc>().add(
                                AuthLoginRequested(
                                  password: formData['Password'],
                                  email: formData['Email Address'],
                                ),
                              );
                            }
                          },
                        ),

                        CommonWidgets.dividerText(),

                        // Enhanced Google login button
                        CommonWidgets.googleBtn(
                          isLoading: isGoogleLoading,
                          onPressed: (state.isLoading || isGoogleLoading)
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    const AuthGoogleLoginRequested(),
                                  );
                                },
                        ),

                        LoginWidgets.toSignUp(),
                      ],
                    ),
                  ),
                ),

                // Loading overlay
                if (state.isLoading && !isGoogleLoading)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: AwesomeLoadingWidget(isLogin: true),
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
