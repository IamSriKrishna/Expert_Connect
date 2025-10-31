class AreaOfExpertise {
  final int id;
  final int vendorId;
  final String areaOfExpertise;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  AreaOfExpertise({
    required this.id,
    required this.vendorId,
    required this.areaOfExpertise,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory AreaOfExpertise.fromJson(Map<String, dynamic> json) {
    return AreaOfExpertise(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      areaOfExpertise: json['area_of_expertise'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String) 
          : null,
    );
  }
}