import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../provider/habit_provider.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/stats_row.dart';
import '../calendar/inline_calendar.dart';
import '../habits/add_habit_screen.dart';
import '../analytics/analytics_screen.dart';
import '../../widgets/quote_card.dart';
import '../profile/profile_screen.dart';
//indexedstack - handles 3 screens navigation
//slivers, customscrollview
//bottom navigation bar

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text('HabitFlow',
                style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
              top: BorderSide(color: AppTheme.primary.withOpacity(0.2))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle:
          GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddHabitScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('New Habit',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      )
          : null,
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsStreamProvider);
    final user = ref.watch(currentUserProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good ${_greeting()}! 👋',
                    style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary, fontSize: 14)),
                Text(
                    user?.displayName ??
                        user?.email?.split('@')[0] ??
                        'User',
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: habitsAsync.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (habits) => StatsRow(habits: habits),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: InlineCalendar()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text("Today's Habits",
                style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        habitsAsync.when(
          loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverToBoxAdapter(
              child: Center(
                  child: Text('$e',
                      style: const TextStyle(color: AppTheme.error)))),
          data: (habits) {
            if (habits.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    const Text('🌱', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text('No habits yet',
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('Tap + to create your first habit',
                        style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary)),
                  ]),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) => HabitCard(habit: habits[i]),
                  childCount: habits.length,
                ),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
        // Add after the StatsRow SliverToBoxAdapter
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: QuoteCard()),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}