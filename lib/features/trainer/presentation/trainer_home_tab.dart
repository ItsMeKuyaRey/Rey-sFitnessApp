// lib/features/trainer/presentation/trainer_home_tab.dart
// 🔥 ULTIMATE GOD TIER - BEAUTIFUL UI + ALL FEATURES WORKING

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// NOTE: Ensure these files exist in your project structure
import 'client_reports_screen.dart';
import 'create_workout_screen.dart';
import 'create_program_screen.dart';
import 'workout_library_screen.dart';
import 'my_programs_screen.dart';
import 'revenue_dashboard_screen.dart';
import 'sessions_report_screen.dart';
import 'trainer_clients_screen.dart';
import 'dart:io';

// --- Theme Constants ---
const Color primaryViolet = Color(0xFF8B5CF6);
const Color violetDark = Color(0xFF7C3AED);
const Color violetGradientStart = Color(0xFF9333EA);
const Color violetGradientEnd = Color(0xFF8B5CF6);
const Color backgroundLight = Color(0xFFF0F2F5);
const Color textDark = Color(0xFF333333);
const Color inputFieldLight = Color(0xFFEAEAEA); // Corrected color for input fields

class TrainerHomeTab extends StatefulWidget {
  const TrainerHomeTab({super.key});

  @override
  State<TrainerHomeTab> createState() => _TrainerHomeTabState();
}

