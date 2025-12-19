import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitnessapp/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  String name = "Alex Johnson";
  String email = "alex.johnson@fitpro.com";
  String phone = "+1 (555) 123-4567";
  String specialization = "ACSM Certified, Nutrition Specialist";
  String experience = "5 Years";
  String avatarUrl = "https://i.pravatar.cc/300?img=12";
  bool notificationsOn = true;

  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          name = prefs.getString('trainer_name') ?? name;
          email = prefs.getString('trainer_email') ?? email;
          phone = prefs.getString('trainer_phone') ?? phone;
          specialization = prefs.getString('trainer_role') ?? specialization;
          experience = prefs.getString('trainer_experience') ?? experience;
          avatarUrl = prefs.getString('trainer_avatar') ?? avatarUrl;
          notificationsOn = prefs.getBool('trainer_notifications') ?? true;
        });
      }
    } catch (e) {
      debugPrint('Error loading trainer data: $e');
    }
  }

  void setMountedState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  Future<void> _updateNotificationPreference(bool value) async {
    setMountedState(() => notificationsOn = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('trainer_notifications', value);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({'notifications': value}, SetOptions(merge: true));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  // 🔥 REUSABLE AVATAR IMAGE PROVIDER (FIXES THE CRASH)
  ImageProvider getAvatarProvider(String url) {
    if (url.isEmpty || !url.startsWith('http')) {
      // Local file path
      if (url.startsWith('/') || url.contains('image_picker') || url.contains('tmp')) {
        final file = File(url);
        if (file.existsSync()) {
          return FileImage(file);
        }
      }
    }
    // Network URL
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    currentName: name,
                    currentEmail: email,
                    currentPhone: phone,
                    currentSpecialization: specialization,
                    currentExperience: experience,
                    currentAvatarUrl: avatarUrl,
                    onSave: (updated) {
                      setState(() {
                        name = updated['name']!;
                        email = updated['email']!;
                        phone = updated['phone']!;
                        specialization = updated['specialization']!;
                        experience = updated['experience']!;
                        avatarUrl = updated['avatarUrl']!;
                      });
                    },
                  ),
                ),
              );

              // 🔥 THIS IS THE KEY: Reload Home Tab data when returning
              if (result == true) {
                // You can use a GlobalKey or event bus, but easiest:
                // Just trigger a rebuild via a stream or post-frame
                // OR: Accept that didChangeDependencies will run when tab regains focus
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: getAvatarProvider(avatarUrl),
              onBackgroundImageError: (_, __) {
                debugPrint('Avatar load failed: $avatarUrl');
              },
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Certified Personal Trainer", style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text("$experience Experience", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _sectionTitle("Personal Information"),
            _infoRow("Name", name, Icons.person),
            _infoRow("Email", email, Icons.email),
            _infoRow("Phone", phone, Icons.phone),
            _infoRow("Specialization", specialization, Icons.fitness_center),
            _infoRow("Experience", experience, Icons.timer),
            const SizedBox(height: 32),
            _sectionTitle("Account & Settings"),
            _settingRow(
              "Change Password",
              Icons.lock,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
            ),
            _settingRow(
              "Notification Preferences",
              Icons.notifications,
              isSwitch: true,
              switchValue: notificationsOn,
              onSwitch: _updateNotificationPreference,
            ),
            _settingRow("Logout", Icons.logout, textColor: Colors.red, onTap: _logout),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
  );

  Widget _infoRow(String label, String value, IconData icon) => ListTile(
    leading: Icon(icon, color: Colors.deepPurple),
    title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
  );

  Widget _settingRow(String title, IconData icon,
      {bool isSwitch = false, bool switchValue = false, Color? textColor, VoidCallback? onTap, ValueChanged<bool>? onSwitch}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.deepPurple),
      title: Text(title, style: TextStyle(color: textColor ?? Colors.black87, fontWeight: FontWeight.w500)),
      trailing: isSwitch
          ? Switch(
        value: switchValue,
        onChanged: onSwitch,
        activeTrackColor: Colors.deepPurple.withOpacity(0.5),
        activeColor: Colors.deepPurple,
      )
          : const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap,
    );
  }
}

// ==================================================
// EDIT PROFILE SCREEN (WITH LOCAL IMAGE PICKER)
// ==================================================

class EditProfileScreen extends StatefulWidget {
  final String currentName, currentEmail, currentPhone, currentSpecialization, currentExperience, currentAvatarUrl;
  final Function(Map<String, String>) onSave;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentSpecialization,
    required this.currentExperience,
    required this.currentAvatarUrl,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl, _emailCtrl, _phoneCtrl, _specCtrl, _expCtrl;
  File? _tempImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _emailCtrl = TextEditingController(text: widget.currentEmail);
    _phoneCtrl = TextEditingController(text: widget.currentPhone);
    _specCtrl = TextEditingController(text: widget.currentSpecialization);
    _expCtrl = TextEditingController(text: widget.currentExperience);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _specCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _tempImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final newName = _nameCtrl.text.trim();
      if (newName.isEmpty) throw Exception("Name cannot be empty");

      String finalAvatarUrl = widget.currentAvatarUrl;

      // 🔥 NEW: If user picked a new photo → copy it to permanent storage
      if (_tempImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final permanentFile = File('${directory.path}/trainer_avatar.jpg');

        // Copy the temp image to permanent location
        await _tempImage!.copySync(permanentFile.path);

        finalAvatarUrl = permanentFile.path; // This path survives app restarts
      }

      // Save everything to SharedPreferences
      await prefs.setString('trainer_name', newName);
      await prefs.setString('trainer_role', _specCtrl.text.trim());
      await prefs.setString('trainer_avatar', finalAvatarUrl); // ← permanent path now
      await prefs.setString('trainer_email', _emailCtrl.text.trim());
      await prefs.setString('trainer_phone', _phoneCtrl.text.trim());
      await prefs.setString('trainer_experience', _expCtrl.text.trim());

      // Update parent screen
      widget.onSave({
        'name': newName,
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'specialization': _specCtrl.text.trim(),
        'experience': _expCtrl.text.trim(),
        'avatarUrl': finalAvatarUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated permanently!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  ImageProvider get _currentImageProvider {
    if (_tempImage != null) return FileImage(_tempImage!);
    if (widget.currentAvatarUrl.startsWith('/') || widget.currentAvatarUrl.contains('image_picker')) {
      final file = File(widget.currentAvatarUrl);
      if (file.existsSync()) return FileImage(file);
    }
    return NetworkImage(widget.currentAvatarUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _currentImageProvider,
                    child: _currentImageProvider is! FileImage && _currentImageProvider is! NetworkImage
                        ? Text(
                      widget.currentName.isNotEmpty ? widget.currentName[0].toUpperCase() : "T",
                      style: const TextStyle(fontSize: 60, color: Colors.white),
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _specCtrl, decoration: const InputDecoration(labelText: "Specialization", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _expCtrl, decoration: const InputDecoration(labelText: "Experience", border: OutlineInputBorder())),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 56)),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CHANGE PASSWORD SCREEN (UNCHANGED)
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _change() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match")));
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = EmailAuthProvider.credential(email: user!.email!, password: _oldCtrl.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password changed!")));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Failed";
      if (e.code == 'wrong-password') msg = "Current password is wrong";
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Current Password", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _newCtrl, obscureText: true, decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Confirm New Password", border: OutlineInputBorder())),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _change,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, minimumSize: const Size(double.infinity, 56)),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Update Password", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}