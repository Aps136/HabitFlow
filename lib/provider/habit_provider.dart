import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

//creates global access to them so u can use them w/o manual setup in any screen
final authServiceProvider = Provider((_) => AuthService());
final firestoreServiceProvider = Provider((_) => FirestoreService());

//listens in real time and automatically listens to firebase, when user logs in or out, entire app reacts instantly
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});
//if add or complete habit, UI updates in real time w/o refreshing
final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(authStateProvider).when(
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.read(firestoreServiceProvider).getHabits(user.uid);
    },
  );
});

// Total XP across all habits, recalculates the total XP whenever habits data changes
final totalXpProvider = Provider<int>((ref) {
  return ref.watch(habitsStreamProvider).maybeWhen(
    data: (habits) => habits.fold(0, (sum, h) => sum + h.xpPoints),
    orElse: () => 0,
  );
});