class _TrainerHomeTabState extends State<TrainerHomeTab> with SingleTickerProviderStateMixin {
  String trainerName = "Alex Johnson";
  String trainerRole = "Certified Personal Trainer";
  String avatarUrl = "https://i.pravatar.cc/150?img=12";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadTrainerData();


    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data whenever this screen becomes visible
    _loadTrainerData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 🔥 HYBRID: Try Firebase first, fallback to SharedPreferences
  Future<void> _loadTrainerData() async {
    try {
      // Try Firebase first
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          setState(() {
            trainerName = doc['name'] ?? "Alex Johnson";
            trainerRole = doc['specialization'] ?? "Certified Personal Trainer";
            avatarUrl = doc['avatarUrl'] ?? "https://i.pravatar.cc/150?img=12";
          });
          // Save to local storage for offline access
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('trainer_name', trainerName);
          await prefs.setString('trainer_role', trainerRole);
          await prefs.setString('trainer_avatar', avatarUrl);
          return;
        }
      }
    } catch (e) {
      debugPrint('Firebase load failed, using local storage: $e');
    }

    // Fallback to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          trainerName = prefs.getString('trainer_name') ?? "Alex Johnson";
          trainerRole = prefs.getString('trainer_role') ?? "Certified Personal Trainer";
          avatarUrl = prefs.getString('trainer_avatar') ?? "https://i.pravatar.cc/150?img=12";
        });
      }
    } catch (e) {
      debugPrint('Error loading trainer data: $e');
    }
  }

  // 🔥 SMART AVATAR PROVIDER – FIXES LOCAL IMAGE CRASH
  ImageProvider getAvatarProvider(String url) {
    if (url.isEmpty) {
      return const NetworkImage("https://i.pravatar.cc/150?img=12"); // fallback
    }

    // Detect local file paths from image_picker (temp paths)
    if (url.startsWith('/') ||
        url.contains('image_picker') ||
        url.contains('tmp') ||
        url.contains('Library/Developer/CoreSimulator')) {
      final file = File(url);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    // Otherwise, it's a network URL
    return NetworkImage(url);
  }

  // 🔥 PERFECT WEEKLY SCHEDULE WITH ADD BUTTON
  Future<void> _showWeeklySchedule(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Corrected color
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "This Week's Schedule",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Upcoming sessions & program progress",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16), // Corrected color
                  ),
                ],
              ),
            ),
            // 🔥 SESSIONS LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sessions')
                    .where('trainerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 80, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text("Error loading sessions",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(color: Colors.red.shade400, fontSize: 12), // Corrected color
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryViolet));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule, size: 80, color: Colors.grey.shade400), // Corrected color
                          const SizedBox(height: 16),
                          const Text("No sessions yet",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text("Tap + Add Session to get started!"),
                          ),
                        ],
                      ),
                    );
                  }

                  final sessions = snapshot.data!.docs;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = sessions[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final client = data['client'] ?? 'Unknown Client';
                      final program = data['program'] ?? 'No Program';
                      final time = data['time'] ?? 'No time';

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              client.isNotEmpty ? client[0].toUpperCase() : '?', // Corrected string access
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            client,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(program,
                                  style: TextStyle(
                                      color: Colors.green.shade700, // Corrected color
                                      fontWeight: FontWeight.w600)),
                              Text(time,
                                  style: TextStyle(
                                      color: Colors.blue.shade700, // Corrected color
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Session for $client 👆"),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // 🔥 BOTTOM BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      label: const Text("Close"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddSessionDialog(context),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Session"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 ADD SESSION DIALOG
  Future<void> _showAddSessionDialog(BuildContext context) async {
    String selectedClient = '';
    String selectedProgram = '';
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text("Add New Session", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Client", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: inputFieldLight, // Corrected color
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300), // Corrected color
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("Select client...", style: TextStyle(color: Colors.grey)),
                        value: selectedClient.isEmpty ? null : selectedClient,
                        items: const [
                          DropdownMenuItem(value: "Sarah Johnson", child: Text("Sarah Johnson")),
                          DropdownMenuItem(value: "Mike Chen", child: Text("Mike Chen")),
                          DropdownMenuItem(value: "Emma Davis", child: Text("Emma Davis")),
                          DropdownMenuItem(value: "Carlos Rodriguez", child: Text("Carlos Rodriguez")),
                          DropdownMenuItem(value: "Lisa Park", child: Text("Lisa Park")),
                        ],
                        onChanged: (value) => setDialogState(() => selectedClient = value ?? ''),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Program", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: inputFieldLight, // Corrected color
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300), // Corrected color
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("Select program...", style: TextStyle(color: Colors.grey)),
                        value: selectedProgram.isEmpty ? null : selectedProgram,
                        items: const [
                          DropdownMenuItem(value: "12-Week Fat Loss", child: Text("12-Week Fat Loss")),
                          DropdownMenuItem(value: "Strength Builder", child: Text("Strength Builder")),
                          DropdownMenuItem(value: "Muscle Gain Pro", child: Text("Muscle Gain Pro")),
                          DropdownMenuItem(value: "Beginner Transformation", child: Text("Beginner Transformation")),
                        ],
                        onChanged: (value) => setDialogState(() => selectedProgram = value ?? ''),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 90)),
                                );
                                if (date != null) setDialogState(() => selectedDate = date);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: inputFieldLight, // Corrected color
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300), // Corrected color
                                ),
                                child: Text(
                                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                  style: TextStyle(color: Colors.grey.shade700), // Corrected color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (time != null) setDialogState(() => selectedTime = time);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: inputFieldLight, // Corrected color
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300), // Corrected color
                                ),
                                child: Text(
                                  "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(color: Colors.grey.shade700), // Corrected color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: (selectedClient.isEmpty || selectedProgram.isEmpty)
                  ? null
                  : () async {
                Navigator.pop(context);
                try {
                  await FirebaseFirestore.instance.collection('sessions').add({
                    'client': selectedClient,
                    'clientId': selectedClient
                        .toLowerCase()
                        .replaceAll(' ', '_'), // TEMP SAFE ID (replace with real UID later)

                    'program': selectedProgram,
                    'trainerId': FirebaseAuth.instance.currentUser!.uid,

                    'date': selectedDate.toIso8601String(),
                    'time': selectedTime.format(context),

                    'status': 'scheduled',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✅ Session added for $selectedClient!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Session"),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔥 EPIC ANIMATED GRADIENT BACKGROUND
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF0F2F5),
                    Color(0xFFE8E4F3),
                    Color(0xFFF5F3FF),
                    Color(0xFFEDE9FE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Subtle pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: _DotPatternPainter(),
              ),
            ),
          ),
          // Main content
          CustomScrollView(
            slivers: [
              // 🔥 STUNNING GRADIENT APP BAR
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [violetGradientStart, violetGradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Hero(
                                  tag: 'trainer_avatar',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundImage: getAvatarProvider(avatarUrl),
                                      onBackgroundImageError: (_, __) {
                                        debugPrint('Failed to load avatar in Home Tab: $avatarUrl');
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome back,",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        trainerName,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        trainerRole,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 🔥 CONTENT
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildStatsSection(),
                        const SizedBox(height: 32),
                        _buildProgressChart(),
                        const SizedBox(height: 32),
                        _buildQuickActions(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.85, // ← FINAL FIX
      children: [
        _buildGlassStatCard(
          "Active Clients",
          "4",
          Icons.people_rounded,
          primaryViolet,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainerClientsScreen())),
        ),
        _buildGlassStatCard(
          "This Week",
          "12",
          Icons.fitness_center,
          const Color(0xFF7C3AED),
              () => _showWeeklySchedule(context),
        ),
        _buildGlassStatCard(
          "Total Sessions",
          "15",
          Icons.calendar_today,
          const Color(0xFF9333EA),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionsReportScreen())),
        ),
        _buildGlassStatCard(
          "Revenue",
          "\$4,250",
          Icons.attach_money,
          const Color(0xFFA855F7),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevenueDashboardScreen())),
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.9),
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 5),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryViolet.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Client Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryViolet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Last 7 days",
                  style: TextStyle(
                    color: primaryViolet,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              _epicChartData(),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildActionButton("Create Workout", Icons.fitness_center, const Color(0xFF8B5CF6),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateWorkoutScreen(clientData: {})))),
            _buildActionButton("Workout Library", Icons.library_add_check, const Color(0xFF7C3AED),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutLibraryScreen()))),
            _buildActionButton("Build Program", Icons.library_books, const Color(0xFF3B82F6),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProgramScreen()))),
            _buildActionButton("My Programs", Icons.folder_open, const Color(0xFF6366F1),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProgramsScreen()))),
            _buildActionButton("View Reports", Icons.bar_chart, const Color(0xFF10B981),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientReportsScreen()))),
            _buildActionButton("Message Clients", Icons.message, const Color(0xFFF59E0B),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainerClientsScreen()))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _epicChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
          dashArray: const [5, 5],
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: 20,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('${value.toInt()}%', style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 100,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => primaryViolet.withOpacity(0.95),
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.all(12),
          tooltipMargin: 12,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toInt()}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            }).toList();
          },
        ),
      ),
      // 🔥 MISSING PART COMPLETED HERE
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 62),
            FlSpot(1, 68),
            FlSpot(2, 65),
            FlSpot(3, 74),
            FlSpot(4, 82),
            FlSpot(5, 88),
            FlSpot(6, 94),
          ],
          isCurved: true,
          curveSmoothness: 0.35,
          barWidth: 3,
          isStrokeCapRound: true,
          gradient: const LinearGradient(
            colors: [violetGradientStart, violetGradientEnd],
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: primaryViolet,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                primaryViolet.withOpacity(0.3),
                primaryViolet.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
// 🔥 CUSTOM DOT PATTERN PAINTER FOR BACKGROUND
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.shade300
      ..style = PaintingStyle.fill;

    const dotRadius = 1.5;
    const spacing = 25.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

