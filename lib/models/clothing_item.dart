class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String style;
  final String season;
  final String? imagePath;
  final DateTime createdAt;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.style,
    required this.season,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'color': color,
      'style': style,
      'season': season,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      color: json['color'],
      style: json['style'],
      season: json['season'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}