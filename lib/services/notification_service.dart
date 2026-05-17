import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
//talks to flutter local notificaions plugin on ur phone, schedules reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'habit_reminders',
    'Habit Reminders',
    description: 'Daily reminders to complete your habits',
    importance: Importance.high,
  );

  Future<void> init() async {
    // FIXED: Brackets <...> must be on the same line, attached to the method name
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios));

    // FIXED: Brackets <...> attached here too
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    if (!value) await cancelAll();
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Habit reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<void> showTestNotification() async {
    await showImmediateNotification(
      id: 0,
      title: '⚡ HabitFlow',
      body: 'Notifications enabled! You will get daily reminders. 🎉',
    );
  }

  Future<void> showMotivationalNotification() async {
    if (!await isEnabled()) return;
    await showImmediateNotification(
      id: 999,
      title: '🔥 Keep your streak alive!',
      body: 'Don\'t forget to complete your habits today.',
    );
  }

  // Schedule notification at a specific number of seconds from now
  // This is what you use for demo: pass secondsFromNow: 60 for 1 minute
  Future<void> scheduleNotificationInSeconds({
    required int id,
    required String habitName,
    required int secondsFromNow,
  }) async {
    if (!await isEnabled()) return;

    // Calculate the future time
    final scheduledTime =
    DateTime.now().add(Duration(seconds: secondsFromNow));

    // Use periodically — workaround without timezone package
    // Show delayed notification using Future.delayed (works for demo)
    Future.delayed(Duration(seconds: secondsFromNow), () async {
      await showImmediateNotification(
        id: id,
        title: '⏰ Habit Reminder',
        body: 'Time to complete: $habitName 💪',
      );
    });
  }

  // Schedule based on HH:mm time string
  // Calculates seconds until that time today and fires then
  Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required String timeStr, // "HH:mm"
  }) async {
    if (!await isEnabled()) return;

    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    var scheduledTime =
    DateTime(now.year, now.month, now.day, hour, minute);

    // If time already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final secondsUntil = scheduledTime.difference(now).inSeconds;

    await scheduleNotificationInSeconds(
      id: id,
      habitName: habitName,
      secondsFromNow: secondsUntil,
    );
  }

  Future<void> cancelHabitReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}