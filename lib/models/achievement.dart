class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    this.unlockedAt,
  });

  static List<Achievement> defaultAchievements() {
    return [
      Achievement(id: 'first_habit', title: 'First Step', description: 'Create your first habit', icon: '🌱', unlocked: false),
      Achievement(id: 'streak_7', title: 'Week Warrior', description: '7 day streak on any habit', icon: '🔥', unlocked: false),
      Achievement(id: 'streak_30', title: 'Monthly Master', description: '30 day streak', icon: '👑', unlocked: false),
      Achievement(id: 'five_habits', title: 'Habit Builder', description: 'Create 5 habits', icon: '⚡', unlocked: false),
      Achievement(id: 'perfect_week', title: 'Perfect Week', description: 'Complete all habits for 7 days', icon: '🏆', unlocked: false),
    ];
  }
}