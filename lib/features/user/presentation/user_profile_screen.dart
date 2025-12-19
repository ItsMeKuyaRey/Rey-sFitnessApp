// lib/features/user/presentation/user_profile_screen.dart
// FULL LOCAL VERSION — SAME DESIGN AS YOUR OLD 400-LINE FIREBASE ONE
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/presentation/login_screen.dart';
import 'user_chat_screen.dart'; // 🔥 make sure this path is correct


class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _displayName = "John";
  String _userAvatar = "J";
  String? _profileImagePath;

  // Personal Info (saved locally)
  String _currentWeight = "68 kg";
  String _goalWeight = "60 kg";
  String _height = "5'6\"";
  final String _trainerName = "David Thompson";

  File? _tempImage;
  final _nameController = TextEditingController();
  final _weightController = TextEditingController(text: "68");
  final _goalController = TextEditingController(text: "60");
  final _heightController = TextEditingController(text: "5'6\"");

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name') ?? "John";
    final avatar = prefs.getString('user_avatar') ?? name[0].toUpperCase();
    final imagePath = prefs.getString('user_profile_image');
    final weight = prefs.getString('user_current_weight') ?? "68";
    final goal = prefs.getString('user_goal_weight') ?? "60";
    final height = prefs.getString('user_height') ?? "5'6\"";

    if (mounted) {
      setState(() {
        _displayName = name;
        _userAvatar = avatar;
        _profileImagePath = imagePath;
        _currentWeight = "$weight kg";
        _goalWeight = "$goal kg";
        _height = height;

        _nameController.text = name;
        _weightController.text = weight;
        _goalController.text = goal;
        _heightController.text = height;
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await prefs.setString('user_name', newName);
    await prefs.setString('user_avatar', newName[0].toUpperCase());
    await prefs.setString('user_current_weight', _weightController.text);
    await prefs.setString('user_goal_weight', _goalController.text);
    await prefs.setString('user_height', _heightController.text);

    if (_tempImage != null) {
      await prefs.setString('user_profile_image', _tempImage!.path);
    }

    if (mounted) {
      setState(() {
        _displayName = newName;
        _userAvatar = newName[0].toUpperCase();
        _currentWeight = "${_weightController.text} kg";
        _goalWeight = "${_goalController.text} kg";
        _height = _heightController.text;
        _profileImagePath = _tempImage?.path;
        _tempImage = null;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Profile updated!"), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        _tempImage = File(picked.path);
      });
    }
  }

  ImageProvider? get _currentImageProvider {
    if (_tempImage != null) return FileImage(_tempImage!);
    if (_profileImagePath != null) return FileImage(File(_profileImagePath!));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final bgColor = isDark ? Colors.grey[900]! : const Color(0xFFFAFAFA);
    final cardColor = isDark ? Colors.grey[800]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(_displayName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white),
            onPressed: () => Provider.of<ThemeProvider>(context, listen: false)
                .toggleTheme(!isDark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple,
                    backgroundImage: _currentImageProvider,
                    child: _tempImage == null && _profileImagePath == null
                        ? Text(
                            _displayName.isNotEmpty
                                ? _displayName[0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                                fontSize: 60, color: Colors.white),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.deepPurple, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(_displayName,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text("Weight Loss Goal",
                style: TextStyle(color: secondaryTextColor)),
            const SizedBox(height: 30),

            // PERSONAL INFO CARD
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Personal Information",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 16),
                    _infoRow("Current Weight", _currentWeight, textColor,
                        secondaryTextColor),
                    _infoRow("Goal Weight", _goalWeight, textColor,
                        secondaryTextColor),
                    _infoRow("Height", _height, textColor, secondaryTextColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TRAINER CARD
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400"),
                ),
                title: Text(
                  _trainerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  "Certified Personal Trainer",
                  style: TextStyle(color: secondaryTextColor),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    elevation: 6, // ↑ add shadow
                    shadowColor: Colors.black54, // optional, makes shadow darker
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => UserChatScreen()));
                  },
                  child: const Text(
                    "Message",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),


            const SizedBox(height: 30),
            _buildButton(
                "Edit Profile", Icons.edit, _showEditDialog, textColor),
            _buildButton("Logout", Icons.logout, () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false,
                );
              }
            }, Colors.red),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      String label, String value, Color textColor, Color secondaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: secondaryColor)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildButton(
      String title, IconData icon, VoidCallback onTap, Color textColor) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _currentImageProvider,
                  child: _tempImage == null && _profileImagePath == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: "Name", prefixIcon: Icon(Icons.person))),
              TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Current Weight (kg)",
                      prefixIcon: Icon(Icons.fitness_center))),
              TextField(
                  controller: _goalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Goal Weight (kg)",
                      prefixIcon: Icon(Icons.flag))),
              TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                      labelText: "Height", prefixIcon: Icon(Icons.height))),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(onPressed: _saveProfile, child: const Text("Save")),
        ],
      ),
    );
  }
}
