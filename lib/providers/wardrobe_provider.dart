import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clothing_item.dart';

class WardrobeProvider extends ChangeNotifier {
  static const String _storageKey = 'wardrobe_items';

  List<ClothingItem> _items = [];

  List<ClothingItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  Future<void> loadItems() async {
    final preferences = await SharedPreferences.getInstance();

    final savedItems = preferences.getStringList(_storageKey);

    if (savedItems == null) {
      _items = [];
      notifyListeners();
      return;
    }

    _items = savedItems.map((item) {
      return ClothingItem.fromJson(
        jsonDecode(item),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> addItem(ClothingItem item) async {
    _items.add(item);

    await _saveItems();

    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);

    await _saveItems();

    notifyListeners();
  }

  List<ClothingItem> getByCategory(String category) {
    if (category == 'All') {
      return items;
    }

    return _items
        .where((item) => item.category == category)
        .toList();
  }

  Future<void> _saveItems() async {
    final preferences = await SharedPreferences.getInstance();

    final encodedItems = _items.map((item) {
      return jsonEncode(item.toJson());
    }).toList();

    await preferences.setStringList(
      _storageKey,
      encodedItems,
    );
  }
}