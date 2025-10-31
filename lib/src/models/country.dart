class Country {
  final int id;
  final String name;
  final String shortCode;
  final String phoneCode;
  final String? createdAt;
  final String? updatedAt;

  const Country({
    required this.id,
    required this.name,
    required this.shortCode,
    required this.phoneCode,
    this.createdAt,
    this.updatedAt,
  });

  factory Country.initial() => const Country(
        id: 0,
        name: '',
        shortCode: '',
        phoneCode: '',
        createdAt: null,
        updatedAt: null,
      );

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        id: json['id'],
        name: json['name'],
        shortCode: json['short_code'],
        phoneCode: json['phone_code'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'short_code': shortCode,
        'phone_code': phoneCode,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  Country copyWith({
    int? id,
    String? name,
    String? shortCode,
    String? phoneCode,
    String? createdAt,
    String? updatedAt,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      shortCode: shortCode ?? this.shortCode,
      phoneCode: phoneCode ?? this.phoneCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
