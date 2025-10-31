import 'package:expert_connect/src/models/vendors.dart';

enum ArticleVendorListStatus {
  initial,
  loaded,
  loading,
  failed,
  empty,
  success,
}

class ArticleVendorList {
  final int id;
  final int vendorId;
  final String title;
  final String content;
  final Vendor vendor;
  final String highlightedContent;
  final String image;
  final List<String> tags;
  final String status;
  final String updatedAt;

  const ArticleVendorList({
    required this.content,
    required this.vendor,
    required this.id,
    required this.vendorId,
    required this.tags,
    required this.title,
    required this.highlightedContent,
    required this.updatedAt,
    required this.status,
    required this.image,
  });

  factory ArticleVendorList.fromJson(Map<String, dynamic> json) {
    return ArticleVendorList(
      content: json['content'] ?? "no-content",
      id: json['id'] ?? 0,
      vendor: Vendor.initial(),
      vendorId: json['vendor_id'] ?? 0,
      tags: List.from(json['tags']),
      title: json['title'] ?? "title",
      highlightedContent:
          json['highlighted_content'] ?? "no highlighted content",
      updatedAt: json['updated_at'] ?? "no time",
      status: json['status'] ?? "pending",
      image: json['image'] ?? "no-image",
    );
  }

  ArticleVendorList copyWith({
    int? id,
    int? vendorId,
    String? title,
    String? highlightedContent,
    String? image,
    Vendor? vendor,
    List<String>? tags,
    String? status,
    String? updatedAt,
    String? content,
  }) {
    return ArticleVendorList(
      content: content ?? this.content,
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      vendor: vendor ??this.vendor,
      highlightedContent: highlightedContent ?? this.highlightedContent,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      image: image ?? this.image,
    );
  }
}
