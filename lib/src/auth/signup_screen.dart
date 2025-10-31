import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/auth/widgets/login_loading.dart';
import 'package:expert_connect/src/auth/widgets/login_widgets.dart';
import 'package:expert_connect/src/auth/widgets/signup_widget.dart';
import 'package:expert_connect/src/helper/auth_helper.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignedInCubit(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.registrationComplete) {
            Get.offAllNamed(
              RoutesName.otp,
              arguments: {
                'email': formKey.currentState!.value['Email Address'],
              },
            );
          } else if (state.status == AuthStatus.unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return BlocBuilder<SignedInCubit, bool>(
              builder: (context, cubit) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: FormBuilder(
                          key: formKey,
                          child: Column(
                            children: [
                              LoginWidgets.logo(),
                              SignupWidget.welcomeText(),
                              SignupWidget.fields(state, context),
                              SignupWidget.termsAndCondition(cubit),
                              CommonWidgets.btn(
                                onPressed: () => AuthHelper.submit(
                                  formKey,
                                  context,
                                  state,
                                  isTermsAccepted:
                                      cubit, // Pass the checkbox state
                                ),
                                text: "register",
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.isLoading)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black.withOpacity(0.7),
                          child: const Center(
                            child: AwesomeLoadingWidget(isLogin: false),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
