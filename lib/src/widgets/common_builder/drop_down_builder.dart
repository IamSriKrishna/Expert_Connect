import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ValidationType {
  required,
  email,
  phone,
  minLength,
  maxLength,
  numeric,
  url,
}

class DropdownFieldBuilder<T> extends StatelessWidget {
  final String name;
  final String? errorText;
  final List<ValidationType> validationTypes;
  final String? Function(T?)? customValidator;
  final void Function(T?)? onChanged;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final String? hintText;
  final bool enabled;

  const DropdownFieldBuilder({
    super.key,
    required this.name,
    required this.items,
    this.errorText,
    this.onChanged,
    this.validationTypes = const [],
    this.customValidator,
    this.initialValue,
    this.hintText,
    this.enabled = true,
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
        FormBuilderDropdown<T>(
          name: name,
          initialValue: initialValue,
          enabled: enabled,
          onChanged: onChanged,
          items: items,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(8.sp),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.sp),
            ),
            hintText: hintText ?? "Select ${name.toLowerCase()}".capitalize(),
            errorText: errorText,
          ),
          validator: _buildValidator(),
        ),
      ],
    );
  }

  String? Function(T?)? _buildValidator() {
    if (validationTypes.isEmpty && customValidator == null) {
      return null;
    }

    List<String? Function(T?)> validators = [];

    for (ValidationType type in validationTypes) {
      switch (type) {
        case ValidationType.required:
          validators.add((value) {
            if (value == null) {
              return 'This field is required';
            }
            return null;
          });
          break;
        default:
          break;
      }
    }

    if (customValidator != null) {
      validators.add(customValidator!);
    }

    return validators.isEmpty
        ? null
        : (T? value) {
            for (var validator in validators) {
              final result = validator(value);
              if (result != null) return result;
            }
            return null;
          };
  }
}

class DropdownOption<T> {
  final T value;
  final String label;
  final Widget? icon;

  const DropdownOption({required this.value, required this.label, this.icon});

  DropdownMenuItem<T> toDropdownMenuItem() {
    return DropdownMenuItem<T>(
      value: value,
      child: Row(
        children: [
          if (icon != null) ...[icon!, SizedBox(width: 8.w)],
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

extension DropdownOptionsExtension<T> on List<DropdownOption<T>> {
  List<DropdownMenuItem<T>> toDropdownMenuItems() {
    return map((option) => option.toDropdownMenuItem()).toList();
  }
}
