// lib/features/admin/presentation/detailed_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';

class DetailedAnalyticsScreen extends StatefulWidget {
  const DetailedAnalyticsScreen({super.key, required AppBar appBar, required DefaultTabController body});

  @override
  State<DetailedAnalyticsScreen> createState() => _DetailedAnalyticsScreenState();
}

class _DetailedAnalyticsScreenState extends State<DetailedAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final background = isDark ? const Color(0xFF121212) : Colors.grey[50]!;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          tr.translate("Detailed Analytics"),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(text: tr.translate("Revenue")),
            Tab(text: tr.translate("Members")),
            Tab(text: tr.translate("Plans")),
            Tab(text: tr.translate("Trainers")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRevenueTab(isDark, cardColor, textColor),
          _buildMembersTab(isDark, cardColor, textColor),
          _buildPlansTab(isDark, cardColor, textColor),
          _buildTrainersTab(isDark, cardColor, textColor),
        ],
      ),
    );
  }

  Widget _buildRevenueTab(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatCard("Total Revenue", "\$48,920", "+28.5%", Colors.green, isDark, cardColor, textColor),
          const SizedBox(height: 24),
          _buildBarChart(
            title: "Monthly Revenue 2025",
            data: [8000, 9500, 11000, 12500, 14000, 15800, 17200, 18800, 19500, 21000, 22500, 23920],
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          _buildLineChart(
            title: "Revenue Trend",
            spots: const [
              FlSpot(0, 8),
              FlSpot(1, 9.5),
              FlSpot(2, 11),
              FlSpot(3, 12.5),
              FlSpot(4, 14),
              FlSpot(5, 15.8),
              FlSpot(6, 17.2),
              FlSpot(7, 18.8),
              FlSpot(8, 19.5),
              FlSpot(9, 21),
              FlSpot(10, 22.5),
              FlSpot(11, 23.92),
            ],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatCard("Active Members", "1,248", "+18.3%", Colors.blue, isDark, cardColor, textColor),
          const SizedBox(height: 24),
          _buildLineChart(
            title: "Member Growth",
            spots: const [
              FlSpot(0, 800),
              FlSpot(1, 880),
              FlSpot(2, 920),
              FlSpot(3, 1050),
              FlSpot(4, 1120),
              FlSpot(5, 1248),
            ],
            color: Colors.blue,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatCard("Most Popular Plan", "Premium", "45% of users", Colors.deepPurple, isDark, cardColor, textColor),
          const SizedBox(height: 24),
          _buildPieChart(isDark),
        ],
      ),
    );
  }

  Widget _buildTrainersTab(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatCard("Top Trainer", "Alex Morgan", "98% rating", Colors.orange, isDark, cardColor, textColor),
          const SizedBox(height: 24),
          _buildBarChart(
            title: "Trainer Performance",
            data: [95, 92, 88, 85, 80],
            labels: ["Alex", "Sarah", "Mike", "Emma", "John"],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // REUSABLE STAT CARD
  Widget _buildStatCard(String title, String value, String subtitle, Color accent, bool isDark, Color cardColor, Color textColor) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isDark ? 0 : 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 16)),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: accent)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // BAR CHART
  Widget _buildBarChart({required String title, required List<double> data, List<String>? labels, required bool isDark}) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isDark ? 0 : 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.reduce((a, b) => a > b ? a : b) + 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (labels != null && index < labels.length) {
                            return Text(labels[index], style: const TextStyle(fontSize: 12));
                          }
                          return Text(['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][index], style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(toY: e.value, color: Colors.deepPurple, width: 20, borderRadius: BorderRadius.circular(8))],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LINE CHART
  Widget _buildLineChart({required String title, required List<FlSpot> spots, Color color = Colors.deepPurple, required bool isDark}) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isDark ? 0 : 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
                  minX: 0,
                  maxX: spots.length - 1.toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 5,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PIE CHART
  Widget _buildPieChart(bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isDark ? 0 : 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Plan Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 45, color: Colors.deepPurple, title: "Premium\n45%", titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    PieChartSectionData(value: 30, color: Colors.orange, title: "Basic\n30%", titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    PieChartSectionData(value: 25, color: Colors.green, title: "Elite\n25%", titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                  centerSpaceRadius: 50,
                  sectionsSpace: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}