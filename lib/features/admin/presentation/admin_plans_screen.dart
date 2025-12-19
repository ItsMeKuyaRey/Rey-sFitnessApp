// lib/features/admin/presentation/admin_plans_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';

class AdminPlansScreen extends StatefulWidget {
  const AdminPlansScreen({super.key});

  // Plans data — all keys are now translatable
  final List<Map<String, dynamic>> plans = const [
    {
      "name": "Premium Plan",
      "price": 99,
      "duration": "month",
      "features": [
        "Unlimited classes",
        "Personal trainer access",
        "Priority chat support",
      ],
      "activeUsers": 24,
      "users": [
        {"name": "Sarah Johnson", "joined": "Jan 15, 2025"},
        {"name": "Mike Anderson", "joined": "Jan 10, 2025"},
        {"name": "Emily Davidson", "joined": "Jan 8, 2025"},
      ],
    },
    {
      "name": "Basic Plan",
      "price": 49,
      "duration": "month",
      "features": ["20 classes/month", "Community access", "Weekly check-ins"],
      "activeUsers": 87,
      "users": [],
    },
    {
      "name": "Elite Plan",
      "price": 199,
      "duration": "month",
      "features": [
        "Everything in Premium",
        "1-on-1 coaching",
        "Custom nutrition plan",
        "24/7 priority support",
      ],
      "activeUsers": 12,
      "users": [],
    },
  ];

  @override
  State<AdminPlansScreen> createState() => _AdminPlansScreenState();
}

class _AdminPlansScreenState extends State<AdminPlansScreen> {
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    final backgroundColor =
        isDarkMode ? const Color(0xFF121212) : Colors.grey[50]!;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey[600]!;
    final tertiaryTextColor =
        isDarkMode ? const Color(0xFF808080) : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(tr.translate("Membership Plans"),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.plans.length,
        itemBuilder: (context, index) {
          final plan = widget.plans[index];
          final hasUsers = (plan["users"] as List).isNotEmpty;

          return Card(
            color: cardColor,
            margin: const EdgeInsets.only(bottom: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isDarkMode ? 0 : 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr.translate(plan["name"]),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.deepPurple.withOpacity(0.2)
                              : Colors.deepPurple[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tr.translate("Active"),
                            style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text("\$${plan["price"]}",
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple)),
                  Text("/ ${tr.translate(plan["duration"])}",
                      style: TextStyle(color: secondaryTextColor)),
                  const SizedBox(height: 16),

                  // Features
                  ...plan["features"]
                      .map<Widget>((feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check,
                                    size: 18, color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(tr.translate(feature),
                                        style: TextStyle(
                                            color: tertiaryTextColor))),
                              ],
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(tr.translate("Edit Plan")),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            side: const BorderSide(color: Colors.deepPurple),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () =>
                              _showEditPlanDialog(context, plan, tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: Text(tr.translate("Delete")),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () =>
                              _showDeleteDialog(context, plan["name"], tr),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Users Section
                  if (hasUsers) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr
                              .translate("Users Assigned (%d)")
                              .replaceAll("%d", plan["activeUsers"].toString()),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: textColor),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(tr
                                      .translate("Showing %d users for %s")
                                      .replaceAll(
                                          "%d", plan["activeUsers"].toString())
                                      .replaceAll(
                                          "%s", tr.translate(plan["name"]))),
                                  backgroundColor: Colors.deepPurple),
                            );
                          },
                          child: Text(tr.translate("View All"),
                              style: const TextStyle(color: Colors.deepPurple)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(plan["users"] as List)
                        .take(3)
                        .map<Widget>((user) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: isDarkMode
                                        ? Colors.deepPurple.withOpacity(0.3)
                                        : Colors.deepPurple[100],
                                    child: Text(user["name"][0],
                                        style: const TextStyle(
                                            color: Colors.deepPurple)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user["name"],
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: textColor)),
                                        Text(
                                            tr
                                                .translate("Joined %s")
                                                .replaceAll(
                                                    "%s", user["joined"]),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: secondaryTextColor)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    if (plan["activeUsers"] > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(tr.translate("+ and more..."),
                            style: TextStyle(color: secondaryTextColor)),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "admin_plans_fab", // ← STATIC, UNIQUE TAG
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(tr.translate("New Plan"), style: const TextStyle(color: Colors.white)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr.translate("New plan creation coming soon!")),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showEditPlanDialog(
      BuildContext context, Map<String, dynamic> plan, AppLocalizations tr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.watch<ThemeProvider>().isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        title: Text(tr
            .translate("Edit %s")
            .replaceAll("%s", tr.translate(plan["name"]))),
        content: Text(
            tr.translate("Edit plan details here (full form coming soon)")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.translate("Cancel"))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(tr
                        .translate("%s updated successfully!")
                        .replaceAll("%s", tr.translate(plan["name"]))),
                    backgroundColor: Colors.green),
              );
            },
            child: Text(tr.translate("Save")),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String planNameKey, AppLocalizations tr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.watch<ThemeProvider>().isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        title: Text(tr.translate("Delete Plan?"),
            style: const TextStyle(color: Colors.red)),
        content: Text(tr
            .translate("Remove '%s' permanently?")
            .replaceAll("%s", tr.translate(planNameKey))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.translate("Cancel"))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(tr
                        .translate("%s deleted!")
                        .replaceAll("%s", tr.translate(planNameKey))),
                    backgroundColor: Colors.red),
              );
            },
            child: Text(tr.translate("Delete")),
          ),
        ],
      ),
    );
  }
}
