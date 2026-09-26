import 'clothing_item.dart';

class Outfit {
  final String id;

  final ClothingItem? top;
  final ClothingItem? bottom;
  final ClothingItem? shoes;
  final ClothingItem? outerwear;
  final ClothingItem? accessory;

  final DateTime createdAt;

  Outfit({
    required this.id,
    this.top,
    this.bottom,
    this.shoes,
    this.outerwear,
    this.accessory,
    required this.createdAt,
  });

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