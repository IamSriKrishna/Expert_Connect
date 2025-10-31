import 'package:expert_connect/src/auth/bloc/auth_bloc.dart';
import 'package:expert_connect/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

class AuthHelper {
  static Future<void> submit(
    GlobalKey<FormBuilderState> formKey,
    BuildContext context,
    AuthState state,
    {bool? isTermsAccepted} // Add this parameter to receive checkbox state
  ) async {
    try {
      // First validate the form
      if (formKey.currentState?.saveAndValidate() ?? false) {
        final formData = formKey.currentState!.value;

        // Check if terms and conditions are accepted
        if (!_validateTermsAndConditions(isTermsAccepted, context)) {
          return;
        }

        // Check if all required fields are filled
        if (!_validateRequiredFields(formData, context)) {
          return;
        }

        // Validate email format
        if (!_validateEmail(formData['Email Address'], context)) {
          return;
        }

        // Validate phone number
        if (!_validatePhoneNumber(formData['Phone Number'], context)) {
          return;
        }

        // Validate password match
        if (!_validatePasswordMatch(
          formData['Password'],
          formData['Confirm Password'],
          context,
        )) {
          return;
        }
        final phoneNumber = formData['Phone Number'].replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        final pinCode = int.tryParse(formData['Pincode']) ?? 0;
        // Log form data for debugging
        Logger().d('=== FORM DATA ===');
        formData.forEach((key, value) {
          Logger().d('$key (${key.runtimeType}): $value');
        });
        Logger().d('Country: ${state.selectedCountryId}');
        Logger().d('State: ${state.selectedStateId}');
        Logger().d('City: ${state.selectedCityId}');
        Logger().d('================');

        // Dispatch signup event if all validations pass
        context.read<AuthBloc>().add(
          AuthSignupRequested(
            confirmPassword: formData['Confirm Password'],
            password: formData['Password'],
            name: formData['Name'],
            email: formData['Email Address'],
            pinCode:pinCode,
            phone: phoneNumber,
          ),
        );
      } else {
        Logger().e('Form validation failed');
        Logger().e('Validation errors: ${formKey.currentState?.errors}');
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackbar.loginError(
            "Please fill all required fields correctly",
          ),
        );
      }
    } catch (e) {
      Logger().e("Error in submit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.loginError("An error occurred. Please try again."),
      );
    }
  }

  // Add this new validation method
  static bool _validateTermsAndConditions(
    bool? isTermsAccepted,
    BuildContext context,
  ) {
    if (isTermsAccepted != true) {
      Get.snackbar(
        "Terms & Conditions Required",
        "Please accept the terms and conditions to proceed",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        icon: Icon(Icons.error, color: Colors.white),
      );
      return false;
    }
    return true;
  }

  static bool _validateRequiredFields(
    Map<String, dynamic> formData,
    BuildContext context,
  ) {
    final requiredFields = [
      'Name',
      'Email Address',
      'Password',
      'Confirm Password',
      'Phone Number',
    ];

    for (var field in requiredFields) {
      if (formData[field] == null ||
          formData[field].toString().trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackbar.loginError("$field is required"));
        return false;
      }
    }
    return true;
  }

  static bool _validateEmail(String email, BuildContext context) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
    );
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.loginError("Please enter a valid email address"),
      );
      return false;
    }
    return true;
  }

  static bool _validatePhoneNumber(String phone, BuildContext context) {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Check for exactly 10 digits
    if (cleanedPhone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar.loginError("Phone number must be exactly 10 digits"),
      );

      return false;
    }
    return true;
  }

  static bool _validatePasswordMatch(
    String password,
    String confirmPassword,
    BuildContext context,
  ) {
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CustomSnackbar.loginError("Passwords do not match"));
      return false;
    }
    return true;
  }
}