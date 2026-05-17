import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/habit_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';
//listens to auth state provider which trakcs if user is logged in or out in real time,
//uses conditional routing pattern using riverpods asyncvalue, synchronizes the UI with auth state
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const Scaffold(
        body: Center(child: Text('Auth error')),
      ),
      data: (user) => user != null
          ? const DashboardScreen()
          : const LoginScreen(),
    );
  }
}