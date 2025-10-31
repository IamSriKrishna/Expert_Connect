import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/widgets/common_builder/drop_down_builder.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class PasswordFieldBuilder extends StatelessWidget {
  final String name;
  final String? errorText;
  final List<ValidationType> validationTypes;
  final int? minLength;
  final int? maxLength;
  final String? Function(String?)? customValidator;
  final void Function(String?)? onChanged;

  const PasswordFieldBuilder({
    super.key,
    required this.name,
    this.errorText,
    this.onChanged,
    this.validationTypes = const [],
    this.minLength,
    this.maxLength,
    this.customValidator,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordVisibilityCubit(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5.0.h),
            child: CommonWidgets.text(
              text: name.capitalize(),
              color: Colors.black,
              fontFamily: TextFamily.manrope,
              fontWeight: TextWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          BlocBuilder<PasswordVisibilityCubit, bool>(
            builder: (context, isObscured) {
              return FormBuilderTextField(
                name: name,
                cursorColor: Colors.grey,
                onChanged: onChanged,
                keyboardType: TextInputType.visiblePassword,
                obscureText: isObscured,
                maxLines: 1,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.sp),
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey.shade200,
                    ),
                  ),
                  hintText: "Enter your ${name.toLowerCase()}".capitalize(),
                  errorText: errorText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      context
                          .read<PasswordVisibilityCubit>()
                          .toggleVisibility();
                    },
                  ),
                ),
                validator: _buildValidator(),
              );
            },
          ),
        ],
      ),
    );
  }

  String? Function(String?)? _buildValidator() {
    if (validationTypes.isEmpty && customValidator == null) {
      return null;
    }

    List<String? Function(String?)> validators = [];

    for (ValidationType type in validationTypes) {
      switch (type) {
        case ValidationType.required:
          validators.add(FormBuilderValidators.required());
          break;
        case ValidationType.email:
          validators.add(FormBuilderValidators.email());
          break;
        case ValidationType.phone:
          validators.add(FormBuilderValidators.phoneNumber());
          break;
        case ValidationType.minLength:
          if (minLength != null) {
            validators.add(FormBuilderValidators.minLength(minLength!));
          }
          break;
        case ValidationType.maxLength:
          if (maxLength != null) {
            validators.add(FormBuilderValidators.maxLength(maxLength!));
          }
          break;
        case ValidationType.numeric:
          validators.add(FormBuilderValidators.numeric());
          break;
        case ValidationType.url:
          validators.add(FormBuilderValidators.url());
          break;
      }
    }

    if (customValidator != null) {
      validators.add(customValidator!);
    }

    return validators.isEmpty
        ? null
        : FormBuilderValidators.compose(validators);
  }
}
