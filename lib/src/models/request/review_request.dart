class ReviewRequest {
  final int userId;
  final int vendorId;
  final int rating;
  final String review;

  const ReviewRequest({
    required this.rating,
    required this.review,
    required this.userId,
    required this.vendorId,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "vendor_id": vendorId,
      "rating": rating,
      "review": review,
    };
  }
}