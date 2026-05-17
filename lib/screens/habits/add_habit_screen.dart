import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/habit.dart';
import '../../models/habit_category.dart';
import '../../provider/habit_provider.dart';
import '../../services/notification_service.dart';
import 'habit_templates_screen.dart';
//creating new , editing,
//
class AddHabitScreen extends ConsumerStatefulWidget {
  final Habit? existingHabit;
  const AddHabitScreen({super.key, this.existingHabit});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late HabitPriority _priority;
  late HabitFrequency _frequency;
  late HabitCategory _category;
  late int _colorIndex;
  String? _reminderTime;
  bool _saving = false;

  bool get _isEditing => widget.existingHabit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.existingHabit;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _priority = h?.priority ?? HabitPriority.medium;
    _frequency = h?.frequency ?? HabitFrequency.daily;
    _category = h?.category ?? HabitCategory.other;
    _colorIndex = h?.colorIndex ?? 0;
    _reminderTime = h?.reminderTime;
  }

  void _applyTemplate(HabitTemplate template) {
    setState(() {
      _nameCtrl.text = template.name;
      _descCtrl.text = template.description;
      _category = template.category;
      _priority = template.priority;
      _frequency = template.frequency;
      _colorIndex = template.colorIndex;
    });
  }

  Future<void> _pickTime() async {
    TimeOfDay initial = const TimeOfDay(hour: 8, minute: 0);
    if (_reminderTime != null) {
      final parts = _reminderTime!.split(':');
      initial = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _reminderTime =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);

    final firestore = ref.read(firestoreServiceProvider);

    if (_isEditing) {
      final updated = Habit(
        id: widget.existingHabit!.id,
        userId: user.uid,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        frequency: _frequency,
        category: _category,
        colorIndex: _colorIndex,
        completedDates: widget.existingHabit!.completedDates,
        reminderTime: _reminderTime,
        createdAt: widget.existingHabit!.createdAt,
      );
      await firestore.editHabit(updated);
    } else {
      final habit = Habit(
        id: '',
        userId: user.uid,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        frequency: _frequency,
        category: _category,
        colorIndex: _colorIndex,
        completedDates: [],
        reminderTime: _reminderTime,
        createdAt: DateTime.now(),
      );
      await firestore.addHabit(habit);

      // Schedule notification if time set
      if (_reminderTime != null) {
        await NotificationService().scheduleHabitReminder(
          id: habit.name.hashCode,
          habitName: habit.name,
          timeStr: _reminderTime!,
        );
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'New Habit',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push<HabitTemplate>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HabitTemplatesScreen()),
                );
                if (result != null) _applyTemplate(result);
              },
              icon: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 18),
              label: Text('Templates',
                  style: GoogleFonts.poppins(
                      color: AppTheme.primary, fontSize: 13)),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    title: Text('Delete Habit?',
                        style: GoogleFonts.poppins(color: Colors.white)),
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
                if (confirm == true && mounted) {
                  await ref.read(firestoreServiceProvider).deleteHabit(
                      widget.existingHabit!.userId, widget.existingHabit!.id);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color strip preview
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Color(Habit.colorPalette[_colorIndex]),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),

            _label('Habit Name'),
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    hintText: 'e.g. Morning meditation')),
            const SizedBox(height: 16),

            _label('Description'),
            TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Optional description')),
            const SizedBox(height: 20),

            // Category
            _label('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HabitCategory.values.map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? cat.color.withOpacity(0.2)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected ? cat.color : Colors.transparent,
                          width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.emoji,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(cat.label,
                            style: GoogleFonts.poppins(
                                color: selected
                                    ? cat.color
                                    : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Color
            _label('Habit Color'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(Habit.colorPalette.length, (i) {
                final selected = _colorIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _colorIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: selected ? 36 : 30,
                    height: selected ? 36 : 30,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Color(Habit.colorPalette[i]),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                        BoxShadow(
                            color:
                            Color(Habit.colorPalette[i]).withOpacity(0.5),
                            blurRadius: 8)
                      ]
                          : [],
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Priority
            _label('Priority'),
            const SizedBox(height: 8),
            Row(
              children: HabitPriority.values.map((p) {
                final colors = {
                  HabitPriority.high: AppTheme.error,
                  HabitPriority.medium: AppTheme.warning,
                  HabitPriority.low: AppTheme.success,
                };
                final selected = _priority == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors[p]!.withOpacity(0.2)
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: selected ? colors[p]! : Colors.transparent,
                              width: 1.5),
                        ),
                        child: Text(p.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selected
                                    ? colors[p]
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Frequency
            _label('Frequency'),
            const SizedBox(height: 8),
            Row(
              children: HabitFrequency.values.map((f) {
                final selected = _frequency == f;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() => _frequency = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.accent])
                              : null,
                          color: selected ? null : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(f.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Reminder time
            _label('Daily Reminder (optional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _reminderTime != null
                        ? AppTheme.primary
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_outlined,
                        color: _reminderTime != null
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _reminderTime != null
                          ? 'Remind me at $_reminderTime'
                          : 'Set reminder time',
                      style: GoogleFonts.poppins(
                        color: _reminderTime != null
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_reminderTime != null)
                      GestureDetector(
                        onTap: () => setState(() => _reminderTime = null),
                        child: const Icon(Icons.close,
                            color: AppTheme.textSecondary, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Save Changes' : 'Create Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: GoogleFonts.poppins(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500)),
  );
}