import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../core/theme.dart';
import '../models/habit.dart';
import '../provider/habit_provider.dart';
import '../screens/habits/add_habit_screen.dart';

class HabitCard extends ConsumerStatefulWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final habit = widget.habit;
    // Allow toggle (check OR uncheck) always — remove the restriction
    final wasCompleted = habit.isCompletedToday;
    await ref.read(firestoreServiceProvider).toggleCompletion(habit);
    if (!wasCompleted && mounted) {
      _confetti.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final priorityColor = {
      HabitPriority.high: AppTheme.error,
      HabitPriority.medium: AppTheme.warning,
      HabitPriority.low: AppTheme.success,
    }[habit.priority]!;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 18,
          colors: const [
            AppTheme.primary,
            AppTheme.accent,
            Colors.white,
            AppTheme.warning
          ],
          shouldLoop: false,
        ),
        Dismissible(
          key: Key(habit.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: Text('Delete "${habit.name}"?',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 16)),
                content: Text('This cannot be undone.',
                    style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete',
                          style: TextStyle(color: AppTheme.error))),
                ],
              ),
            );
          },
          onDismissed: (_) {
            ref
                .read(firestoreServiceProvider)
                .deleteHabit(habit.userId, habit.id);
          },
          child: GestureDetector(
            onLongPress: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddHabitScreen(existingHabit: habit)),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: habit.isCompletedToday
                    ? AppTheme.primary.withOpacity(0.08)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: habit.isCompletedToday
                      ? AppTheme.primary.withOpacity(0.4)
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: habit.isCompletedToday
                    ? [BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 16)]
                    : [],
              ),
              // ── use a Row instead of ListTile to avoid overflow ──
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Check circle
                    GestureDetector(
                      onTap: _toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: habit.isCompletedToday
                              ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.accent])
                              : null,
                          border: Border.all(
                            color: habit.isCompletedToday
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            width: 2,
                          ),
                        ),
                        child: habit.isCompletedToday
                            ? const Icon(Icons.check,
                            color: Colors.white, size: 22)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            habit.name,
                            style: GoogleFonts.poppins(
                              color: habit.isCompletedToday
                                  ? AppTheme.textSecondary
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: habit.isCompletedToday
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppTheme.textSecondary,
                            ),
                          ),
                          if (habit.description.isNotEmpty)
                            Text(
                              habit.description,
                              style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Text('🔥',
                                  style: TextStyle(fontSize: 11)),
                              Text(' ${habit.streak} streak',
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 6),
                              Text('⚡ ${habit.xpPoints} XP',
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.accent,
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Priority badge + edit — fixed height, no overflow
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            habit.priority.name.toUpperCase(),
                            style: TextStyle(
                                color: priorityColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            habit.frequency.name,
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AddHabitScreen(existingHabit: habit)),
                          ),
                          child: const Icon(Icons.edit_outlined,
                              color: AppTheme.textSecondary, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}