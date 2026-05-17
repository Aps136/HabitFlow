import 'package:cloud_firestore/cloud_firestore.dart';
import 'habit_category.dart';

enum HabitFrequency { daily, weekly }
enum HabitPriority { high, medium, low }

class Habit {
  final String id;
  final String userId;
  final String name;
  final String description;
  final HabitPriority priority;
  final HabitFrequency frequency;
  final HabitCategory category;
  final List<String> completedDates;
  final String? reminderTime; // "HH:mm" format e.g. "08:30"
  final int colorIndex; // index into our color palette
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.priority,
    required this.frequency,
    required this.category,
    required this.completedDates,
    this.reminderTime,
    this.colorIndex = 0,
    required this.createdAt,
  });

  static const List<int> colorPalette = [
    0xFFE91E8C, // pink (default)
    0xFF9C27B0, // purple
    0xFF2196F3, // blue
    0xFF4CAF50, // green
    0xFFFF9800, // orange
    0xFFFF5722, // red-orange
    0xFF00BCD4, // cyan
    0xFFFFD700, // gold
  ];

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      priority: HabitPriority.values.firstWhere(
            (e) => e.name == (map['priority'] ?? 'medium'),
        orElse: () => HabitPriority.medium,
      ),
      frequency: HabitFrequency.values.firstWhere(
            (e) => e.name == (map['frequency'] ?? 'daily'),
        orElse: () => HabitFrequency.daily,
      ),
      category: HabitCategory.values.firstWhere(
            (e) => e.name == (map['category'] ?? 'other'),
        orElse: () => HabitCategory.other,
      ),
      completedDates: List<String>.from(map['completedDates'] ?? []),
      reminderTime: map['reminderTime'],
      colorIndex: map['colorIndex'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'priority': priority.name,
      'frequency': frequency.name,
      'category': category.name,
      'completedDates': completedDates,
      'reminderTime': reminderTime,
      'colorIndex': colorIndex,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static String dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String todayString() => Habit.dateToString(DateTime.now());
  bool get isCompletedToday => completedDates.contains(todayString());

  bool canCompleteToday() {
    if (frequency == HabitFrequency.daily) return true;
    if (completedDates.isEmpty) return true;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = Habit.dateToString(
        DateTime(weekStart.year, weekStart.month, weekStart.day));
    return !completedDates.any((d) => d.compareTo(weekStartStr) >= 0);
  }

  int get streak {
    if (completedDates.isEmpty) return 0;
    int streak = 0;
    DateTime check = DateTime.now();
    while (true) {
      final dateStr = dateToString(check);
      if (completedDates.contains(dateStr)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        if (streak == 0) {
          check = check.subtract(const Duration(days: 1));
          if (completedDates.contains(dateToString(check))) {
            streak++;
            check = check.subtract(const Duration(days: 1));
            continue;
          }
        }
        break;
      }
    }
    return streak;
  }

  double get completionPercentage {
    if (completedDates.isEmpty) return 0;
    final last30 = List.generate(30, (i) {
      final d = DateTime.now().subtract(Duration(days: i));
      return dateToString(d);
    });
    final done = completedDates.where((d) => last30.contains(d)).length;
    return (done / 30) * 100;
  }

  double get consistencyScore {
    final streakScore = (streak / 30).clamp(0.0, 1.0) * 50;
    final completionScore = (completionPercentage / 100) * 50;
    return streakScore + completionScore;
  }

  int get xpPoints {
    int points = completedDates.length * 10;
    points += streak * 5;
    if (priority == HabitPriority.high) points = (points * 1.5).toInt();
    return points;
  }
}