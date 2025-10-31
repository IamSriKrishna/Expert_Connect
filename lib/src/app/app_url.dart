class AppUrl {
  //Auth
  static String baseUrl = "https://expertconnect.world/api";
  static String imageUrl = "https://expertconnect.world/";
  static String login = "$baseUrl/user_login";
  static String signUp = "$baseUrl/user_register";
  static String category = "$baseUrl/categories";
  static String subCategory = "$baseUrl/getsubcategorieslist";
  static String verifyEmailOTP = "$baseUrl/verify_email_otp";
  static String updateProfileImage = '$baseUrl/user/update-image';
  static String logout = "$baseUrl/logout";
  static String userProfile = "$baseUrl/user_profile";

  // Google Auth URLs
  static String googleAuthUrl = "$baseUrl/auth/google/url";
  static String googleCallback = "$baseUrl/auth/google/callback";

  //Home Url
  static String listVendors = "$baseUrl/vendor_list";
  static String featuredProfessionalVendors = "$baseUrl/featured_vendors_list";

  //country, city and state
  static String country = "$baseUrl/getcountries";
  static String state = "$baseUrl/statesbycountry";
  static String city = "$baseUrl/citybystates";

  //vendor
  static String vendorId = "$baseUrl/vendor_profile";
  static String topRatedVendors = "$baseUrl/top_rated_vendors";
  static String mostPopularVendors = "$baseUrl/most_popular_vendors";
  static String vendorListBySubCategory = '$baseUrl/vendor_list_by_sub_cat';
  static String vendorAppointmentTypeList =
      '$baseUrl/vendorappointmenttypelist';
  static String vendorAreaOfExpertise = "$baseUrl/vendorareaofexpertise";
  static String categoriesList = '$baseUrl/categorieslist';
  
  //review
  static String submitReview = "$baseUrl/submit_rating";
  static String getReview = "$baseUrl/vendor_ratings";

  //appointment
  static String vendorSlotTiming = "$baseUrl/vendor-available-slots";
  static String bookAppointment = "$baseUrl/book-appointment";
  static String listAppointment = "$baseUrl/user_appointments";

  //category
  static String categories = "$baseUrl/categories";
  static String getSubCategoriesList = "$baseUrl/getsubcategorieslist";

  //article
  static String getArticleVendorList = "$baseUrl/vendor/articles/all";

  //chat
  static String listChat = "$baseUrl/chat-list";

  //wallet
  static String userWalletSummary = "$baseUrl/user_wallet_summary";
  static String userWalletTransaction = "$baseUrl/user_wallet_transactions";
}
