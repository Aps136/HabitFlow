import 'package:flutter/material.dart';

enum HabitCategory {
  health,
  fitness,
  learning,
  mindfulness,
  productivity,
  social,
  finance,
  creativity,
  other,
}

extension HabitCategoryExtension on HabitCategory {
  String get label {
    switch (this) {
      case HabitCategory.health: return 'Health';
      case HabitCategory.fitness: return 'Fitness';
      case HabitCategory.learning: return 'Learning';
      case HabitCategory.mindfulness: return 'Mindfulness';
      case HabitCategory.productivity: return 'Productivity';
      case HabitCategory.social: return 'Social';
      case HabitCategory.finance: return 'Finance';
      case HabitCategory.creativity: return 'Creativity';
      case HabitCategory.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.health: return '🏥';
      case HabitCategory.fitness: return '💪';
      case HabitCategory.learning: return '📚';
      case HabitCategory.mindfulness: return '🧘';
      case HabitCategory.productivity: return '⚡';
      case HabitCategory.social: return '👥';
      case HabitCategory.finance: return '💰';
      case HabitCategory.creativity: return '🎨';
      case HabitCategory.other: return '✨';
    }
  }

  Color get color {
    switch (this) {
      case HabitCategory.health: return const Color(0xFF4CAF50);
      case HabitCategory.fitness: return const Color(0xFFFF5722);
      case HabitCategory.learning: return const Color(0xFF2196F3);
      case HabitCategory.mindfulness: return const Color(0xFF9C27B0);
      case HabitCategory.productivity: return const Color(0xFFE91E8C);
      case HabitCategory.social: return const Color(0xFF00BCD4);
      case HabitCategory.finance: return const Color(0xFFFFD700);
      case HabitCategory.creativity: return const Color(0xFFFF9800);
      case HabitCategory.other: return const Color(0xFF607D8B);
    }
  }
}