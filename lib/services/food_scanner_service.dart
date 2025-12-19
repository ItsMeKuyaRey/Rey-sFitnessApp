// lib/services/food_scanner_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FoodScannerService {
  static Future<Map<String, dynamic>?> scanFood() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 90,
    );

    if (image == null) return null;

    try {
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer sk-ant-api03-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-AAAA',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": "Analyze this food photo. Return ONLY this exact JSON:\n{\"name\":\"food name\",\"calories\":999,\"protein\":\"99g\",\"carbs\":\"99g\",\"fat\":\"99g\"}"},
                {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,$base64Image"}}
              ]
            }
          ],
          "max_tokens": 300
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        final clean = content.replaceAll('```json', '').replaceAll('```', '').trim();
        final data = jsonDecode(clean);

        return {
          "name": data["name"] ?? "Food",
          "calories": int.tryParse(data["calories"].toString()) ?? 0,
          "protein": data["protein"] ?? "0g",
          "carbs": data["carbs"] ?? "0g",
          "fat": data["fat"] ?? "0g",
          "imagePath": image.path,
        };
      }
    } catch (e) {
      print("Scan error: $e");
    }
    return null;
  }
}
