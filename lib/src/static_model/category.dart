class Categorys {
  final String title;
  final String color;
  final int id;
  final String image;

  const Categorys({
    required this.color,
    required this.image,
    required this.id,
    required this.title,
  });

  factory Categorys.fromJson(Map<String, dynamic> json) {
    return Categorys(
      color: json['color'],
      id: json['id'],
      image: json['image'],
      title: json['title'],
    );
  }
}
