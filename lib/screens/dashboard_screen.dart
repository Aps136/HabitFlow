import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../provider/habit_provider.dart';
import '../widgets/habit_card.dart';
import 'habits/add_habit_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('HabitFlow', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Text('No habits yet.\nTap + to add one!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 18)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) => HabitCard(habit: habits[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}