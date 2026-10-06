import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clothing_item.dart';
import '../models/favorite_outfit.dart';
import '../models/wear_history.dart';

class WearHistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'wear_history';

  List<WearHistory> _history = [];

  List<WearHistory> get history =>
      List.unmodifiable(_history);

  int get totalWears => _history.length;

  int get uniqueOutfits {
    final ids = <String>{};

    for (final entry in _history) {
      ids.add(entry.outfit.id);
    }

    return ids.length;
  }

  List<WearHistory> get recentHistory {
    final sorted = List<WearHistory>.from(_history);

    sorted.sort(
          (a, b) => b.wornAt.compareTo(a.wornAt),
    );

    return sorted;
  }

  Future<void> loadHistory() async {
    final preferences =
    await SharedPreferences.getInstance();

    final savedHistory =
    preferences.getStringList(_storageKey);

    if (savedHistory == null) {
      _history = [];
      notifyListeners();
      return;
    }

    try {
      _history = savedHistory.map((item) {
        return WearHistory.fromJson(
          jsonDecode(item),
        );
      }).toList();

      _sortHistory();

      notifyListeners();
    } catch (_) {
      _history = [];
      notifyListeners();
    }
  }

  Future<void> markAsWorn({
    required FavoriteOutfit outfit,
    DateTime? wornAt,
    String? plannedOutfitId,
  }) async {
    if (plannedOutfitId != null &&
        isPlannedOutfitMarkedWorn(
          plannedOutfitId,
        )) {
      return;
    }

    final entry = WearHistory(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      outfit: outfit,
      wornAt: wornAt ?? DateTime.now(),
      plannedOutfitId: plannedOutfitId,
    );

    _history.add(entry);

    _sortHistory();

    await _saveHistory();

    notifyListeners();
  }

  Future<void> removeHistory(String id) async {
    _history.removeWhere(
          (entry) => entry.id == id,
    );

    await _saveHistory();

    notifyListeners();
  }

  bool isPlannedOutfitMarkedWorn(
      String plannedOutfitId,
      ) {
    return _history.any(
          (entry) =>
      entry.plannedOutfitId ==
          plannedOutfitId,
    );
  }

  int getWearCountForOutfit(
      FavoriteOutfit outfit,
      ) {
    return _history.where(
          (entry) => entry.outfit.id == outfit.id,
    ).length;
  }

  DateTime? getLastWornForOutfit(
      FavoriteOutfit outfit,
      ) {
    final matching = _history
        .where(
          (entry) =>
      entry.outfit.id == outfit.id,
    )
        .toList();

    if (matching.isEmpty) {
      return null;
    }

    matching.sort(
          (a, b) => b.wornAt.compareTo(a.wornAt),
    );

    return matching.first.wornAt;
  }

  // ----------------------------------------------------------
  // CLOTHING ITEM WEAR COUNT
  // ----------------------------------------------------------

  int getWearCountForItem(
      ClothingItem item,
      ) {
    int count = 0;

    for (final entry in _history) {
      final items = entry.outfit.items;

      final wasWorn = items.any(
            (wornItem) => wornItem.id == item.id,
      );

      if (wasWorn) {
        count++;
      }
    }

    return count;
  }

  // ----------------------------------------------------------
  // COST PER WEAR
  // ----------------------------------------------------------

  double getCostPerWear(
      ClothingItem item,
      ) {
    final wearCount = getWearCountForItem(item);

    if (wearCount == 0) {
      return item.price;
    }

    return item.price / wearCount;
  }

  // ----------------------------------------------------------
  // LAST WORN ITEM
  // ----------------------------------------------------------

  DateTime? getLastWornForItem(
      ClothingItem item,
      ) {
    for (final entry in recentHistory) {
      final wasWorn = entry.outfit.items.any(
            (wornItem) => wornItem.id == item.id,
      );

      if (wasWorn) {
        return entry.wornAt;
      }
    }

    return null;
  }

  // ----------------------------------------------------------
  // MOST WORN OUTFITS
  // ----------------------------------------------------------

  List<WearHistory> getMostWornOutfits() {
    final Map<String, List<WearHistory>>
    grouped = {};

    for (final entry in _history) {
      grouped.putIfAbsent(
        entry.outfit.id,
            () => [],
      );

      grouped[entry.outfit.id]!.add(entry);
    }

    final groups = grouped.values.toList();

    groups.sort(
          (a, b) => b.length.compareTo(a.length),
    );

    final result = <WearHistory>[];

    for (final group in groups) {
      result.add(group.first);
    }

    return result;
  }

  // ----------------------------------------------------------
  // SAVE HISTORY
  // ----------------------------------------------------------

  Future<void> _saveHistory() async {
    final preferences =
    await SharedPreferences.getInstance();

    final encodedHistory =
    _history.map((entry) {
      return jsonEncode(entry.toJson());
    }).toList();

    await preferences.setStringList(
      _storageKey,
      encodedHistory,
    );
  }

  void _sortHistory() {
    _history.sort(
          (a, b) => b.wornAt.compareTo(a.wornAt),
    );
  }
}