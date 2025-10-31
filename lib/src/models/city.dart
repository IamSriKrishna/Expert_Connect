class City {
  final int id;
  final String name;
  final int stateId;
  final String? createdAt;
  final String? updatedAt;

  const City({
    required this.id,
    required this.name,
    required this.stateId,
    this.createdAt,
    this.updatedAt,
  });

  factory City.initial() => const City(
        id: 0,
        name: '',
        stateId: 0,
        createdAt: null,
        updatedAt: null,
      );

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'],
        name: json['name'],
        stateId: json['state_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state_id': stateId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  City copyWith({
    int? id,
    String? name,
    int? stateId,
    String? createdAt,
    String? updatedAt,
  }) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      stateId: stateId ?? this.stateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
