class BannerDetails {
  final String banner;
  final int vendorId;

  const BannerDetails({
    required this.banner,
    required this.vendorId,
  });

  factory BannerDetails.fromJson(Map<String, dynamic> json) {
    return BannerDetails(
      banner: json['banner'] as String,
      vendorId: json['vendor_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banner': banner,
      'vendor_id': vendorId,
    };
  }

  factory BannerDetails.initial() {
    return const BannerDetails(
      banner: '',
      vendorId: 0,
    );
  }
}

class BannerDetailsResponse {
  final bool success;
  final BannerDetails bannerDetails;

  const BannerDetailsResponse({
    required this.success,
    required this.bannerDetails,
  });

  factory BannerDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BannerDetailsResponse(
      success: json['success'] as bool,
      bannerDetails: BannerDetails.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': bannerDetails.toJson(),
    };
  }

  factory BannerDetailsResponse.initial() {
    return BannerDetailsResponse(
      success: false,
      bannerDetails: BannerDetails.initial(),
    );
  }
}
