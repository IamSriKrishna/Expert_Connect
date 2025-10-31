import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:expert_connect/src/app/app_url.dart';
import 'package:expert_connect/src/app/routes_name.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/models/appointment_type_model.dart';
import 'package:expert_connect/src/models/area_of_expertise.dart';
import 'package:expert_connect/src/models/banner_model.dart';
import 'package:expert_connect/src/models/category.dart';
import 'package:expert_connect/src/models/notification_model.dart';
import 'package:expert_connect/src/models/request/appointment_request.dart';
import 'package:expert_connect/src/models/request/review_request.dart';
import 'package:expert_connect/src/models/request/vendor_booking.dart';
import 'package:expert_connect/src/models/review_model.dart';
import 'package:expert_connect/src/models/sub_category.dart';
import 'package:expert_connect/src/models/vendor_availabe_slot.dart';
import 'package:expert_connect/src/models/vendors.dart';
import 'package:expert_connect/src/static_model/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' show Get, GetNavigation;
import 'package:logger/logger.dart';

class HomeException implements Exception {
  final String message;
  final String? code;

  const HomeException(this.message, {this.code});

  @override
  String toString() => message;
}

class VendorResponse {
  final bool success;
  final List<Vendor> vendorDetails;

  const VendorResponse({required this.success, required this.vendorDetails});

