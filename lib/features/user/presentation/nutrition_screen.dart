// lib/features/user/presentation/nutrition_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/theme/theme_provider.dart';
import 'nutrition_provider.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  File? _selectedImage;

  Future<void> _pickFoodImage() async {
    final picker = ImagePicker();

    // Detect real device vs simulator
    final isPhysicalDevice = Platform.isAndroid
        ? (await DeviceInfoPlugin().androidInfo).isPhysicalDevice
        : (await DeviceInfoPlugin().iosInfo).isPhysicalDevice;

    final source = isPhysicalDevice ? ImageSource.camera : ImageSource.gallery;

    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 90,
    );

    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
      _analyzeFood(File(picked.path));
    }
  }

  Future<void> _analyzeFood(File image) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("AI is scanning your food...")),
    );

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'YOUR_GEMINI_KEY_HERE', // ← Put your key
      );

      final bytes = await image.readAsBytes();
      final response = await model.generateContent([
        Content.data('image/jpeg', bytes),
        Content.text(
          "Analyze this food. Return ONLY valid JSON in this exact format:\n"
              "{\"name\":\"food name\",\"calories\":999,\"protein\":\"99g\",\"carbs\":\"99g\",\"fat\":\"99g\"}",
        ),
      ]);

      final jsonStr = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (!mounted) return;

      context.read<NutritionProvider>().addScannedMeal(
        name: data['name'] ?? 'Unknown Food',
        calories: int.tryParse(data['calories'].toString()) ?? 0,
        protein: data['protein'] ?? '0g',
        carbs: data['carbs'] ?? '0g',
        fat: data['fat'] ?? '0g',
      );

      setState(() => _selectedImage = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${data['name']} added!", style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("AI Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? Colors.grey[900]! : const Color(0xFFFAFAFA);
    final cardColor = isDark ? Colors.grey[800]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Nutrition Log", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Consumer<NutritionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              const SizedBox(height: 30),

              // BEAUTIFUL SCAN BUTTON — SAME STYLE AS PROFILE
              GestureDetector(
                onTap: _pickFoodImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.deepPurple,
                      backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.restaurant_menu, size: 70, color: Colors.white)
                          : null,
                    ),
                    if (_selectedImage == null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                          ),
                          child: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
                        ),
                      ),
                    if (_selectedImage != null)
                      const Positioned(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text(
                "Tap to scan your meal",
                style: TextStyle(fontSize: 18, color: secondaryColor),
              ),

              const SizedBox(height: 30),

              // Total Calories Card
              Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text("Total Calories Today", style: TextStyle(color: secondaryColor, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        "${provider.totalCalories}",
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Text("of 2,500 goal", style: TextStyle(color: secondaryColor)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Food List
              Expanded(
                child: provider.foods.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_outlined, size: 80, color: secondaryColor),
                      const SizedBox(height: 16),
                      Text("No food logged yet", style: TextStyle(fontSize: 18, color: secondaryColor)),
                      Text("Tap the plate above to scan!", style: TextStyle(color: secondaryColor)),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.foods.length,
                  itemBuilder: (context, i) {
                    final food = provider.foods[i];
                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple[100],
                          child: const Icon(Icons.restaurant, color: Colors.deepPurple),
                        ),
                        title: Text(food.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text("${food.calories} kcal • ${food.protein} • ${food.carbs} • ${food.fat}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.removeFood(i),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}