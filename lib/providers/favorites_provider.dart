import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_outfit.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_outfits';

  List<FavoriteOutfit> _favorites = [];

  List<FavoriteOutfit> get favorites =>
      List.unmodifiable(_favorites);

  int get count => _favorites.length;

  Future<void> loadFavorites() async {
    final preferences =
    await SharedPreferences.getInstance();

    final savedFavorites =
    preferences.getStringList(_storageKey);

    if (savedFavorites == null) {
      _favorites = [];
      notifyListeners();
      return;
    }

    _favorites = savedFavorites.map((item) {
      return FavoriteOutfit.fromJson(
        jsonDecode(item),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> addFavorite(
      FavoriteOutfit outfit,
      ) async {
    _favorites.insert(0, outfit);

    await _saveFavorites();

    notifyListeners();
  }

  Future<void> removeFavorite(
      String id,
      ) async {
    _favorites.removeWhere(
          (outfit) => outfit.id == id,
    );

    await _saveFavorites();

    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favorites.any(
          (outfit) => outfit.id == id,
    );
  }

  Future<void> _saveFavorites() async {
    final preferences =
    await SharedPreferences.getInstance();

    final encodedFavorites =
    _favorites.map((outfit) {
      return jsonEncode(outfit.toJson());
    }).toList();

    await preferences.setStringList(
      _storageKey,
      encodedFavorites,
    );
  }
}