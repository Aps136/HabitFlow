import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../models/habit.dart';
import '../widgets/glass_card.dart';
import 'dart:ui';
class StatsRow extends StatelessWidget {
  final List<Habit> habits;
  const StatsRow({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final completed = habits.where((h) => h.isCompletedToday).length;
    final total = habits.length;
    final bestStreak = habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        _stat('$completed/$total', 'Today', Icons.check_circle_outline, AppTheme.primary),
        const SizedBox(width: 12),
        _stat('🔥 $bestStreak', 'Best Streak', Icons.local_fire_department, AppTheme.warning),
        const SizedBox(width: 12),
        _stat('$total', 'Habits', Icons.list_alt_rounded, AppTheme.accent),
      ],
    );
  }

  // Find _stat widget method, replace the Container with:
  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              children: [
                Text(value,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 2),
                Text(label,
                    style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}