  factory VendorResponse.fromJson(Map<String, dynamic> json) {
    return VendorResponse(
      success: json['success'] as bool,
      vendorDetails: (json['vendor_details'] as List<dynamic>)
          .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

abstract class HomeRepo {
  Future<List<Categorys>> getCategory();
  Future<List<Vendor>> listVendors();
  Future<List<Vendor>> featuredProfessionalVendors();
  Future<List<Vendor>> mostPopularVendors();
  Future<List<Vendor>> topRatedVendors();
  Future<bool> markAllNotificationsAsRead();
  Future<List<Category>> getCategories();
  Future<Vendor> vendorProfile(int id);
  Future<List<Vendor>> getVendorsBySubCategory(int subCategoryId);
  Future<List<SubCategory>> getSubCategories(int categoryId);
  Future<List<ReviewModel>> getReviews({required int vendorId});
  Future<VendorAvailabeSlot> vendorSlotTiming({
    required int id,
    required String date,
  });
  Future<bool> submitReview({
    required int vendorId,
    required int rating,
    required String review,
  });
  Future<List<Category>> getCategoriesList();
  Future<List<NotificationModel>> getUserNotifications();
  Future<List<AreaOfExpertise>> getVendorAreasOfExpertise(int vendorId);
  Future<bool> bookVendorAppointment({
    required int vendorId,
    required int userId,
    required int type,
    required double price,
    required double tax,
    required String paymentMethod,
    required String appointmentDate,
    required String description,
    required String appointmentTime,
    required String userEmail,
    required String razorpayPaymentId,
  });

  Future<List<Vendor>> searchVendors({required String search});
  Future<BannerDetailsResponse> getBannerDetails();
  Future<List<AppointmentTypeModel>> fetchListOfAppointemnt({
    required int vendorId,
  });
}

class HomeRepoImpl implements HomeRepo {
  final Dio _dio;
  final Logger _logger = Logger();
  final AuthStateManager authStateManager = AuthStateManager();
  HomeRepoImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options.baseUrl = AppUrl.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.uri}');
          _logger.d('Token ${authStateManager.token}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _logger.w('Unauthorized access detected, clearing auth data');
            authStateManager.clearAuthData();
            Get.offAndToNamed(RoutesName.splash);
          }
          _logger.e('HTTP Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<List<Vendor>> searchVendors({required String search}) async {
    try {
      final Response response = await _dio.post(
        '${AppUrl.baseUrl}/search-vendors',
        data: {"search": search},
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _logger.d('Successfully searched vendors: ${response.data}');

        List<dynamic> data = response.data['data'];
        List<Vendor> vendors = data.map((e) => Vendor.fromJson(e)).toList();

        return vendors;
      }

      _logger.e('Failed to search vendors: ${response.data}');
      throw HomeException(
        "Failed to search vendors: ${response.data['message'] ?? 'Unknown error'}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error searching vendors: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error searching vendors: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to search vendors: ${e.toString()}');
    }
  }

  @override
  Future<List<Category>> getCategoriesList() async {
    try {
      final Response response = await _dio.get(
        AppUrl.categoriesList,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == "true") {
        _logger.d('Successfully loaded categories list: ${response.data}');

        List<dynamic> data = response.data['indexdata'];
        List<Category> categories = data
            .map((e) => Category.fromJson(e))
            .toList();

        return categories;
      }

      _logger.e('Failed to load categories list: ${response.data}');
      throw HomeException(
        "Failed to load categories list: ${response.data['message'] ?? 'Unknown error'}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading categories list: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading categories list: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load categories list: ${e.toString()}');
    }
  }

  @override
  Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.baseUrl}/user-notifications/${authStateManager.user?.id}',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _logger.d('Successfully loaded user notifications: ${response.data}');

        List<dynamic> data = response.data['notifications'];
        List<NotificationModel> notifications = data
            .map((e) => NotificationModel.fromJson(e))
            .toList();

        return notifications;
      }

      _logger.e('Failed to load user notifications: ${response.data}');
      throw HomeException(
        "Failed to load user notifications: ${response.data['message'] ?? 'Unknown error'}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading user notifications: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading user notifications: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load user notifications: ${e.toString()}');
    }
  }

  @override
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final Response response = await _dio.post(
        '${AppUrl.baseUrl}/notifications/read-all/${authStateManager.user?.id}',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _logger.d('Successfully marked all notifications as read');
        return true;
      }

      _logger.e('Failed to mark notifications as read: ${response.data}');
      return false;
    } on DioException catch (e) {
      _logger.e('Dio error marking notifications as read: ${e.message}');
      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error marking notifications as read: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to mark notifications as read');
    }
  }

  @override
  Future<BannerDetailsResponse> getBannerDetails() async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.baseUrl}/banner-details',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _logger.d('Successfully loaded banner details: ${response.data}');
        return BannerDetailsResponse.fromJson(response.data);
      }

      _logger.e('Failed to load banner details: ${response.data}');
      throw HomeException(
        "Failed to load banner details: ${response.data['message'] ?? 'Unknown error'}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading banner details: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading banner details: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load banner details: ${e.toString()}');
    }
  }

  @override
  Future<List<AreaOfExpertise>> getVendorAreasOfExpertise(int vendorId) async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.vendorAreaOfExpertise}/$vendorId',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        _logger.d('Successfully loaded areas of expertise: ${response.data}');

        List<dynamic> data = response.data['area_of_expertise'];
        List<AreaOfExpertise> areas = data
            .map((e) => AreaOfExpertise.fromJson(e))
            .toList();

        return areas;
      }

      _logger.e('Failed to load areas of expertise: ${response.data}');
      throw HomeException(
        "Failed to load areas of expertise: ${response.data['message'] ?? 'Unknown error'}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading areas of expertise: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading areas of expertise: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load areas of expertise: ${e.toString()}');
    }
  }

  @override
  Future<List<AppointmentTypeModel>> fetchListOfAppointemnt({
    required int vendorId,
  }) async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.vendorAppointmentTypeList}/$vendorId',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.data["success"] == "true") {
        _logger.d('Successfully loaded Type Of Appointment: ${response.data}');
        List<dynamic> data = response.data['indexdata'];
        List<AppointmentTypeModel> vendors = data
            .map((e) => AppointmentTypeModel.fromJson(e))
            .toList();
        return vendors;
      }
      _logger.e('Failed to load  Type Of Appointment: ${response.data}');
      throw HomeException(
        "Failed to load  Type Of Appointment: ${response.data}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading  Type Of Appointment: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading  Type Of Appointment: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException(
        'Failed to load  Type Of Appointment: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ReviewModel>> getReviews({required int vendorId}) async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.getReview}/$vendorId',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Successfully loaded Review: ${response.data}');
        List<dynamic> data = response.data['ratings'];
        List<ReviewModel> vendors = data
            .map((e) => ReviewModel.fromJson(e))
            .toList();
        return vendors;
      }
      _logger.e('Failed to load Review: ${response.data}');
      throw HomeException("Failed to load Review: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error loading Review: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading Review: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load Review: ${e.toString()}');
    }
  }

  @override
  Future<bool> submitReview({
    required int vendorId,
    required int rating,
    required String review,
  }) async {
    final ReviewRequest requestBody = ReviewRequest(
      rating: rating,
      review: review,
      userId: authStateManager.user!.id,
      vendorId: vendorId,
    );
    try {
      final Response response = await _dio.post(
        AppUrl.submitReview,
        data: requestBody.toJson(),
        options: Options(
          headers: {"Authorization": "Bearer ${authStateManager.token}"},
        ),
      );
      if (response.data['message'] == "Rating submitted successfully") {
        _logger.d("Successfully Submited Review:\n${response.data}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      _logger.e('Dio error Failed to Submit Review: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      if (e.response?.statusCode == 422) {
        throw HomeException('Invalid request data. Please check your input.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error Failed to Book Appointment: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to Submit Review: ${e.toString()}');
    }
  }

  @override
  Future<List<Vendor>> getVendorsBySubCategory(int subCategoryId) async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.vendorListBySubCategory}/$subCategoryId',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data['success'] == true) {
        _logger.d(
          'Successfully loaded vendors by subcategory: ${response.data}',
        );

        List<dynamic> data = response.data['vendor_details'];
        List<Vendor> vendors = data.map((e) => Vendor.fromJson(e)).toList();

        return vendors;
      }
      _logger.e('Failed to load vendors by subcategory: ${response.data}');
      throw HomeException(
        "Failed to load vendors by subcategory: ${response.data}",
      );
    } on DioException catch (e) {
      _logger.e('Dio error loading vendors by subcategory: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading vendors by subcategory: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException(
        'Failed to load vendors by subcategory: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final Response response = await _dio.get(
        AppUrl.categories,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data['success'] == true) {
        _logger.d('Successfully loaded categories: ${response.data}');

        List<dynamic> data = response.data['indexdata'];
        List<Category> categories = data
            .map((e) => Category.fromJson(e))
            .toList();

        return categories;
      }
      _logger.e('Failed to load categories: ${response.data}');
      throw HomeException("Failed to load categories: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error loading categories: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading categories: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load categories: ${e.toString()}');
    }
  }

  @override
  Future<List<SubCategory>> getSubCategories(int categoryId) async {
    try {
      final Response response = await _dio.get(
        '${AppUrl.getSubCategoriesList}/$categoryId',
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data['success'] == "true") {
        _logger.d('Successfully loaded subcategories: ${response.data}');

        List<dynamic> data = response.data['indexdata'];
        List<SubCategory> subCategories = data
            .map((e) => SubCategory.fromJson(e))
            .toList();

        return subCategories;
      }
      _logger.e('Failed to load subcategories: ${response.data}');
      throw HomeException("Failed to load subcategories: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error loading subcategories: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading subcategories: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load subcategories: ${e.toString()}');
    }
  }

  @override
  Future<List<Vendor>> mostPopularVendors() async {
    try {
      final Response response = await _dio.get(
        AppUrl.mostPopularVendors,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.data['success'] == true) {
        _logger.d('Successfully Loaded Most Popular Vendors: ${response.data}');

        List<dynamic> data = response.data['data'];
        List<Vendor> vendors = data.map((e) => Vendor.fromJson(e)).toList();

        return vendors;
      }
      _logger.e('Failed to Load Most Popular Vendors: ${response.data}');
      throw Exception("Failed to Load Most Popular Vendors: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error Failed to Load Most Popular Vendors: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      if (e.response?.statusCode == 422) {
        throw HomeException('Invalid request data. Please check your input.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error Failed to Load Most Popular Vendors: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to Most Popular Vendors: ${e.toString()}');
    }
  }

  @override
  Future<List<Vendor>> topRatedVendors() async {
    try {
      final Response response = await _dio.get(
        AppUrl.topRatedVendors,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Content-Type": "application/json",
          },
        ),
      );
      if (response.data['success'] == true) {
        _logger.d('Successfully Loaded Top Rated Vendors: ${response.data}');

        List<dynamic> data = response.data['data'];
        List<Vendor> vendors = data.map((e) => Vendor.fromJson(e)).toList();

        return vendors;
      }
      _logger.e('Failed to Load Top Rated Vendors: ${response.data}');

      throw Exception("Failed to Load Top Rated Vendors: ${response.data}");
    } on DioException catch (e) {
      _logger.e('Dio error Failed to Load Top Rated Vendors: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      if (e.response?.statusCode == 422) {
        throw HomeException('Invalid request data. Please check your input.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error Failed to Load Top Rated Vendors: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load Top rated Vendors: ${e.toString()}');
    }
  }

  @override
  Future<bool> bookVendorAppointment({
    required int vendorId,
    required int userId,
    required int type,
    required double price,
    required double tax,
    required String paymentMethod,
    required String appointmentDate,
    required String description,
    required String appointmentTime,
    required String userEmail,
    required String razorpayPaymentId,
  }) async {
    final AppointmentRequest requestBody = AppointmentRequest(
      vendorId: vendorId,
      userId: userId,
      appointmentDate: appointmentDate,
      paymentMethod: paymentMethod,
      appointmentTime: appointmentTime,
      type: type,
      price: price,
      tax: tax,
      description: description,
      userEmail: userEmail,
      razorpayPaymentId: razorpayPaymentId,
    );
    try {
      final Response response = await _dio.post(
        AppUrl.bookAppointment,
        data: requestBody.toJson(),
        options: Options(
          headers: {"Authorization": "Bearer ${authStateManager.token}"},
        ),
      );
      if (response.data['success'] == true) {
        _logger.d(
          "Successfully Booked Appointment:\n${response.data['available_slots']}",
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      _logger.e('Dio error Failed to Book Appointment: ${e.message}');

      if (e.response != null) {
        _logger.e("Response:${requestBody.toJson()}");
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      if (e.response?.statusCode == 422) {
        throw HomeException('Invalid request data. Please check your input.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error Failed to Book Appointment: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to Book vendor appointment: ${e.toString()}');
    }
  }

  @override
  Future<VendorAvailabeSlot> vendorSlotTiming({
    required int id,
    required String date,
  }) async {
    final requestBody = VendorSlotTiming(id: id, date: date);
    try {
      final Response response = await _dio.post(
        AppUrl.vendorSlotTiming,
        data: requestBody.toJson(),
        options: Options(
          headers: {"Authorization": "Bearer ${authStateManager.token}"},
        ),
      );
      if (response.data['success'] == true) {
        _logger.d(
          "Successfully fetched Slot Timing:\n${response.data['available_slots']}",
        );

        final VendorAvailabeSlot vendorAvailabeSlot =
            VendorAvailabeSlot.fromJson(response.data);
        return vendorAvailabeSlot;
      }
      _logger.e(
        'Unexpected error Failed to Book Appointment: ${response.data}',
      );

      throw HomeException(
        'Unexpected error Failed to Book Appointment: ${response.data}',
      );
    } on DioException catch (e) {
      _logger.e('Dio error Failed to Book Appointment: ${e.message}');

      if (e.response != null) {
        _logger.e('Server response: ${e.response?.data}');
        _logger.e('Status code: ${e.response?.statusCode}');
      }

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      if (e.response?.statusCode == 422) {
        throw HomeException('Invalid request data. Please check your input.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error Failed to Book Appointment: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException(
        'Failed to load vendors slot timing: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Categorys>> getCategory() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/category.json',
      );
      final List<dynamic> data = jsonDecode(response);
      final List<Categorys> category = data
          .map((e) => Categorys.fromJson(e))
          .toList();
      debugPrint(category.map((e) => e.title).toString());
      return category;
    } catch (e) {
      _logger.e('Error loading categories: $e');
      throw HomeException('Failed to load categories: ${e.toString()}');
    }
  }

  @override
  Future<List<Vendor>> listVendors() async {
    try {
      final response = await _dio.get(
        AppUrl.listVendors,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Response Content-Type: ${response.headers['content-type']}');
        _logger.d('Raw response data type: ${response.data.runtimeType}');

        if (response.data is String) {
          final String responseString = response.data as String;
          if (responseString.trim().startsWith('<!doctype html>') ||
              responseString.trim().startsWith('<html')) {
            _logger.e(
              'Received HTML response instead of JSON - likely authentication issue',
            );
            throw HomeException(
              'Authentication failed. Please check your credentials and try again.',
            );
          }

          try {
            final Map<String, dynamic> responseMap = jsonDecode(responseString);
            return _processVendorResponse(responseMap);
          } catch (e) {
            throw HomeException('Invalid JSON response format');
          }
        }

        if (response.data is! Map<String, dynamic>) {
          throw HomeException(
            'Invalid response format: expected Map but got ${response.data.runtimeType}',
          );
        }

        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return _processVendorResponse(responseMap);
      } else {
        throw HomeException(
          'Failed to load vendors: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Dio error loading vendors: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading vendors: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load vendors: ${e.toString()}');
    }
  }

  @override
  Future<List<Vendor>> featuredProfessionalVendors() async {
    try {
      final response = await _dio.get(
        AppUrl.featuredProfessionalVendors,
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.d('Response Content-Type: ${response.headers['content-type']}');
        _logger.d('Raw response data type: ${response.data.runtimeType}');

        if (response.data is String) {
          final String responseString = response.data as String;
          if (responseString.trim().startsWith('<!doctype html>') ||
              responseString.trim().startsWith('<html')) {
            _logger.e(
              'Received HTML response instead of JSON - likely authentication issue',
            );
            throw HomeException(
              'Authentication failed. Please check your credentials and try again.',
            );
          }

          try {
            final Map<String, dynamic> responseMap = jsonDecode(responseString);
            return _processVendorResponse(responseMap);
          } catch (e) {
            throw HomeException('Invalid JSON response format');
          }
        }

        if (response.data is! Map<String, dynamic>) {
          throw HomeException(
            'Invalid response format: expected Map but got ${response.data.runtimeType}',
          );
        }

        final Map<String, dynamic> responseMap =
            response.data as Map<String, dynamic>;
        return _processVendorResponse(responseMap);
      } else {
        throw HomeException(
          'Failed to load vendors: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _logger.e('Dio error loading vendors: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw HomeException('Authentication failed. Please login again.');
      }

      throw HomeException(_getErrorMessage(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected error loading vendors: $e');
      _logger.e('Stack trace: $stackTrace');
      throw HomeException('Failed to load vendors: ${e.toString()}');
    }
  }

  @override
  Future<Vendor> vendorProfile(int id) async {
    try {
      final Response res = await _dio.get(
        "${AppUrl.vendorId}/$id",
        options: Options(
          headers: {
            "Authorization": "Bearer ${authStateManager.token}",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      Logger().d('API Response Status: ${res.statusCode}');
      Logger().d('API Response Data: ${res.data}');

      if (res.statusCode == 200 && res.data != null) {
        if (res.data is Map<String, dynamic>) {
          final responseData = res.data as Map<String, dynamic>;

          if (responseData['success'] == true) {
            if (responseData.containsKey('vendor_details') &&
                responseData['vendor_details'] != null) {
              final vendorData = responseData['vendor_details'];
              Logger().d('Vendor Data: $vendorData');

              if (vendorData is Map<String, dynamic>) {
                try {
                  Vendor vendor = Vendor.fromJson(vendorData);
                  Logger().d('Successfully parsed vendor: ${vendor.name}');
                  return vendor;
                } catch (parseError) {
                  Logger().d('Error parsing vendor data: $parseError');
                  Logger().d('Vendor data that failed to parse: $vendorData');
                  throw HomeException(
                    'Failed to parse vendor data: $parseError',
                  );
                }
              } else {
                throw HomeException(
                  'vendor_details is not a valid object: ${vendorData.runtimeType}',
                );
              }
            } else {
              throw HomeException('vendor_details not found in response');
            }
          } else {
            final errorMessage =
                responseData['message'] ?? 'API returned success: false';
            throw HomeException('API Error: $errorMessage');
          }
        } else {
          throw HomeException(
            'Invalid response format: expected Map but got ${res.data.runtimeType}',
          );
        }
      } else {
        throw HomeException(
          'HTTP Error: ${res.statusCode} - ${res.statusMessage}',
        );
      }
    } on DioException catch (dioError) {
      Logger().e('Dio Error: ${dioError.message}');
      Logger().e('Dio Error Type: ${dioError.type}');
      Logger().e('Dio Error Response: ${dioError.response?.data}');

      if (dioError.response != null) {
        throw HomeException(
          'Network Error: ${dioError.response!.statusCode} - ${dioError.message}',
        );
      } else {
        throw HomeException('Network Error: ${dioError.message}');
      }
    } catch (e) {
      Logger().e('Unexpected error in vendorProfile: $e');
      if (e is HomeException) {
        rethrow;
      }
      throw HomeException('Failed to load vendor profile: $e');
    }
  }

  List<Vendor> _processVendorResponse(Map<String, dynamic> responseMap) {
    if (!responseMap.containsKey('vendor_details')) {
      throw HomeException('Response missing vendor_details field');
    }

    final dynamic vendorDetailsRaw = responseMap['vendor_details'];
    if (vendorDetailsRaw is! List) {
      throw HomeException(
        'vendor_details is not a List: ${vendorDetailsRaw.runtimeType}',
      );
    }

    final List<dynamic> vendorDetailsList = vendorDetailsRaw;
    _logger.d('Found ${vendorDetailsList.length} vendor records');

    final List<Vendor> vendors = [];

    for (int i = 0; i < vendorDetailsList.length; i++) {
      try {
        final dynamic vendorData = vendorDetailsList[i];
        _logger.d('Processing vendor $i: ${vendorData.runtimeType}');

        if (vendorData is! Map<String, dynamic>) {
          _logger.w(
            'Vendor at index $i is not a Map: ${vendorData.runtimeType}',
          );
          continue;
        }

        final vendor = Vendor.fromJson(vendorData);
        vendors.add(vendor);
        _logger.d('Successfully parsed vendor: ${vendor.name}');
      } catch (e, stackTrace) {
        _logger.e('Failed to parse vendor at index $i: $e');
        _logger.e('Vendor data: ${vendorDetailsList[i]}');
        _logger.e('Stack trace: $stackTrace');
      }
    }

    if (responseMap['success'] == true) {
      _logger.i('Successfully loaded ${vendors.length} vendors');
      return vendors;
    } else {
      throw HomeException('API returned success: false');
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Try to extract meaningful error message from response
        String? serverMessage;
        if (responseData is Map<String, dynamic>) {
          serverMessage =
              responseData['message'] ??
              responseData['error'] ??
              responseData['errors']?.toString();
        }

        switch (statusCode) {
          case 400:
            return serverMessage ??
                'Bad request. Please check your input data.';
          case 401:
            return 'Authentication failed. Please login again.';
          case 403:
            return 'Access denied. You don\'t have permission to perform this action.';
          case 404:
            return 'Resource not found. The requested item may have been deleted.';
          case 409:
            return serverMessage ??
                'Conflict occurred. The resource already exists or is being used.';
          case 422:
            return _handleValidationErrors(responseData) ??
                'Validation failed. Please check your input and try again.';
          case 429:
            return 'Too many requests. Please wait a moment and try again.';
          case 500:
            return 'Internal server error. Please try again later.';
          case 502:
            return 'Bad gateway. Server is temporarily unavailable.';
          case 503:
            return 'Service unavailable. Please try again later.';
          case 504:
            return 'Gateway timeout. Please try again.';
          default:
            return serverMessage ?? 'Request failed. Please try again.';
        }

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';

      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Helper method to handle validation errors (422 status code)
  String? _handleValidationErrors(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Laravel-style validation errors
      if (responseData.containsKey('errors') && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];

        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.map((msg) => msg.toString()));
          } else {
            errorMessages.add(messages.toString());
          }
        });

        if (errorMessages.isNotEmpty) {
          return errorMessages.first; // Return first validation error
        }
      }

      // Simple message field
      if (responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
    }

    return null;
  }
}
