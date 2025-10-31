import 'package:equatable/equatable.dart';
import 'package:expert_connect/src/auth/repo/auth_repo_manager.dart';
import 'package:expert_connect/src/home/repo/home_repo.dart';
import 'package:expert_connect/src/models/appointment_type_model.dart';
import 'package:expert_connect/src/models/area_of_expertise.dart';
import 'package:expert_connect/src/models/banner_model.dart';
import 'package:expert_connect/src/models/category.dart';
import 'package:expert_connect/src/models/notification_model.dart';
import 'package:expert_connect/src/models/review_model.dart';
import 'package:expert_connect/src/models/sub_category.dart';
import 'package:expert_connect/src/models/vendor_availabe_slot.dart';
import 'package:expert_connect/src/models/vendors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepo _homeRepo;
  final AuthStateManager _authStateManager;

  HomeBloc(final HomeRepo homeRepo, {AuthStateManager? authStateManager})
    : _homeRepo = homeRepo,
      _authStateManager = authStateManager ?? AuthStateManager(),
      super(HomeState.initial()) {
    on<FetchVendorAreasOfExpertise>(_onFetchVendorAreasOfExpertise);
    on<FetchVendors>(fetchVendors);
    on<FetchFeaturedProfessionalVendors>(fetchFeaturedProfessionalVendors);
    on<FetchSubCategories>(_onFetchSubCategories);
    on<FetchTopRatedVendors>(_onFetchTopRatedVendors);
    on<FetchMostPopularVendors>(_onFetchMostPopularVendors);
    on<RefreshHomeData>(refreshHomeData);
    on<FetchVendorByID>(_onfetchVendorById);
    on<FetchUserNotifications>(_onFetchUserNotifications);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<FetchVendorSlotBooking>(_onfetchVendorSlotTiming);
    on<FetchBannerDetails>(_onFetchBannerDetails);
    on<BookAppointment>(_onBookAppointment);
    on<SubmitReview>(_onSubmitReview);
    on<FetchVendorsBySubCategory>(_onFetchVendorsBySubCategory);
    on<GetReview>(_onGetReviews);
    on<SearchVendors>(_onSearchVendors);
    on<UpdatePaymentMethod>(_onUpdatePaymentMethod);
    on<FetchVendorAppointmentType>(_fetchVendorAppointmentType);
    on<FetchCategoriesList>(_onFetchCategoriesList);
  }

  
  Future<void> _onSearchVendors(
    SearchVendors event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(searchStatus: () => HomeStateStatus.loading));

    try {
      final vendors = await _homeRepo.searchVendors(search: event.searchQuery);
      
      if (vendors.isEmpty) {
        emit(
          state.copyWith(
            message: () => "No vendors found for '${event.searchQuery}'",
            searchResults: () => vendors,
            searchStatus: () => HomeStateStatus.empty,
          ),
        );
      } else {
        emit(
          state.copyWith(
            message: () => "Found ${vendors.length} vendor(s) for '${event.searchQuery}'",
            searchResults: () => vendors,
            searchStatus: () => HomeStateStatus.loaded,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error searching vendors: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          searchStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }
  Future<void> _onFetchCategoriesList(
    FetchCategoriesList event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: () => HomeStateStatus.loading));

    try {
      final categories = await _homeRepo.getCategoriesList();
      emit(
        state.copyWith(
          message: () => "Categories list loaded successfully",
          category: () => categories,
          status: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching categories list: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchBannerDetails(
    FetchBannerDetails event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(bannerStatus: () => HomeStateStatus.loading));

    try {
      final bannerDetails = await _homeRepo.getBannerDetails();
      emit(
        state.copyWith(
          bannerDetails: () => bannerDetails,
          bannerStatus: () => HomeStateStatus.loaded,
          message: () => "Banner details loaded successfully",
        ),
      );
    } catch (e) {
      debugPrint('Error fetching banner details: ${e.toString()}');
      emit(
        state.copyWith(
          bannerStatus: () => HomeStateStatus.failed,
          message: () => e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(notificationsStatus: () => HomeStateStatus.loading));

    try {
      final success = await _homeRepo.markAllNotificationsAsRead();

      if (success) {
        // Optionally refresh notifications after marking as read
        add(const FetchUserNotifications());

        emit(
          state.copyWith(
            message: () => "All notifications marked as read",
            notificationsStatus: () => HomeStateStatus.success,
          ),
        );
      } else {
        emit(
          state.copyWith(
            message: () => "Failed to mark notifications as read",
            notificationsStatus: () => HomeStateStatus.failed,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          message: () => e.toString(),
          notificationsStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchUserNotifications(
    FetchUserNotifications event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(notificationsStatus: () => HomeStateStatus.loading));

    try {
      final notifications = await _homeRepo.getUserNotifications();
      emit(
        state.copyWith(
          notifications: () => notifications,
          message: () => "Notifications loaded successfully",
          notificationsStatus: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching notifications: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          notificationsStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchVendorAreasOfExpertise(
    FetchVendorAreasOfExpertise event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: () => HomeStateStatus.loading));

    try {
      final areas = await _homeRepo.getVendorAreasOfExpertise(event.vendorId);
      emit(
        state.copyWith(
          areasOfExpertise: () => areas,
          message: () => "Successfully loaded areas of expertise",
          status: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching areas of expertise: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onGetReviews(GetReview event, Emitter<HomeState> emit) async {
    state.copyWith(status: () => HomeStateStatus.loading);
    try {
      final review = await _homeRepo.getReviews(vendorId: event.vendorId);
      emit(
        state.copyWith(
          reviews: () => review,
          message: () =>
              "Successfully Loaded Review for Vendor: ${event.vendorId}",
          status: () => HomeStateStatus.success,
        ),
      );
    } catch (e) {
      debugPrint('Error Loading Review: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethod event,
    Emitter<HomeState> emit,
  ) async {
    state.copyWith(status: () => HomeStateStatus.loading);
    try {
      Logger().d("Payment Method Updated: ${event.paymentMethod}");
      emit(
        state.copyWith(
          paymentMethod: () => event.paymentMethod,
          status: () => HomeStateStatus.updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _fetchVendorAppointmentType(
    FetchVendorAppointmentType event,
    Emitter<HomeState> emit,
  ) async {
    state.copyWith(status: () => HomeStateStatus.loading);
    try {
      final type = await _homeRepo.fetchListOfAppointemnt(
        vendorId: event.vendorId,
      );
      emit(
        state.copyWith(
          appointmentTypeModel: () => type,
          message: () =>
              "Successfully Loaded Appointment Type For: ${event.vendorId}",
          status: () => HomeStateStatus.success,
        ),
      );
    } catch (e) {
      debugPrint('Error Loading Appointment Type: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: () => HomeStateStatus.loading));

    try {
      final success = await _homeRepo.submitReview(
        vendorId: event.vendorId,
        rating: event.rating,
        review: event.review,
      );

      if (success) {
        emit(
          state.copyWith(
            message: () =>
                "Successfully Submitted Review for Vendor: ${event.vendorId}",
            status: () => HomeStateStatus.success,
          ),
        );

        // Add a small delay to ensure server has processed the review
        await Future.delayed(const Duration(milliseconds: 500));
        add(GetReview(vendorId: event.vendorId));
      } else {
        emit(
          state.copyWith(
            message: () =>
                "Failed To Submit Review for Vendor: ${event.vendorId}",
            status: () => HomeStateStatus.failed,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error Submitting Review: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchVendorsBySubCategory(
    FetchVendorsBySubCategory event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(vendorStatus: () => HomeStateStatus.loading));

    try {
      final vendors = await _homeRepo.getVendorsBySubCategory(
        event.subCategoryId,
      );

      if (vendors.isEmpty || vendors == []) {
        emit(
          state.copyWith(
            message: () => "Vendors by subcategory is Empty",
            vendors: () => vendors,
            vendorStatus: () => HomeStateStatus.empty,
          ),
        );
      } else {
        await Future.delayed(Duration(seconds: 2));

        emit(
          state.copyWith(
            message: () => "Vendors by subcategory loaded successfully",
            vendors: () => vendors,
            vendorStatus: () => HomeStateStatus.loaded,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error fetching vendors by subcategory: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchSubCategories(
    FetchSubCategories event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: () => HomeStateStatus.loading));

    try {
      final subCategories = await _homeRepo.getSubCategories(event.categoryId);
      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => "Subcategories loaded successfully",
          subCategories: () => subCategories,
          status: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching subcategories: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> fetchVendors(FetchVendors event, Emitter<HomeState> emit) async {
    emit(state.copyWith(vendorStatus: () => HomeStateStatus.loading));

    try {
      final vendors = await _homeRepo.listVendors();
      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => "Vendors loaded successfully",
          vendors: () => vendors,
          vendorStatus: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching vendors: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  
  Future<void> fetchFeaturedProfessionalVendors(FetchFeaturedProfessionalVendors event, Emitter<HomeState> emit) async {
    emit(state.copyWith(vendorStatus: () => HomeStateStatus.loading));

    try {
      final vendors = await _homeRepo.featuredProfessionalVendors();
      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => "Vendors loaded successfully",
          featuredVendors: () => vendors,
          vendorStatus: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching vendors: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchTopRatedVendors(
    FetchTopRatedVendors event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(vendorStatus: () => HomeStateStatus.loading));

    try {
      final vendors = await _homeRepo.topRatedVendors();
      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => "Vendors loaded successfully",
          topRatedVendors: () => vendors,
          vendorStatus: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching vendors: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onFetchMostPopularVendors(
    FetchMostPopularVendors event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(vendorStatus: () => HomeStateStatus.loading));

    try {
      final vendors = await _homeRepo.topRatedVendors();
      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => "Vendors loaded successfully",
          mostPopularVendors: () => vendors,
          vendorStatus: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching vendors: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onfetchVendorById(
    FetchVendorByID event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: () => HomeStateStatus.loading));

    try {
      final vendor = await _homeRepo.vendorProfile(event.id);
      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => "Vendors loaded successfully",
          vendor: () => vendor,
          status: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching vendors: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onfetchVendorSlotTiming(
    FetchVendorSlotBooking event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: () => HomeStateStatus.loading));

    try {
      final vendor = await _homeRepo.vendorSlotTiming(
        id: event.id,
        date: event.date,
      );
      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => "Vendors Available Slot loaded successfully",
          vendorAvailabeSlot: () => vendor,
          status: () => HomeStateStatus.success,
        ),
      );
    } catch (e) {
      debugPrint('Error fetching vendors: ${e.toString()}');

      await Future.delayed(Duration(seconds: 2));
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> refreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        status: () => HomeStateStatus.loading,
        vendorStatus: () => HomeStateStatus.loading,
      ),
    );

    try {
      final futures = await Future.wait([
        _homeRepo.getCategory(),
        _homeRepo.listVendors(),
      ]);

      final categories = futures[0] as List<Category>;
      final vendors = futures[1] as List<Vendor>;

      emit(
        state.copyWith(
          message: () => "Data refreshed successfully",
          category: () => categories,
          vendors: () => vendors,
          status: () => HomeStateStatus.loaded,
          vendorStatus: () => HomeStateStatus.loaded,
        ),
      );
    } catch (e) {
      debugPrint('Error refreshing home data: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }

  Future<void> _onBookAppointment(
    BookAppointment event,
    Emitter<HomeState> emit,
  ) async {
    if (!_authStateManager.isLoggedIn || _authStateManager.user?.id == null) {
      Logger().w("User not logged in or user ID is null");
      emit(state.copyWith(status: () => HomeStateStatus.failed));
      return;
    }

    final userId = _authStateManager.user!.id;
    final userEmail = _authStateManager.user!.email;

    Logger().i("Fetching appointments for user ID: $userId");
    Logger().i("Fetching appointments for user Email: $userEmail");

    state.copyWith(status: () => HomeStateStatus.loading);
    try {
      final success = await _homeRepo.bookVendorAppointment(
        vendorId: event.vendorId,
        userId: userId,
        paymentMethod: state.paymentMethod,
        appointmentDate: event.appointmentDate,
        appointmentTime: event.appointmentTime,
        description: event.description,
        price: event.price,
        tax: event.tax,
        type: event.type,
        userEmail: userEmail,
        razorpayPaymentId: event.razorpayPaymentId,
      );

      if (success) {
        emit(
          state.copyWith(
            message: () =>
                "Successfully booked appointment for User: $userEmail",
            status: () => HomeStateStatus.success,
          ),
        );
      } else {
        emit(
          state.copyWith(
            message: () => "Failed To book Appointment for User: $userEmail",
            status: () => HomeStateStatus.failed,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error refreshing home data: ${e.toString()}');
      emit(
        state.copyWith(
          message: () => e.toString(),
          status: () => HomeStateStatus.failed,
          vendorStatus: () => HomeStateStatus.failed,
        ),
      );
    }
  }
}
