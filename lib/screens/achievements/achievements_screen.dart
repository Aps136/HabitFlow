import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/achievement.dart';
import '../../provider/habit_provider.dart';
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});
//consumer widget - riverpod widget allows screen to listen to habitstreamprovider
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const SizedBox(),
        data: (habits) {
          final achievements = Achievement.defaultAchievements().map((a) {
            bool unlocked = false;
            if (a.id == 'first_habit') unlocked = habits.isNotEmpty;
            if (a.id == 'streak_7') unlocked = habits.any((h) => h.streak >= 7);
            if (a.id == 'streak_30') unlocked = habits.any((h) => h.streak >= 30);
            if (a.id == 'five_habits') unlocked = habits.length >= 5;
            if (a.id == 'perfect_week') {
              // check if any 7-day window all habits were completed (simplified)
              unlocked = habits.isNotEmpty && habits.every((h) => h.streak >= 7);
            }
            return Achievement(
              id: a.id, title: a.title, description: a.description,
              icon: a.icon, unlocked: unlocked,
            );
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.1,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, i) {
              final a = achievements[i];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: a.unlocked ? AppTheme.primary.withOpacity(0.6) : AppTheme.surfaceLight,
                    width: 1.5,
                  ),
                  boxShadow: a.unlocked
                      ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 12)]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(a.unlocked ? a.icon : '🔒',
                        style: TextStyle(fontSize: 36, color: a.unlocked ? null : Colors.grey)),
                    const SizedBox(height: 10),
                    Text(a.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: a.unlocked ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(a.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 10)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}