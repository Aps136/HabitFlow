import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/habit.dart';
import '../../models/habit_category.dart';

class HabitTemplate {
  final String name;
  final String description;
  final HabitCategory category;
  final HabitPriority priority;
  final HabitFrequency frequency;
  final int colorIndex;

  const HabitTemplate({
    required this.name,
    required this.description,
    required this.category,
    required this.priority,
    required this.frequency,
    required this.colorIndex,
  });
}

const List<HabitTemplate> habitTemplates = [
  // Health
  HabitTemplate(name: 'Drink 8 glasses of water', description: 'Stay hydrated throughout the day', category: HabitCategory.health, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 3),
  HabitTemplate(name: 'Sleep 8 hours', description: 'Get quality sleep every night', category: HabitCategory.health, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 2),
  HabitTemplate(name: 'Take vitamins', description: 'Daily vitamin and supplement intake', category: HabitCategory.health, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 3),
  HabitTemplate(name: 'No junk food', description: 'Avoid processed and junk food', category: HabitCategory.health, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 5),

  // Fitness
  HabitTemplate(name: '30 min workout', description: 'Any form of exercise for 30 minutes', category: HabitCategory.fitness, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 5),
  HabitTemplate(name: '10,000 steps', description: 'Walk at least 10,000 steps today', category: HabitCategory.fitness, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 5),
  HabitTemplate(name: 'Morning stretch', description: '10 minutes of stretching after waking up', category: HabitCategory.fitness, priority: HabitPriority.low, frequency: HabitFrequency.daily, colorIndex: 4),
  HabitTemplate(name: 'Gym session', description: 'Full workout at the gym', category: HabitCategory.fitness, priority: HabitPriority.high, frequency: HabitFrequency.weekly, colorIndex: 5),

  // Mindfulness
  HabitTemplate(name: 'Meditate 10 mins', description: 'Daily mindfulness meditation', category: HabitCategory.mindfulness, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 1),
  HabitTemplate(name: 'Gratitude journal', description: 'Write 3 things you are grateful for', category: HabitCategory.mindfulness, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 1),
  HabitTemplate(name: 'Digital detox hour', description: 'One hour without screens before bed', category: HabitCategory.mindfulness, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 6),
  HabitTemplate(name: 'Deep breathing', description: '5 minutes of deep breathing exercises', category: HabitCategory.mindfulness, priority: HabitPriority.low, frequency: HabitFrequency.daily, colorIndex: 1),

  // Learning
  HabitTemplate(name: 'Read 20 pages', description: 'Read at least 20 pages of any book', category: HabitCategory.learning, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 2),
  HabitTemplate(name: 'Learn a new word', description: 'Expand your vocabulary daily', category: HabitCategory.learning, priority: HabitPriority.low, frequency: HabitFrequency.daily, colorIndex: 2),
  HabitTemplate(name: 'Online course 30 mins', description: 'Study an online course for 30 minutes', category: HabitCategory.learning, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 2),
  HabitTemplate(name: 'Practice language', description: 'Practice a foreign language', category: HabitCategory.learning, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 2),

  // Productivity
  HabitTemplate(name: 'Plan tomorrow', description: 'Write your task list for the next day', category: HabitCategory.productivity, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 0),
  HabitTemplate(name: 'Inbox zero', description: 'Clear your email inbox completely', category: HabitCategory.productivity, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 0),
  HabitTemplate(name: 'Deep work 2 hours', description: 'Two hours of focused, distraction-free work', category: HabitCategory.productivity, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 0),
  HabitTemplate(name: 'Weekly review', description: 'Review goals and progress every week', category: HabitCategory.productivity, priority: HabitPriority.high, frequency: HabitFrequency.weekly, colorIndex: 0),

  // Finance
  HabitTemplate(name: 'Track expenses', description: 'Log all spending for the day', category: HabitCategory.finance, priority: HabitPriority.high, frequency: HabitFrequency.daily, colorIndex: 7),
  HabitTemplate(name: 'No impulse buying', description: 'Avoid unplanned purchases', category: HabitCategory.finance, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 7),
  HabitTemplate(name: 'Save ₹100', description: 'Put away at least ₹100 every day', category: HabitCategory.finance, priority: HabitPriority.medium, frequency: HabitFrequency.daily, colorIndex: 7),

  // Social
  HabitTemplate(name: 'Call a friend/family', description: 'Reach out to someone you care about', category: HabitCategory.social, priority: HabitPriority.medium, frequency: HabitFrequency.weekly, colorIndex: 6),
  HabitTemplate(name: 'Random act of kindness', description: 'Do something kind for someone today', category: HabitCategory.social, priority: HabitPriority.low, frequency: HabitFrequency.daily, colorIndex: 6),
];

class HabitTemplatesScreen extends StatefulWidget {
  const HabitTemplatesScreen({super.key});

  @override
  State<HabitTemplatesScreen> createState() => _HabitTemplatesScreenState();
}

class _HabitTemplatesScreenState extends State<HabitTemplatesScreen> {
  HabitCategory? _selectedCategory;

  List<HabitTemplate> get _filtered => _selectedCategory == null
      ? habitTemplates
      : habitTemplates.where((t) => t.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Templates',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                // All chip
                GestureDetector(
                  onTap: () => setState(() => _selectedCategory = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: _selectedCategory == null
                          ? const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accent])
                          : null,
                      color: _selectedCategory == null ? null : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('All',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                // Category chips
                ...HabitCategory.values.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() =>
                    _selectedCategory = selected ? null : cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? cat.color.withOpacity(0.3)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: selected ? cat.color : Colors.transparent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(cat.label,
                              style: GoogleFonts.poppins(
                                  color: selected ? cat.color : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Templates list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final template = _filtered[i];
                final habitColor = Color(Habit.colorPalette[template.colorIndex]);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: template.category.color.withOpacity(0.3)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: template.category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(template.category.emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    title: Text(template.name,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(template.description,
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary, fontSize: 11)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _chip(template.category.label,
                                template.category.color),
                            const SizedBox(width: 6),
                            _chip(template.frequency.name,
                                AppTheme.textSecondary),
                            const SizedBox(width: 6),
                            _chip(template.priority.name, _priorityColor(template.priority)),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.pop(context, template),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Use',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }

  Color _priorityColor(HabitPriority p) {
    switch (p) {
      case HabitPriority.high: return AppTheme.error;
      case HabitPriority.medium: return AppTheme.warning;
      case HabitPriority.low: return AppTheme.success;
    }
  }
}