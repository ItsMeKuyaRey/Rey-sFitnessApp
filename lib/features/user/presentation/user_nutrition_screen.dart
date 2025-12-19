// lib/features/user/presentation/user_nutrition_screen.dart
// WITH DARK MODE SUPPORT!
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/gemini_service.dart';

class UserNutritionScreen extends StatefulWidget {
  const UserNutritionScreen({super.key});

  @override
  State<UserNutritionScreen> createState() => _UserNutritionScreenState();
}

class _UserNutritionScreenState extends State<UserNutritionScreen> {
  int consumedCalories = 1847;
  int calorieGoal = 2500;
  int protein = 79;
  int carbs = 182;
  int fats = 63;

  final List<Map<String, dynamic>> recentMeals = [
    {"time": "Breakfast", "name": "Oatmeal with berries", "cal": 320},
    {"time": "Lunch", "name": "Grilled chicken salad", "cal": 489},
    {"time": "Snack", "name": "Greek yogurt + almonds", "cal": 182},
  ];

  bool isScanning = false;

  // lib/features/user/presentation/user_nutrition_screen.dart

  Future<void> _scanFood() async {
    final picker = ImagePicker();

    // Pick image from camera
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (photo == null) {
      print('❌ User cancelled photo');
      return; // User cancelled
    }

    print('✅ Photo taken: ${photo.path}');

    setState(() => isScanning = true);

    try {
      // Convert XFile to File
      final File imageFile = File(photo.path);

      // Call the working service
      final result = await GeminiService.analyzeFoodImage(imageFile);

      print('📊 Analysis result: $result');

      if (result != null) {
        setState(() {
          // Add calories
          consumedCalories += (result['total_calories'] as num).toInt();
          protein += (result['protein_grams'] as num).toInt();
          carbs += (result['carbs_grams'] as num).toInt();
          fats += (result['fats_grams'] as num).toInt();

          // Add to recent meals
          recentMeals.insert(0, {
            "time": "Just Now",
            "name": result['meal_name'] ?? "Unknown Meal",
            "cal": result['total_calories'],
          });

          isScanning = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "✅ Added ${result['meal_name']} • ${result['total_calories']} cal",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Result is null');
      }

    } catch (e) {
      print('❌ Error in _scanFood: $e');
      setState(() => isScanning = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to analyze: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;
    final cardColor = isDark ? Colors.grey[800]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    int remaining = calorieGoal - consumedCalories;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Nutrition",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // CALORIES CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Calories",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$consumedCalories",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "of $calorieGoal goal",
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Remaining",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$remaining",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: remaining > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _macroRing("Protein", "$protein g", "160g", Colors.red, textColor),
                      _macroRing("Carbs", "$carbs g", "300g", Colors.blue, textColor),
                      _macroRing("Fats", "$fats g", "80g", Colors.amber, textColor),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SCAN BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: isScanning ? null : _scanFood,
                icon: isScanning
                    ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.camera_alt, size: 28),
                label: Text(
                  isScanning
                      ? "Analyzing Food..."
                      : "Scan or Upload Food Photo",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // RECENT MEALS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Meals",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                    onPressed: () {},
                    child: const Text("View All",
                        style: TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 12),
            ...recentMeals.map((meal) => _mealItem(
              meal["time"] as String,
              meal["name"] as String,
              "${meal["cal"]} Cal",
              cardColor,
              textColor,
            )),
          ],
        ),
      ),
    );
  }

  Widget _macroRing(String label, String consumed, String goal, Color color, Color textColor) {
    final double percentage = double.parse(consumed.replaceAll("g", "")) /
        double.parse(goal.replaceAll("g", ""));
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 90,
              width: 90,
              child: CircularProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                strokeWidth: 10,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              consumed,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            )),
      ],
    );
  }

  Widget _mealItem(String time, String name, String calories, Color cardColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.restaurant_menu, color: Colors.deepPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            calories,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}