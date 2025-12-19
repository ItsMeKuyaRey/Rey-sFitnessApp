// lib/features/admin/presentation/admin_activity_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';

class AdminActivityLogScreen extends StatefulWidget {
  const AdminActivityLogScreen({super.key});

  @override
  State<AdminActivityLogScreen> createState() => _AdminActivityLogScreenState();
}

class _AdminActivityLogScreenState extends State<AdminActivityLogScreen> {
  // Full list
  final List<Map<String, dynamic>> _allActivities = [
    {"name": "Sarah Johnson", "action": "upgraded to Premium", "time": "2 hours ago", "type": "upgrade", "avatar": "S", "date": "2025-12-01"},
    {"name": "Mike Chen", "action": "joined as Trainer", "time": "5 hours ago", "type": "trainer", "avatar": "M", "date": "2025-12-01"},
    {"name": "Emma Davis", "action": "purchased Elite Plan", "time": "1 day ago", "type": "purchase", "avatar": "E", "date": "2025-11-30"},
    {"name": "Alex Rivera", "action": "completed first workout", "time": "2 days ago", "type": "milestone", "avatar": "A", "date": "2025-11-29"},
    {"name": "Lisa Wong", "action": "referred a friend", "time": "3 days ago", "type": "referral", "avatar": "L", "date": "2025-11-28"},
    {"name": "David Kim", "action": "cancelled subscription", "time": "1 week ago", "type": "cancel", "avatar": "D", "date": "2025-11-24"},
    {"name": "John Doe", "action": "upgraded to Elite", "time": "4 hours ago", "type": "upgrade", "avatar": "J", "date": "2025-12-01"},
    {"name": "Anna Lee", "action": "completed 30-day streak", "time": "1 day ago", "type": "milestone", "avatar": "A", "date": "2025-11-30"},
  ];

  // Filtered list
  List<Map<String, dynamic>> _filteredActivities = [];

  // Filter states
  String _selectedType = "all";
  String _selectedTime = "all";

  @override
  void initState() {
    super.initState();
    _filteredActivities = List.from(_allActivities);
  }

  void _applyFilters() {
    setState(() {
      _filteredActivities = _allActivities.where((activity) {
        final matchesType = _selectedType == "all" || activity["type"] == _selectedType;
        final activityDate = DateTime.parse(activity["date"]);
        final now = DateTime.now();
        bool matchesTime = true;

        if (_selectedTime == "today") {
          matchesTime = activityDate.year == now.year && activityDate.month == now.month && activityDate.day == now.day;
        } else if (_selectedTime == "7days") {
          matchesTime = now.difference(activityDate).inDays <= 7;
        } else if (_selectedTime == "30days") {
          matchesTime = now.difference(activityDate).inDays <= 30;
        }

        return matchesType && matchesTime;
      }).toList();
    });
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedType = "all";
      _selectedTime = "all";
      _filteredActivities = List.from(_allActivities);
    });
    Navigator.pop(context);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Filter Activity",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text("Clear", style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("By Type", style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildTypeChip("all", "All Types", Icons.all_inclusive),
                          _buildTypeChip("upgrade", "Upgrade", Icons.trending_up),
                          _buildTypeChip("purchase", "Purchase", Icons.shopping_cart_outlined),
                          _buildTypeChip("trainer", "Trainer", Icons.fitness_center),
                          _buildTypeChip("milestone", "Milestone", Icons.emoji_events),
                          _buildTypeChip("referral", "Referral", Icons.card_giftcard),
                          _buildTypeChip("cancel", "Cancel", Icons.cancel),
                        ],
                      ),

                      const SizedBox(height: 32),
                      Text("By Time", style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildTimeChip("all", "All Time"),
                          _buildTimeChip("today", "Today"),
                          _buildTimeChip("7days", "Last 7 Days"),
                          _buildTimeChip("30days", "Last 30 Days"),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Bottom Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  border: Border(top: BorderSide(color: Colors.grey[800]!, width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[600]!),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Clear All"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                        ),
                        child: const Text("Apply Filters", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// PERFECT TYPE CHIP (MATCHES YOUR SCREENSHOT)
  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return FilterChip(
      showCheckmark: false,
      avatar: isSelected
          ? CircleAvatar(backgroundColor: Colors.white, radius: 10, child: Icon(icon, size: 16, color: Colors.deepPurple))
          : Icon(icon, color: Colors.grey[500], size: 20),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = value),
      backgroundColor: const Color(0xFF1E1E1E),
      selectedColor: Colors.deepPurple.shade400,
      side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey[700]!, width: 1.5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

// TIME CHIP
  Widget _buildTimeChip(String value, String label) {
    final isSelected = _selectedTime == value;
    return FilterChip(
      showCheckmark: false,
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTime = value;  // THIS WAS MISSING — NOW IT'S PRESSABLE
        });
      },
      backgroundColor: const Color(0xFF1E1E1E),
      selectedColor: Colors.deepPurple.shade400,
      side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey[700]!, width: 1.5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return FilterChip(
      label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)]),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = value),
      backgroundColor: Colors.grey[800],
      selectedColor: Colors.deepPurple,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey[300]),
    );
  }


  Color _getActionColor(String type, bool isDark) {
    switch (type) {
      case "upgrade": case "purchase": return Colors.green;
      case "trainer": return Colors.deepPurple;
      case "milestone": return Colors.blue;
      case "referral": return Colors.orange;
      case "cancel": return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getActionIcon(String type) {
    switch (type) {
      case "upgrade": case "purchase": return Icons.trending_up;
      case "trainer": return Icons.fitness_center;
      case "milestone": return Icons.emoji_events;
      case "referral": return Icons.card_giftcard;
      case "cancel": return Icons.cancel;
      default: return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50]!;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(tr.translate("Activity Log"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet, // NOW IT WORKS!
            tooltip: "Filter",
          ),
        ],
      ),
      body: _filteredActivities.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 80, color: secondaryText),
            const SizedBox(height: 16),
            Text(tr.translate("No activity found"), style: TextStyle(fontSize: 18, color: secondaryText)),
            const SizedBox(height: 8),
            Text("Try adjusting filters", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredActivities.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today • ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}",
                  style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
              ],
            );
          }

          final activity = _filteredActivities[index - 1];
          final color = _getActionColor(activity["type"], isDark);

          return Card(
            color: cardColor,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isDark ? 0 : 4,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Text(activity["avatar"], style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
              title: Text(activity["name"], style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              subtitle: Text(activity["action"], style: TextStyle(color: color, fontWeight: FontWeight.w500)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getActionIcon(activity["type"]), color: color, size: 20),
                  const SizedBox(height: 4),
                  Text(activity["time"], style: TextStyle(fontSize: 12, color: secondaryText)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}