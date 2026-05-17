import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

final notificationEnabledProvider =
StateNotifierProvider<NotificationNotifier, bool>((ref) {
  return NotificationNotifier();
});
//manages the logic of updating the UI state and calling the service req
class NotificationNotifier extends StateNotifier<bool> {
  NotificationNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await NotificationService().isEnabled();
  }
//async loads the saved preference from devices storage
  Future<void> toggle() async {
    final newValue = !state;
    // Update state first so UI responds immediately
    state = newValue;
    await NotificationService().setEnabled(newValue);
    if (newValue) {
      await NotificationService().showTestNotification();
    }
  }
}