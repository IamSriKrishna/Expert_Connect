import 'package:expert_connect/src/app/app_json_helper.dart';

class ReviewModel {
  final int ratingId;
  final int rating;
  final String review;
  final int userId;
  final int vendorId;
  final DateTime createdAt;
  final String userName;
  final String userEmail;
  final String vendorName;
  final String vendorEmail;

  ReviewModel({
    required this.ratingId,
    required this.rating,
    required this.review,
    required this.userId,
    required this.vendorId,
    required this.createdAt,
    required this.userName,
    required this.userEmail,
    required this.vendorName,
    required this.vendorEmail,
  });

factory ReviewModel.fromJson(Map<String, dynamic> json) {
  return ReviewModel(
    ratingId: JsonHelper.parseInt(json['rating_id']),
    rating: JsonHelper.parseInt(json['rating']),
    review: json['review'] ?? '',
    userId: JsonHelper.parseInt(json['user_id']),
    vendorId: JsonHelper.parseInt(json['vendor_id']),
    createdAt: DateTime.parse(json['created_at']),
    userName: json['user_name'] ?? '',
    userEmail: json['user_email'] ?? '',
    vendorName: json['vendor_name'] ?? '',
    vendorEmail: json['vendor_email'] ?? '',
  );
}

  Map<String, dynamic> toJson() {
    return {
      'rating_id': ratingId,
      'rating': rating,
      'review': review,
      'user_id': userId,
      'vendor_id': vendorId,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'user_email': userEmail,
      'vendor_name': vendorName,
      'vendor_email': vendorEmail,
    };
  }
}
