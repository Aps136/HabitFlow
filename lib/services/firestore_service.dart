import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit.dart';
// manages habits - talks to firestore db, responsible for saving new habits, deleting old ones, updating when u click complete

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _habitsRef(String userId) =>
      _db.collection('users').doc(userId).collection('habits');

  Future<void> addHabit(Habit habit) async {
    await _habitsRef(habit.userId).add(habit.toMap());
  }

  Stream<List<Habit>> getHabits(String userId) {
    return _habitsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Habit.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> updateHabit(String userId, String habitId, Map<String, dynamic> data) async {
    await _habitsRef(userId).doc(habitId).update(data);
  }

  Future<void> editHabit(Habit habit) async {
    await _habitsRef(habit.userId).doc(habit.id).update({
      'name': habit.name,
      'description': habit.description,
      'priority': habit.priority.name,
      'frequency': habit.frequency.name,
      'category': habit.category.name,
      'colorIndex': habit.colorIndex,
      'reminderTime': habit.reminderTime,
    });
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    await _habitsRef(userId).doc(habitId).delete();
  }

  Future<void> toggleCompletion(Habit habit) async {
    final today = habit.todayString();
    List<String> dates = [...habit.completedDates];
    // Always allow toggle regardless of frequency — user can check/uncheck freely
    if (dates.contains(today)) {
      dates.remove(today);
    } else {
      dates.add(today);
    }
    await updateHabit(habit.userId, habit.id, {'completedDates': dates});
  }
}
