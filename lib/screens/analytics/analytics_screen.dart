import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../provider/habit_provider.dart';
import '../../models/habit_category.dart';
import '../../models/habit.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (habits) {
          final now = DateTime.now();

          final barGroups = List.generate(7, (i) {
            final day = now.subtract(Duration(days: 6 - i));
            final dayStr = Habit.dateToString(day);
            final count = habits.where((h) => h.completedDates.contains(dayStr)).length.toDouble();
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: count,
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(8),
              )
            ]);
          });

          // Calculate daily counts first
          final Map<DateTime, int> dailyCounts = {};
          for (var habit in habits) {
            for (var dateStr in habit.completedDates) {
              try {
                final date = DateTime.parse(dateStr);
                final normalizedDate = DateTime(date.year, date.month, date.day);
                dailyCounts[normalizedDate] = (dailyCounts[normalizedDate] ?? 0) + 1;
              } catch (_) {}
            }
          }

          // Map counts to levels 1-4 based on percentage of habits completed
          final Map<DateTime, int> heatmapData = {};
          if (habits.isNotEmpty) {
            dailyCounts.forEach((date, count) {
              final percentage = count / habits.length;
              if (percentage <= 0.25) {
                heatmapData[date] = 1;
              } else if (percentage <= 0.5) {
                heatmapData[date] = 2;
              } else if (percentage <= 0.75) {
                heatmapData[date] = 3;
              } else {
                heatmapData[date] = 4;
              }
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Weekly bar chart ──────────────────────────
                Text('Weekly Overview',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _glassCard(
                  child: SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
                      barGroups: barGroups,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              final day = now.subtract(Duration(days: 6 - val.toInt()));
                              const labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                              return Text(labels[day.weekday - 1],
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11));
                            },
                          ),
                        ),
                      ),
                    )),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Heatmap ───────────────────────────────────
                Text('Completion Heatmap',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _glassCard(
                  child: HeatMapCalendar(
                    datasets: heatmapData,
                    colorMode: ColorMode.color,
                    defaultColor: AppTheme.surfaceLight,
                    textColor: Colors.white,
                    showColorTip: false,
                    colorsets: const {
                      1: Color(0xFFFF80AB), // Lightest
                      2: Color(0xFFE91E8C),
                      3: Color(0xFFAD1457),
                      4: Color(0xFF6A0572), // Darkest
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // ── Per habit stats ───────────────────────────
                Text('Per Habit Stats',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ...habits.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(h.category.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(h.name,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                            Text('🔥 ${h.streak}d',
                                style: const TextStyle(color: AppTheme.warning, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text('⚡ ${h.xpPoints} XP',
                                style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _progressRow('Completion (30d)', h.completionPercentage, AppTheme.primary),
                        const SizedBox(height: 6),
                        _progressRow('Consistency', h.consistencyScore, AppTheme.accent),
                      ],
                    ),
                  ),
                )),

                const SizedBox(height: 28),

                // ── By Category ───────────────────────────────
                Text('By Category',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                ...HabitCategory.values.map((cat) {
                  final catHabits = habits.where((h) => h.category == cat).toList();
                  if (catHabits.isEmpty) return const SizedBox();
                  final avgCompletion = catHabits
                      .map((h) => h.completionPercentage)
                      .fold<double>(0, (sum, val) => sum + val) / catHabits.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _glassCard(
                      child: Row(
                        children: [
                          Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(cat.label,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                    Text('${catHabits.length} habit${catHabits.length > 1 ? "s" : ""}',
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.textSecondary, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: (avgCompletion / 100).clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor: AppTheme.surfaceLight,
                                    valueColor: AlwaysStoppedAnimation(cat.color),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text('${avgCompletion.toStringAsFixed(0)}% avg completion',
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.textSecondary, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _progressRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary, fontSize: 11)),
            Text('${value.toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                    color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}