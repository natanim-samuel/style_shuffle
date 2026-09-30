import 'favorite_outfit.dart';

class PlannedOutfit {
  final String id;
  final String date;
  final FavoriteOutfit outfit;
  final DateTime createdAt;

  PlannedOutfit({
    required this.id,
    required this.date,
    required this.outfit,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'outfit': outfit.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PlannedOutfit.fromJson(
      Map<String, dynamic> json,
      ) {
    return PlannedOutfit(
      id: json['id'],
      date: json['date'],
      outfit: FavoriteOutfit.fromJson(
        json['outfit'],
      ),
      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }
}