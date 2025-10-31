class SubCategory {
  final int id;
  final int categoryId;
  final String subCategoryName;
  final String subCategoryImage;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.subCategoryName,
    required this.subCategoryImage,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      subCategoryName: json['sub_category_name'] as String,
      subCategoryImage: json['sub_cat_logo'] as String,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      "category_id": categoryId,
      'sub_category_name': subCategoryName,
      'sub_cat_logo': subCategoryImage,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
