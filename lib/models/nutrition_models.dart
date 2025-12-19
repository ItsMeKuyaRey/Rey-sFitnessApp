// lib/models/nutrition_models.dart
class NutritionData {
  final int calories;
  final int goalCalories;
  final int protein;
  final int proteinGoal;
  final int carbs;
  final int carbsGoal;
  final int fats;
  final int fatsGoal;
  final List<Meal> recentMeals;

  NutritionData({
    required this.calories,
    required this.goalCalories,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fats,
    required this.fatsGoal,
    required this.recentMeals,
  });
}

class Meal {
  final String time;
  final String name;
  final int calories;

  Meal({
    required this.time,
    required this.name,
    required this.calories,
  });
}