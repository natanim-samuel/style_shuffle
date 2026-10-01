import 'favorite_outfit.dart';

class WearHistory {
  final String id;
  final FavoriteOutfit outfit;
  final DateTime wornAt;
  final String? plannedOutfitId;

  WearHistory({
    required this.id,
    required this.outfit,
    required this.wornAt,
    this.plannedOutfitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outfit': outfit.toJson(),
      'wornAt': wornAt.toIso8601String(),
      'plannedOutfitId': plannedOutfitId,
    };
  }

  factory WearHistory.fromJson(
      Map<String, dynamic> json,
      ) {
    return WearHistory(
      id: json['id'],
      outfit: FavoriteOutfit.fromJson(
        json['outfit'],
      ),
      wornAt: DateTime.parse(
        json['wornAt'],
      ),
      plannedOutfitId: json['plannedOutfitId'],
    );
  }
}