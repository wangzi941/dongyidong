import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地设置与打卡记录存储
class Storage {
  static late SharedPreferences p;

  static Future<void> init() async {
    p = await SharedPreferences.getInstance();
  }

  static int get interval => p.getInt('interval') ?? 40;
  static Future<void> setInterval(int v) => p.setInt('interval', v);

  static bool get sound => p.getBool('sound') ?? true;
  static Future<void> setSound(bool v) => p.setBool('sound', v);

  static bool get vibrate => p.getBool('vibrate') ?? true;
  static Future<void> setVibrate(bool v) => p.setBool('vibrate', v);

  static bool get strict => p.getBool('strict') ?? false;
  static Future<void> setStrict(bool v) => p.setBool('strict', v);

  static String get quietStart => p.getString('quietStart') ?? '22:00';
  static Future<void> setQuietStart(String v) => p.setString('quietStart', v);

  static String get quietEnd => p.getString('quietEnd') ?? '08:00';
  static Future<void> setQuietEnd(String v) => p.setString('quietEnd', v);

  /// 当前一轮的截止时间戳（毫秒），null 表示未在计时
  static int? get endAt => p.getInt('endAt');
  static Future<void> setEndAt(int? v) =>
      v == null ? p.remove('endAt') : p.setInt('endAt', v);

  /// { '2026-10-05': 次数, ... }
  static Map<String, int> get daily {
    final raw = p.getString('daily');
    if (raw == null) return {};
    return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k.toString(), v as int));
  }

  static Future<void> _saveDaily(Map<String, int> d) =>
      p.setString('daily', jsonEncode(d));

  static int get streak => p.getInt('streak') ?? 0;
  static Future<void> _setStreak(int v) => p.setInt('streak', v);

  static String get lastActiveDate => p.getString('lastActiveDate') ?? '';
  static Future<void> _setLastActiveDate(String v) =>
      p.setString('lastActiveDate', v);

  static String todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// 打卡一次：今天次数 +1，维护连续达标天数
  static Future<void> recordDone() async {
    final d = daily;
    final tk = todayKey();
    d[tk] = (d[tk] ?? 0) + 1;
    await _saveDaily(d);

    if (lastActiveDate != tk) {
      final y = DateTime.now().subtract(const Duration(days: 1));
      final yk = '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
      await _setStreak(lastActiveDate == yk ? streak + 1 : 1);
      await _setLastActiveDate(tk);
    }
  }

  static int todayCount() => daily[todayKey()] ?? 0;

  static Future<void> clearAll() async {
    await p.remove('daily');
    await _setStreak(0);
    await _setLastActiveDate('');
  }

  /// 是否处于免打扰时段
  static bool inQuietHours() {
    final n = DateTime.now();
    final cur = n.hour * 60 + n.minute;
    int toMin(String s) {
      final parts = s.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final s = toMin(quietStart);
    final e = toMin(quietEnd);
    return s < e ? (cur >= s && cur < e) : (cur >= s || cur < e);
  }
}
