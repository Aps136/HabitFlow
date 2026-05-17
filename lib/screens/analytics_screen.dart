import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../provider/habit_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (habits) {
        final now = DateTime.now();

        final barGroups = List.generate(7, (i) {
          final day = now.subtract(Duration(days: 6 - i));
          final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          final count = habits
              .where((h) => h.completedDates.contains(dayStr))
              .length
              .toDouble();
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


        final Map<DateTime, int> heatmapData = {};
        for (var habit in habits) {
          for (var dateStr in habit.completedDates) {
            try {
              final date = DateTime.parse(dateStr);
              // Create a new DateTime using ONLY year, month, and day
              final normalizedDate = DateTime(date.year, date.month, date.day);

              heatmapData[normalizedDate] = (heatmapData[normalizedDate] ?? 0) + 1;
            } catch (_) {
              // Handle or log parsing errors
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Weekly Overview',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20)),
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
                          const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(labels[day.weekday - 1],
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11));
                        },
                      ),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 28),
              Text('Completion Heatmap',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20)),
                child: HeatMapCalendar(
                  datasets: heatmapData,
                  colorMode: ColorMode.color,
                  defaultColor: AppTheme.surfaceLight,
                  textColor: Colors.white,
                  showColorTip: false,
                  colorsets: const {
                    1: Color(0xFFFF80AB),
                    2: Color(0xFFE91E8C),
                    3: Color(0xFFAD1457),
                    4: Color(0xFF6A0572),
                  },
                ),
              ),
              const SizedBox(height: 28),
              Text('Habit Stats',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...habits.map((h) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(h.name,
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Row(children: [
                          Text('🔥 ${h.streak}d',
                              style: const TextStyle(
                                  color: AppTheme.warning, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text('⚡ ${h.xpPoints} XP',
                              style: const TextStyle(
                                  color: AppTheme.accent, fontSize: 12)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Completion %
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('Completion',
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary, fontSize: 11)),
                        const Spacer(),
                        Text('${h.completionPercentage.toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: h.completionPercentage / 100,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Consistency score
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('Consistency score',
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary, fontSize: 11)),
                        const Spacer(),
                        Text('${h.consistencyScore.toStringAsFixed(0)}/100',
                            style: GoogleFonts.poppins(
                                color: AppTheme.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: h.consistencyScore / 100,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}