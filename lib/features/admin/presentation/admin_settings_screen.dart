// lib/features/admin/presentation/admin_settings_screen.dart
import 'dart:io';
import 'dart:convert'; // 🔥 REQUIRED FOR JSON
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late bool _notifications;
  late String _units;
  int _unreadNotifications = 3;
  List<Map<String, dynamic>> _notificationsList = [];

  final TextEditingController _nameController = TextEditingController();
  String _currentName = "Admin";
  File? _profileImage;
  String _adminAvatar = "A";

  @override
  void initState() {
    super.initState();
    _notifications = true;
    _units = "kg/km";
    _loadSettings();

    // 🔥 ADD TEST NOTIFICATION AFTER LOAD
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addTestNotification();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 🔥 LOAD ALL SETTINGS + NOTIFICATIONS
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _notifications = prefs.getBool('notifications') ?? true;
      _units = prefs.getString('units') ?? "kg/km";
      _currentName = prefs.getString('admin_name') ?? "Admin";
      _adminAvatar = prefs.getString('admin_avatar') ?? "A";
      _unreadNotifications = prefs.getInt('unread_notifications') ?? 3;
      _nameController.text = _currentName;
    });

    await _loadNotifications();
  }

  // 🔥 LOAD NOTIFICATIONS FROM STORAGE
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList('notifications_list') ?? [];

    List<Map<String, dynamic>> notifications = [];
    for (String json in notificationsJson) {
      try {
        notifications.add(Map<String, dynamic>.from(jsonDecode(json)));
      } catch (e) {}
    }

    if (mounted) {
      setState(() {
        _notificationsList = notifications;
      });
    }
  }

  // 🔥 SAVE NOTIFICATIONS
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson =
        _notificationsList.map((notif) => jsonEncode(notif)).toList();
    await prefs.setStringList('notifications_list', notificationsJson);
    await prefs.setInt('unread_notifications', _unreadNotifications);
  }

  // 🔥 MARK ALL READ
  void _markAllRead() {
    setState(() {
      _unreadNotifications = 0;
      for (var notif in _notificationsList) {
        notif['read'] = true;
      }
    });
    _saveNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All notifications marked as read!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 🔥 ADD NEW NOTIFICATION (for testing)
  void _addTestNotification() {
    final now = DateTime.now();
    final newNotif = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'New user registered',
      'message': 'Samantha just joined',
      'type': 'user',
      'time': now.toIso8601String(),
      'read': false,
    };

    setState(() {
      _notificationsList.insert(0, newNotif);
      _unreadNotifications++;
    });

    _saveNotifications();
  }

  // 🔥 FULL NOTIFICATIONS DIALOG - CONNECTED TO TOGGLE
  void _showNotificationsDialog(BuildContext context) {
    final tr = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Expanded(
                // Let left side take available space
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.deepPurple),
                    SizedBox(width: 12),
                    Text(
                      "Notifications",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (_unreadNotifications > 0)
                TextButton(
                  onPressed: _markAllRead,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: Colors.deepPurple,
                  ),
                  child: const Text("Mark All Read",
                      style: TextStyle(fontSize: 12.5)),
                ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: _notificationsList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No notifications",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _notificationsList.length,
                    itemBuilder: (context, index) {
                      final notif = _notificationsList[index];
                      final isRead = notif['read'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isRead
                            ? Colors.grey[50]
                            : Colors.deepPurple.shade50,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_add,
                                color: Colors.deepPurple),
                          ),
                          title: Text(
                            notif['title'] ?? '',
                            style: TextStyle(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notif['message'] ?? ''),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(notif['time']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: isRead
                              ? null
                              : Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.deepPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '•',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                          onTap: () {
                            // Mark as read
                            setState(() {
                              _notificationsList[index]['read'] = true;
                              if (!isRead) _unreadNotifications--;
                            });
                            _saveNotifications();
                            setDialogState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr.translate("Close")),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 TIME FORMATTER
  String _formatTime(String? timeString) {
    if (timeString == null) return '';
    final dateTime = DateTime.parse(timeString);
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  // 🔥 FIREBASE PASSWORD CHANGE
  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'no-user');

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  String _getErrorMessage(String code, AppLocalizations tr) {
    switch (code) {
      case 'wrong-password':
        return tr.translate("Current password is incorrect");
      case 'weak-password':
        return tr.translate("Password is too weak");
      case 'requires-recent-login':
        return tr.translate("Please log in again to change password");
      case 'user-mismatch':
        return tr.translate("User not found");
      case 'invalid-credential':
        return tr.translate("Invalid current password");
      default:
        return tr.translate("Password change failed. Please try again.");
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    await prefs.setString('admin_name', newName);
    String avatar = newName.isNotEmpty ? newName[0].toUpperCase() : "A";
    await prefs.setString('admin_avatar', avatar);

    if (_profileImage != null) {
      await prefs.setString('admin_profile_image', _profileImage!.path);
    } else {
      await prefs.remove('admin_profile_image');
    }

    if (mounted) {
      setState(() {
        _currentName = newName;
        _adminAvatar = avatar;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)
              .translate("Profile updated successfully!")),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getLanguageName(String code) {
    const map = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'zh': '中文',
    };
    return map[code] ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    context.watch<LanguageProvider>();
    final theme = context.watch<ThemeProvider>();
    final langProvider = context.watch<LanguageProvider>();
    final isDark = theme.isDarkMode;
    final currentLang = _getLanguageName(langProvider.locale.languageCode);

    final bgColor = isDark ? Colors.grey[900]! : Colors.grey[50]!;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade600,
                  Colors.deepPurple.shade800
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("FitPro",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2)),
                      Text(tr.translate("Admin Panel"),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => _showNotificationsDialog(context),
                        icon: const Icon(Icons.notifications_outlined,
                            size: 28, color: Colors.white),
                      ),
                      if (_unreadNotifications > 0 && _notifications)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              _unreadNotifications < 10
                                  ? "$_unreadNotifications"
                                  : "9+",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // MAIN CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSectionTitle(
                      tr.translate("Account Settings"), textColor),
                  _buildTile(
                      Icons.person_outline,
                      tr.translate("Edit Profile"),
                      () => _showEditProfileDialog(context),
                      cardColor,
                      textColor,
                      secColor),
                  _buildTile(
                      Icons.lock_outline,
                      tr.translate("Change Password"),
                      () => _showChangePasswordDialog(context),
                      cardColor,
                      textColor,
                      secColor),

                  // 🔥 UPDATED NOTIFICATION SWITCH
                  _buildSwitchTile(
                    Icons.notifications_outlined,
                    tr.translate("Notification Preferences"),
                    _notifications,
                    (v) async {
                      setState(() => _notifications = v);
                      await _saveSetting('notifications', v);

                      // 🔥 HIDE/SHOW BELL BADGE
                      if (!v && _unreadNotifications > 0) {
                        setState(() => _unreadNotifications = 0);
                        _markAllRead();
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${tr.translate("Notifications")} ${v ? tr.translate("enabled") : tr.translate("disabled")}"),
                            backgroundColor: v ? Colors.green : Colors.orange,
                          ),
                        );
                      }
                    },
                    cardColor,
                    textColor,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle(
                      tr.translate("System Settings"), textColor),
                  _buildSwitchTile(
                    Icons.palette_outlined,
                    tr.translate("App Theme"),
                    isDark,
                    (v) {
                      theme.toggleTheme(v);
                      _saveSetting('dark_mode', v);
                    },
                    cardColor,
                    textColor,
                  ),
                  _buildTile(
                      Icons.straighten_outlined,
                      tr.translate("Default Units"),
                      () => _showUnitsDialog(context),
                      cardColor,
                      textColor,
                      secColor,
                      trailing:
                          Text(_units, style: TextStyle(color: secColor))),
                  _buildTile(
                      Icons.language,
                      tr.translate("Language"),
                      () => _showLanguageDialog(context),
                      cardColor,
                      textColor,
                      secColor,
                      trailing:
                          Text(currentLang, style: TextStyle(color: secColor))),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.logout,
                          color: isDark ? Colors.grey[400] : Colors.grey[700]),
                      label: Text(tr.translate("Logout"),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700])),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ALL OTHER METHODS (UNCHANGED)
  Widget _buildSectionTitle(String title, Color color) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ),
      );

  Widget _buildTile(IconData icon, String title, VoidCallback onTap,
      Color cardColor, Color textColor, Color secColor,
      {Widget? trailing}) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
        trailing: trailing ?? Icon(Icons.chevron_right, color: secColor),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value,
      ValueChanged<bool> onChanged, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.deepPurple),
        title: Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.deepPurple,
        inactiveThumbColor: Colors.grey[600],
        inactiveTrackColor: Colors.grey.withOpacity(0.3),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final tr = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Text(tr.translate("Edit Profile"),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setDialogState(() {
                          _profileImage = File(image.path);
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.deepPurple, width: 3),
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.deepPurple,
                              child: Text(
                                _adminAvatar,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: tr.translate("Name"),
                    prefixIcon:
                        const Icon(Icons.person, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (_profileImage != null)
                  TextButton.icon(
                    onPressed: () {
                      setDialogState(() {
                        _profileImage = null;
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: Text(tr.translate("Remove Photo"),
                        style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr.translate("Cancel"))),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(tr.translate("Save"), style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final tr = AppLocalizations.of(context);
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _isLoading = false;
    String? _errorMessage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.lock, color: Colors.orange),
              const SizedBox(width: 12),
              Text(tr.translate("Change Password"),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: tr.translate("Current Password"),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.orange),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.translate("Enter current password");
                      }
                      if (value.length < 6) {
                        return tr.translate(
                            "Password must be at least 6 characters");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: tr.translate("New Password"),
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.translate("Enter new password");
                      }
                      if (value.length < 6) {
                        return tr.translate(
                            "Password must be at least 6 characters");
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: tr.translate("Confirm New Password"),
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.translate("Confirm your new password");
                      }
                      if (value != newPasswordController.text) {
                        return tr.translate("Passwords don't match");
                      }
                      return null;
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr.translate("Cancel")),
            ),
            _isLoading
                ? const SizedBox(
                    width: 120,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setDialogState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });

                        try {
                          await _changePassword(
                            currentPasswordController.text,
                            newPasswordController.text,
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(tr.translate(
                                    "Password changed successfully!")),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() {
                            _isLoading = false;
                            _errorMessage = _getErrorMessage(e.code, tr);
                          });
                        } catch (e) {
                          setDialogState(() {
                            _isLoading = false;
                            _errorMessage = tr.translate(
                                "Something went wrong. Please try again.");
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: Text(tr.translate("Change")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _showUnitsDialog(BuildContext context) async {
    final tr = AppLocalizations.of(context);
    final units = ["kg/km", "lbs/miles"];
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(tr.translate("Default Units")),
        children: units
            .map((u) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, u),
                  child: Text(u),
                ))
            .toList(),
      ),
    );
    if (selected != null && selected != _units) {
      setState(() => _units = selected);
      await _saveSetting('units', selected);
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = ["English", "Español", "Français", "Deutsch", "中文"];
    final codes = ['en', 'es', 'fr', 'de', 'zh'];

    showDialog(
      context: context,
      builder: (_) => Consumer<LanguageProvider>(
        builder: (context, langProvider, _) {
          final tr = AppLocalizations.of(context);
          final current = _getLanguageName(langProvider.locale.languageCode);
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(tr.translate("Language")),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(languages[i]),
                  trailing: current == languages[i]
                      ? const Icon(Icons.check, color: Colors.deepPurple)
                      : null,
                  onTap: () async {
                    await langProvider.setLocale(Locale(codes[i]));
                    await _saveSetting('language_display', languages[i]);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr.translate("Cancel")))
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final tr = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr.translate("Logout"),
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(tr.translate("Are you sure you want to logout?")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr.translate("Cancel"))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            child: Text(tr.translate("Logout"),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
