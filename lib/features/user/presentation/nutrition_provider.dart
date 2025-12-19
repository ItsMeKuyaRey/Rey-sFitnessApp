import 'package:flutter/material.dart';

class FoodItem {
  final String name;
  final int calories;
  final String protein;
  final String carbs;
  final String fat;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class NutritionProvider extends ChangeNotifier {
  final List<FoodItem> _foods = [];

  List<FoodItem> get foods => _foods;

  int get totalCalories => _foods.fold(0, (sum, item) => sum + item.calories);

  int get totalProtein {
    return _foods.fold(0, (sum, item) {
      final value = int.tryParse(item.protein.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + value;
    });
  }

  int get totalCarbs {
    return _foods.fold(0, (sum, item) {
      final value = int.tryParse(item.carbs.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + value;
    });
  }

  int get totalFats {
    return _foods.fold(0, (sum, item) {
      final value = int.tryParse(item.fat.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + value;
    });
  }

  void addScannedMeal({
    required String name,
    required int calories,
    required String protein,
    required String carbs,
    required String fat,
  }) {
    _foods.add(FoodItem(
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    ));
    notifyListeners();
  }

  void addFood(FoodItem food) {
    _foods.add(food);
    notifyListeners();
  }

  void removeFood(int index) {
    if (index >= 0 && index < _foods.length) {
      _foods.removeAt(index);
      notifyListeners();
    }
  }

  void clearAll() {
    _foods.clear();
    notifyListeners();
  }
}