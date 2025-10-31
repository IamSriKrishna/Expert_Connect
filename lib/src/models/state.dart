class State {
  final int id;
  final String name;
  final int countryId;
  final String? createdAt;
  final String? updatedAt;

  const State({
    required this.id,
    required this.name,
    required this.countryId,
    this.createdAt,
    this.updatedAt,
  });

  factory State.initial() => const State(
        id: 0,
        name: '',
        countryId: 0,
        createdAt: null,
        updatedAt: null,
      );

  factory State.fromJson(Map<String, dynamic> json) => State(
        id: json['id'],
        name: json['name'],
        countryId: json['country_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country_id': countryId,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  State copyWith({
    int? id,
    String? name,
    int? countryId,
    String? createdAt,
    String? updatedAt,
  }) {
    return State(
      id: id ?? this.id,
      name: name ?? this.name,
      countryId: countryId ?? this.countryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
