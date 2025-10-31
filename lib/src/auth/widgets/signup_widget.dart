import 'package:expert_connect/src/app/app_color.dart';
import 'package:expert_connect/src/app/cubit.dart';
import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/extension/string_extensions.dart';
import 'package:expert_connect/src/widgets/common_builder/drop_down_builder.dart';
import 'package:expert_connect/src/widgets/common_builder/password_builder.dart';
import 'package:expert_connect/src/widgets/common_builder/searchable_dropdown_builder.dart';
import 'package:expert_connect/src/widgets/common_builder/text_field_builder.dart';
import 'package:expert_connect/src/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupWidget {
  static Widget welcomeText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 15.h),
      child: Center(
        child: CommonWidgets.text(
          text: "create your account".capitalize(),
          fontSize: 26.sp,
          color: AppColor.splashColor,
          fontFamily: TextFamily.interRegular,
          fontWeight: TextWeight.semi,
        ),
      ),
    );
  }

  static Widget fields(AuthState state, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: Column(
        children: [
          TextFieldBuilder(
            name: "Name",
            validationTypes: [ValidationType.required],
          ),
          SizedBox(height: 10),
          TextFieldBuilder(
            name: "Email Address",
            validationTypes: [ValidationType.required, ValidationType.email],
          ),
          SizedBox(height: 10),
          TextFieldBuilder(
            name: "Phone Number",
            validationTypes: [ValidationType.required, ValidationType.phone],
          ),
          SizedBox(height: 10),
          SearchableDropdownField<String>(
            name: 'Country',
            validationTypes: [ValidationType.required],
            items: state.country
                .map(
                  (e) => SearchableDropdownOption(
                    value: e.id.toString(),
                    label: e.name,
                    icon: Icon(
                      Icons.flag_outlined,
                      color: Colors.green.shade400,
                      size: 18.sp,
                    ),
                  ),
                )
                .toList(),
            prefixIcon: Icon(
              Icons.public,
              color: Colors.green.shade400,
              size: 20.sp,
            ),
            hintText: "Search and select country",
            emptyMessage: "No countries found",
            onChanged: (value) {
              debugPrint('Selected Country: $value');
              if (value != null) {
                final selectedCountryId = int.tryParse(value);
                if (selectedCountryId != null) {
                  BlocProvider.of<AuthBloc>(
                    context,
                  ).add(StateFetched(selectedCountryId));
                }
              }
            },
          ),
          SizedBox(height: 16.h),

          // State Dropdown with enhanced animation
          if (state.selectedCountryId != null && state.state.isNotEmpty)
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity:
                    (state.selectedCountryId != null && state.state.isNotEmpty)
                    ? 1.0
                    : 0.0,
                child: Column(
                  children: [
                    SearchableDropdownField<String>(
                      name: 'State',
                      validationTypes: [ValidationType.required],
                      items: state.state
                          .map(
                            (e) => SearchableDropdownOption(
                              value: e.id.toString(),
                              label: e.name,
                              icon: Icon(
                                Icons.map_outlined,
                                color: Colors.purple.shade400,
                                size: 18.sp,
                              ),
                            ),
                          )
                          .toList(),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.purple.shade400,
                        size: 20.sp,
                      ),
                      hintText: "Search and select state",
                      emptyMessage: "No states found",
                      onChanged: (value) {
                        debugPrint('Selected State: $value');
                        if (value != null) {
                          final selectedStateId = int.tryParse(value);
                          if (selectedStateId != null) {
                            BlocProvider.of<AuthBloc>(
                              context,
                            ).add(CityFetched(selectedStateId));
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

          // City Dropdown with location pin icons
          if (state.selectedStateId != null && state.city.isNotEmpty)
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity:
                    (state.selectedStateId != null && state.city.isNotEmpty)
                    ? 1.0
                    : 0.0,
                child: Column(
                  children: [
                    SearchableDropdownField<String>(
                      name: 'City',
                      validationTypes: [ValidationType.required],
                      items: state.city
                          .map(
                            (e) => SearchableDropdownOption(
                              value: e.id.toString(),
                              label: e.name,
                              icon: Icon(
                                Icons.location_city_outlined,
                                color: Colors.teal.shade400,
                                size: 18.sp,
                              ),
                            ),
                          )
                          .toList(),
                      prefixIcon: Icon(
                        Icons.place_outlined,
                        color: Colors.teal.shade400,
                        size: 20.sp,
                      ),
                      hintText: "Search and select city",
                      emptyMessage: "No cities found",
                      onChanged: (value) {
                        debugPrint('Selected City: $value');
                        if (value != null) {
                          final selectedCityId = int.tryParse(value);
                          if (selectedCityId != null) {
                            BlocProvider.of<AuthBloc>(
                              context,
                            ).add(UpdateCity(selectedCityId));
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

          TextFieldBuilder(
            name: "Pincode",
            validationTypes: [ValidationType.required, ValidationType.numeric],
          ),
          SizedBox(height: 10),
          PasswordFieldBuilder(
            name: "Password",
            validationTypes: [
              ValidationType.required,
              ValidationType.minLength,
            ],
            minLength: 6,
          ),
          SizedBox(height: 10),
          PasswordFieldBuilder(
            name: "Confirm Password",
            validationTypes: [
              ValidationType.required,
              ValidationType.minLength,
            ],
            minLength: 6,
          ),
        ],
      ),
    );
  }

  static Widget termsAndCondition(bool state) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w, top: 5.h),
      child: Row(
        children: [
          BlocBuilder<SignedInCubit, bool>(
            builder: (context, state) {
              return Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: state,
                onChanged: (value) =>
                    context.read<SignedInCubit>().toggle(value!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(5.sp),
                ),
              );
            },
          ),
          CommonWidgets.text(
            text: "I agree the teams & conditions and privacy & policy",
            fontSize: 12.sp,
          ),
        ],
      ),
    );
  }
  
  static Widget termsAndConditionWithCallback({
    required Function(bool) onChanged,
    bool initialValue = false,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isChecked = initialValue;
        return Padding(
          padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w, top: 5.h),
          child: Row(
            children: [
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                  onChanged(isChecked);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.sp),
                ),
              ),
              Expanded(
                child: CommonWidgets.text(
                  text: "I agree the terms & conditions and privacy & policy",
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
