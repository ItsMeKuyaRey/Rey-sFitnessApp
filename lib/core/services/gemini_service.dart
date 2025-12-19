// lib/core/services/gemini_service.dart

import 'dart:io';
import 'dart:math';

class GeminiService {
  // 🎯 Complete Filipino Food Database
  static final List<Map<String, dynamic>> _foodDatabase = [
    {"meal_name": "Tapsilog", "total_calories": 650, "protein_grams": 35, "carbs_grams": 70, "fats_grams": 25},
    {"meal_name": "Tocino", "total_calories": 450, "protein_grams": 25, "carbs_grams": 45, "fats_grams": 18},
    {"meal_name": "Adobo (Chicken)", "total_calories": 380, "protein_grams": 32, "carbs_grams": 15, "fats_grams": 22},
    {"meal_name": "Sinigang na Baboy", "total_calories": 320, "protein_grams": 25, "carbs_grams": 18, "fats_grams": 18},
    {"meal_name": "Pancit Canton", "total_calories": 380, "protein_grams": 15, "carbs_grams": 55, "fats_grams": 12},
    {"meal_name": "Fried Rice", "total_calories": 320, "protein_grams": 8, "carbs_grams": 50, "fats_grams": 12},
    {"meal_name": "Jollibee Chickenjoy", "total_calories": 320, "protein_grams": 18, "carbs_grams": 15, "fats_grams": 22},
    {"meal_name": "Burger with Fries", "total_calories": 720, "protein_grams": 28, "carbs_grams": 75, "fats_grams": 35},
    {"meal_name": "Sisig", "total_calories": 420, "protein_grams": 24, "carbs_grams": 12, "fats_grams": 32},
    {"meal_name": "Lumpia Shanghai", "total_calories": 320, "protein_grams": 12, "carbs_grams": 28, "fats_grams": 18},
  ];

  // 🎯 Simulate AI food scanning
  static Future<Map<String, dynamic>?> analyzeFoodImage(File imageFile) async {
    try {
      print('🔍 Starting food analysis...');

      // Check if file exists
      if (!await imageFile.exists()) {
        print('❌ Image file does not exist');
        return null;
      }

      print('✅ Image file found: ${imageFile.path}');

      // Simulate AI processing time
      await Future.delayed(const Duration(seconds: 2));

      // Pick random food from database
      final random = Random();
      final randomFood = _foodDatabase[random.nextInt(_foodDatabase.length)];

      print('✅ Scanned food: ${randomFood['meal_name']}');
      print('📊 Nutrition: ${randomFood['total_calories']} cal, ${randomFood['protein_grams']}g protein');

      return randomFood;

    } catch (e) {
      print('❌ Error in analyzeFoodImage: $e');
      return null;
    }
  }
}