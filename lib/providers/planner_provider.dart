import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_outfit.dart';
import '../models/planned_outfit.dart';

class PlannerProvider extends ChangeNotifier {
  static const String _storageKey = 'planned_outfits';

  List<PlannedOutfit> _plannedOutfits = [];

  List<PlannedOutfit> get plannedOutfits =>
      List.unmodifiable(_plannedOutfits);

  Future<void> loadPlans() async {
    final preferences =
    await SharedPreferences.getInstance();

    final savedPlans =
    preferences.getStringList(_storageKey);

    if (savedPlans == null) {
      _plannedOutfits = [];
      notifyListeners();
      return;
    }

    _plannedOutfits = savedPlans.map((item) {
      return PlannedOutfit.fromJson(
        jsonDecode(item),
      );
    }).toList();

    notifyListeners();
  }

  Future<void> addPlan({
    required DateTime date,
    required FavoriteOutfit outfit,
  }) async {
    final dateKey = _dateKey(date);

    // Remove an existing plan for the same date.
    _plannedOutfits.removeWhere(
          (plan) => plan.date == dateKey,
    );

    final newPlan = PlannedOutfit(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      date: dateKey,
      outfit: outfit,
      createdAt: DateTime.now(),
    );

    _plannedOutfits.add(newPlan);

    _sortPlans();

    await _savePlans();

    notifyListeners();
  }

  Future<void> removePlan(String id) async {
    _plannedOutfits.removeWhere(
          (plan) => plan.id == id,
    );

    await _savePlans();

    notifyListeners();
  }

  PlannedOutfit? getPlanForDate(DateTime date) {
    final dateKey = _dateKey(date);

    try {
      return _plannedOutfits.firstWhere(
            (plan) => plan.date == dateKey,
      );
    } catch (_) {
      return null;
    }
  }

  List<PlannedOutfit> getPlansForDate(
      DateTime date,
      ) {
    final dateKey = _dateKey(date);

    return _plannedOutfits
        .where((plan) => plan.date == dateKey)
        .toList();
  }

  bool hasPlanForDate(DateTime date) {
    return getPlanForDate(date) != null;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month =
    date.month.toString().padLeft(2, '0');
    final day =
    date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  void _sortPlans() {
    _plannedOutfits.sort(
          (a, b) => a.date.compareTo(b.date),
    );
  }

  Future<void> _savePlans() async {
    final preferences =
    await SharedPreferences.getInstance();

    final encodedPlans =
    _plannedOutfits.map((plan) {
      return jsonEncode(plan.toJson());
    }).toList();

    await preferences.setStringList(
      _storageKey,
      encodedPlans,
    );
  }
}