import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 本地通知：到点时即使 App 在后台也能弹系统通知
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const int _notifyId = 1001;

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    // Android 13+ 需要运行时申请通知权限
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleAt(DateTime when,
      {bool sound = true, bool vibrate = true}) async {
    await cancel();
    // 用「从现在起的时长」计算，避免时区定位问题
    final delay = when.difference(DateTime.now());
    final scheduled = tz.TZDateTime.now(tz.local).add(delay);
    await _plugin.zonedSchedule(
      _notifyId,
      '坐太久了，该站起来动一动了！',
      '建议：站立伸展 40 秒 + 远眺放松 60 秒',
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sedentary_alert',
          '久坐提醒',
          channelDescription: '久坐计时到点提醒',
          importance: Importance.max,
          priority: Priority.high,
          playSound: sound,
          enableVibration: vibrate,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel() => _plugin.cancel(_notifyId);
}
