class AppointmentTypeModel {
  final int id;
  final int vendorId;
  final String type;
  final String service;
  final double price;
  final String hsnSacCode;
  final int taxId;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final double tax;

  AppointmentTypeModel({
    required this.id,
    required this.vendorId,
    required this.type,
    required this.price,
    required this.hsnSacCode,
    required this.taxId,
    required this.service,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.tax,
  });

  factory AppointmentTypeModel.fromJson(Map<String, dynamic> json) {
  return AppointmentTypeModel(
    id: json['id'],
    vendorId: json['vendor_id'],
    type: json['type'],
    service: json['service'],
    price: json['price'] is String 
        ? double.parse(json['price']) 
        : json['price'] as double,
    hsnSacCode: json['hsn_sac_code'],
    taxId: json['tax_id'],
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
    deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'])
        : null,
     tax: json['tax'] is String 
          ? double.parse(json['tax']) 
          : (json['tax'] as num).toDouble(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'type': type,
      'price': price,
      'hsn_sac_code': hsnSacCode,
      'tax_id': taxId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'tax': tax,
    };
  }

  AppointmentTypeModel copyWith({
    int? id,
    int? vendorId,
    String? type,
    double? price,
    String? hsnSacCode,
    String? service,
    int? taxId,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    double? tax,
  }) {
    return AppointmentTypeModel(
      id: id ?? this.id,
      service: service ?? this.service,
      vendorId: vendorId ?? this.vendorId,
      type: type ?? this.type,
      price: price ?? this.price,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
      taxId: taxId ?? this.taxId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tax: tax ?? this.tax,
    );
  }
}
