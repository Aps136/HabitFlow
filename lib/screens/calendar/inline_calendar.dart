import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/habit.dart';
import '../../core/theme.dart';
import '../../provider/habit_provider.dart';
//consumerstateful widget, handles 2 states : local : currently focused month, specific day
//and global state - listening to habitstreamprovider which habits were completed on which dates

class InlineCalendar extends ConsumerStatefulWidget {
  const InlineCalendar({super.key});
  @override
  ConsumerState<InlineCalendar> createState() => _InlineCalendarState();
}

class _InlineCalendarState extends ConsumerState<InlineCalendar> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsStreamProvider);

    return habitsAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (habits) {
        final Map<String, List<String>> completionMap = {};
        for (var habit in habits) {
          for (var date in habit.completedDates) {
            completionMap[date] = [...(completionMap[date] ?? []), habit.name];
          }
        }

        final selectedStr =
        _selectedDay == null ? null : Habit.dateToString(_selectedDay!);
        final selectedHabits =
        selectedStr != null ? (completionMap[selectedStr] ?? []) : <String>[];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              // Month header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                      onPressed: () => setState(() {
                        _focusedMonth =
                            DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                        _selectedDay = null;
                      }),
                    ),
                    Text(_monthName(_focusedMonth),
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                      onPressed: () => setState(() {
                        _focusedMonth =
                            DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                        _selectedDay = null;
                      }),
                    ),
                  ],
                ),
              ),

              // Day labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: GoogleFonts.poppins(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 4),

              // Calendar grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Column(children: _buildCalendarRows(completionMap, habits)),
              ),

              // Selected day detail
              if (_selectedDay != null)
                _buildSelectedDayPanel(_selectedDay!, selectedHabits, habits),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCalendarRows(
      Map<String, List<String>> completionMap, List<Habit> habits) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7;

    final List<Widget> rows = [];
    List<Widget> week = [];

    for (int i = 0; i < startOffset; i++) {
      week.add(const Expanded(child: SizedBox(height: 36)));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final dateStr = Habit.dateToString(date);
      final completedCount = completionMap[dateStr]?.length ?? 0;
      final isToday = dateStr == Habit.dateToString(DateTime.now());
      final isSelected =
          _selectedDay != null && Habit.dateToString(_selectedDay!) == dateStr;
      final isFuture = date.isAfter(DateTime.now());

      week.add(Expanded(
        child: GestureDetector(
          onTap: isFuture ? null : () => setState(() => _selectedDay = date),
          child: Container(
            height: 36,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(colors: [AppTheme.primary, AppTheme.accent])
                  : null,
              color: isSelected
                  ? null
                  : isToday
                  ? AppTheme.primary.withOpacity(0.2)
                  : null,
              border: isToday && !isSelected
                  ? Border.all(color: AppTheme.primary, width: 1.5)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text('$day',
                    style: GoogleFonts.poppins(
                      color: isFuture
                          ? AppTheme.textSecondary.withOpacity(0.3)
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    )),
                if (completedCount > 0 && !isSelected)
                  Positioned(
                    bottom: 3,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: completedCount == habits.length && habits.isNotEmpty
                            ? AppTheme.success
                            : AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ));

      if (week.length == 7) {
        rows.add(Row(children: week));
        week = [];
      }
    }

    if (week.isNotEmpty) {
      while (week.length < 7) week.add(const Expanded(child: SizedBox(height: 36)));
      rows.add(Row(children: week));
    }

    return rows;
  }

  Widget _buildSelectedDayPanel(
      DateTime day, List<String> completedNames, List<Habit> habits) {
    final isToday = Habit.dateToString(day) == Habit.dateToString(DateTime.now());
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isToday ? 'Today' : _formatDate(day),
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${completedNames.length}/${habits.length}',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('No habits yet',
                  style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary, fontSize: 12)),
            )
          else
            ...habits.map((habit) {
              final done = completedNames.contains(habit.name);
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: done ? AppTheme.primary : AppTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(habit.name,
                        style: GoogleFonts.poppins(
                            color: done ? Colors.white : AppTheme.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _monthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}