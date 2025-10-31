import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/widgets/common_builder/drop_down_builder.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TextFieldBuilder extends StatelessWidget {
  final String name;
  final String initial;
  final String? errorText;
  final List<ValidationType> validationTypes;
  final int? minLength;
  final int? maxLength;
  final int minLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool isHint;
  final String? Function(String?)? customValidator;
  final void Function(String?)? onChanged;
  const TextFieldBuilder({
    super.key,
    required this.name,
    this.errorText,
    this.initial = "",
    this.onChanged,
    this.isHint = true,
    this.minLines = 1,
    this.validationTypes = const [],
    this.minLength,
    this.maxLength,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.customValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        FormBuilderTextField(
          initialValue: initial.isNotEmpty ? initial.capitalize() : null,
          name: name,
          cursorColor: Colors.grey,
          onChanged: onChanged,
          keyboardType: keyboardType ?? _getKeyboardType(),
          obscureText: obscureText,
          minLines: minLines,
          maxLines: minLines > maxLines ? minLines + 1 : maxLines,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8.sp),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
              borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
            ),
            hintText: "${isHint ? "Enter your" : ""} ${name.toLowerCase()}"
                .capitalize(),
            errorText: errorText,
          ),
          validator: _buildValidator(),
        ),
      ],
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

  TextInputType? _getKeyboardType() {
    if (validationTypes.contains(ValidationType.email)) {
      return TextInputType.emailAddress;
    } else if (validationTypes.contains(ValidationType.phone)) {
      return TextInputType.phone;
    } else if (validationTypes.contains(ValidationType.numeric)) {
      return TextInputType.number;
    } else if (validationTypes.contains(ValidationType.url)) {
      return TextInputType.url;
    }
    return null;
  }
}
