import 'clothing_item.dart';

class FavoriteOutfit {
  final String id;
  final ClothingItem top;
  final ClothingItem bottom;
  final ClothingItem shoes;
  final ClothingItem? outerwear;
  final ClothingItem? accessory;
  final DateTime createdAt;

  FavoriteOutfit({
    required this.id,
    required this.top,
    required this.bottom,
    required this.shoes,
    this.outerwear,
    this.accessory,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'top': top.toJson(),
      'bottom': bottom.toJson(),
      'shoes': shoes.toJson(),
      'outerwear': outerwear?.toJson(),
      'accessory': accessory?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FavoriteOutfit.fromJson(
      Map<String, dynamic> json,
      ) {
    return FavoriteOutfit(
      id: json['id'],
      top: ClothingItem.fromJson(json['top']),
      bottom: ClothingItem.fromJson(json['bottom']),
      shoes: ClothingItem.fromJson(json['shoes']),
      outerwear: json['outerwear'] != null
          ? ClothingItem.fromJson(json['outerwear'])
          : null,
      accessory: json['accessory'] != null
          ? ClothingItem.fromJson(json['accessory'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'],
      ),
    );
  }

  List<ClothingItem> get items {
    return [
      top,
      bottom,
      shoes,
      outerwear,
      accessory,
    ].whereType<ClothingItem>().toList();
  }
}