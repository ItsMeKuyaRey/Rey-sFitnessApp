// lib/features/admin/presentation/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';
import 'package:provider/provider.dart'; // 🔥 ADDED FOR THEME
import '../../../core/theme/theme_provider.dart'; // 🔥 YOUR THEME PROVIDER
import '../../../core/localization/app_localizations.dart';
import 'admin_reports_screen.dart';
import 'admin_users_screen.dart';
import 'admin_plans_screen.dart';
import 'add_trainer_screen.dart';
import 'admin_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';


class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Timer? _themeTimer;
  String _adminName = "Admin";
  String _adminAvatar = "A";
  String? _adminImagePath;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
    _themeTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _checkProfile();
    });
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAdminProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _adminName = prefs.getString('admin_name') ?? "Admin";
        _adminAvatar = prefs.getString('admin_avatar') ?? "A";
        _adminImagePath = prefs.getString('admin_profile_image');
      });
    }
  }

  Future<void> _checkProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final currentName = prefs.getString('admin_name') ?? "Admin";
    final currentAvatar = prefs.getString('admin_avatar') ?? "A";
    final currentImage = prefs.getString('admin_profile_image');

    if (mounted) {
      setState(() {
        if (_adminName != currentName ||
            _adminAvatar != currentAvatar ||
            _adminImagePath != currentImage) {
          _adminName = currentName;
          _adminAvatar = currentAvatar;
          _adminImagePath = currentImage;
        }
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }


  void _sendEmail({required String toEmail, String subject = '', String body = ''}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: toEmail,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showSnackBar('Could not open email app', Colors.red);
    }
  }



  void _inviteTrainerByEmail() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white, // or use cardColor if you want dark mode
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Invite Trainer", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Trainer Name",
                hintText: "John Doe",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "trainer@example.com",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              if (emailController.text.isNotEmpty && nameController.text.isNotEmpty) {
                Navigator.pop(ctx);

                _sendEmail(
                  toEmail: emailController.text,
                  subject: 'Trainer Invitation',
                  body: 'Hi ${nameController.text},\n\nYou are invited to join our fitness app as a trainer. Please sign up using this link: [SIGN-UP LINK]',
                );

                // Launch email client
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: emailController.text,
                  queryParameters: {
                    'subject': 'Trainer Invitation',
                    'body': 'Hi ${nameController.text},\n\nYou are invited to join our fitness app as a trainer. Please sign up using this link: [SIGN-UP LINK]'
                  },
                );

                try {
                  launchUrl(emailUri);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Could not open email app"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Send Invite", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // 🔥 GET DARK THEME FROM PROVIDER
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);

    // 🔥 PERFECT DARK/LIGHT COLORS FROM THEME
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.grey[100]!;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey[600]!;
    final tertiaryTextColor = isDarkMode ? const Color(0xFF808080) : Colors.grey[500]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(
          localizations.translate("Admin Dashboard"),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // 🔥 CLEAN COMPACT PROFILE - PERFECT FIT
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar Stack
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 18, // Smaller
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: _adminImagePath != null && _adminImagePath!.isNotEmpty
                            ? ClipOval(
                          child: Image.file(
                            File(_adminImagePath!),
                            fit: BoxFit.cover,
                            width: 36,
                            height: 36,
                            errorBuilder: (_, __, ___) => Text(
                              _adminAvatar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                            : Text(
                          _adminAvatar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      // Green online dot
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Compact name
                  Container(
                    constraints: const BoxConstraints(maxWidth: 80), // Limit width
                    child: Text(
                      _adminName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 STATS ROW 1
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    localizations.translate("Total Users"),
                    "1,247",
                    Colors.deepPurple,
                    cardColor,
                    secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    localizations.translate("Active Trainers"),
                    "23",
                    Colors.green,
                    cardColor,
                    secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 🔥 STATS ROW 2
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    localizations.translate("Total Revenue"),
                    "\$12,450",
                    Colors.blue,
                    cardColor,
                    secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    localizations.translate("Pending Payments"),
                    "8",
                    Colors.orange,
                    cardColor,
                    secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 🔥 QUICK ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.translate("Quick Actions"),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios, size: 14, color: secondaryTextColor),
                  label: Text(
                    localizations.translate("View All"),
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 12),
            // 🔥 ACTION BUTTONS GRID
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildActionButton(
                  localizations.translate("Add Trainer"),
                  Icons.person_add,
                  Colors.deepPurple,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddTrainerScreen()),
                  ),
                ),
                _buildActionButton(
                  localizations.translate("Invite Trainer"),
                  Icons.email_outlined,
                  Colors.green,
                  _inviteTrainerByEmail,
                ),

                _buildActionButton(
                  localizations.translate("View Reports"),
                  Icons.bar_chart,
                  Colors.blue,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                  ),
                ),
                _buildActionButton(
                  localizations.translate("Manage Users"),
                  Icons.people,
                  Colors.green,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                  ),
                ),
                _buildActionButton(
                  localizations.translate("Payment Requests"),
                  Icons.payment,
                  Colors.orange,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPlansScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 🔥 RECENT ACTIVITY
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.translate("Recent Activity"),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                    );
                  },
                  child: Text(
                    localizations.translate("See All"),
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 12),
            ..._buildActivityItems(localizations, cardColor, secondaryTextColor, tertiaryTextColor),
          ],
        ),
      ),
    );
  }

  // 🔥 UPDATED METHODS WITH THEME PARAMETERS
  Widget _buildStatCard(String title, String value, Color color, Color cardColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: secondaryTextColor, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }

  List<Widget> _buildActivityItems(AppLocalizations localizations, Color cardColor, Color secondaryTextColor, Color tertiaryTextColor) {
    final activities = [
      [localizations.translate("New user registered"), "Samantha ${localizations.translate('just joined')}", "2 ${localizations.translate('min ago')}"],
      [localizations.translate("Payment received"), "Premium plan · \$49.99", "15 ${localizations.translate('min ago')}"],
      [localizations.translate("Trainer approved"), "Mike Johnson ${localizations.translate('is now active')}", "1 ${localizations.translate('hour ago')}"],
      [localizations.translate("New review"), "5⭐ from Alex Turner", "3 ${localizations.translate('hours ago')}"],
    ];

    return activities.map((activity) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add, color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(activity[1], style: TextStyle(color: secondaryTextColor, fontSize: 13)),
              ],
            ),
          ),
          Text(activity[2], style: TextStyle(color: tertiaryTextColor, fontSize: 12)),
        ],
      ),
    )).toList();
  }
}