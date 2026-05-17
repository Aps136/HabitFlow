import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../provider/habit_provider.dart';
import '../../provider/theme_provider.dart';
import '../../provider/notification_provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeModeProvider);
    final notifEnabled = ref.watch(notificationEnabledProvider);
    final habitsAsync = ref.watch(habitsStreamProvider);
    final totalXp = ref.watch(totalXpProvider);

    // Safe name and initial
    final String displayName = (user?.displayName != null && user!.displayName!.isNotEmpty) 
        ? user.displayName! 
        : (user?.email != null && user!.email!.isNotEmpty) 
            ? user.email!.split('@')[0] 
            : 'User';
            
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Avatar
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 16)
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(displayName,
                  style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(user?.email ?? '',
                  style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),

              // XP badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('⚡ $totalXp XP Total',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
              const SizedBox(height: 8),
              Text('XP = habits completed × 10 + streak days × 5',
                  style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary, fontSize: 11)),

              const SizedBox(height: 28),

              // Stats
              habitsAsync.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (habits) => Row(
                  children: [
                    _statCard(context, '${habits.length}', 'Habits'),
                    const SizedBox(width: 12),
                    _statCard(
                        context,
                        habits.isEmpty
                            ? '0'
                            : '${habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b)}',
                        'Best Streak 🔥'),
                    const SizedBox(width: 12),
                    _statCard(
                        context,
                        habits.isEmpty
                            ? '0%'
                            : '${(habits.fold<double>(0, (sum, h) => sum + h.completionPercentage) / habits.length).clamp(0, 100).toStringAsFixed(0)}%',
                        'Avg Completion'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Settings section
              _sectionTitle(context, 'Preferences'),
              const SizedBox(height: 10),

              _settingsTile(
                context,
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                iconColor: AppTheme.accent,
                title: 'Dark Mode',
                subtitle: isDark ? 'Switch to light theme' : 'Switch to dark theme',
                trailing: Switch(
                  value: isDark,
                  activeColor: AppTheme.primary,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                ),
              ),
              const SizedBox(height: 10),

              _settingsTile(
                context,
                icon: Icons.notifications_outlined,
                iconColor: AppTheme.warning,
                title: 'Notifications',
                subtitle: notifEnabled
                    ? 'Daily habit reminders ON'
                    : 'Tap to enable reminders',
                trailing: Switch(
                  value: notifEnabled,
                  activeColor: AppTheme.primary,
                  onChanged: (_) =>
                      ref.read(notificationEnabledProvider.notifier).toggle(),
                ),
              ),
              const SizedBox(height: 28),

              // Weekly habit explanation
              _sectionTitle(context, 'How habits work'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('📅 Daily habits',
                        'Must be completed every day to maintain streak'),
                    const SizedBox(height: 8),
                    _infoRow('📆 Weekly habits',
                        'Complete once any day within the week — streak counts week by week'),
                    const SizedBox(height: 8),
                    _infoRow('⚡ XP system',
                        '10 XP per completion, 5 XP per streak day, 1.5x for high priority'),
                    const SizedBox(height: 8),
                    _infoRow('🔥 Streaks',
                        'Streak stays alive if you completed yesterday or today'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Sign out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        title: Text('Sign out?',
                            style: GoogleFonts.poppins(
                                color:
                                Theme.of(context).colorScheme.onSurface)),
                        content: Text('You can sign back in anytime.',
                            style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sign out',
                                  style:
                                  TextStyle(color: AppTheme.primary))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref.read(authServiceProvider).signOut();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
                  label: Text('Sign Out',
                      style: GoogleFonts.poppins(color: AppTheme.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.error.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.poppins(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(BuildContext context,
      {required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required Widget trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 16,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _infoRow(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(desc,
              style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ),
      ],
    );
  }
}