import 'dart:async';
import 'package:flutter/material.dart';
import 'services/storage.dart';
import 'services/notification_service.dart';
import 'widgets/ring_painter.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reminder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await NotificationService.instance.init();
  runApp(const SitLessApp());
}

class SitLessApp extends StatelessWidget {
  const SitLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '动一动 · 久坐提醒',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'sans-serif',
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int tab = 0;
  Timer? _ticker;

  late int totalSec;
  late int remaining;
  bool running = false;
  bool reminding = false;

  @override
  void initState() {
    super.initState();
    totalSec = Storage.interval * 60;
    remaining = totalSec;
    _restore();
  }

  /// 从本地恢复计时状态：App 被杀掉后重开也能接着算
  void _restore() {
    final endAt = Storage.endAt;
    if (endAt == null) return;
    final left = ((endAt - DateTime.now().millisecondsSinceEpoch) / 1000).round();
    if (left <= 0) {
      _timeUp();
    } else {
      remaining = left;
      running = true;
      _tick();
      _scheduleNotif();
    }
  }

  void _tick() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!running) return;
      final left = ((Storage.endAt! - DateTime.now().millisecondsSinceEpoch) / 1000)
          .round()
          .clamp(0, totalSec);
      setState(() => remaining = left);
      if (left <= 0) _timeUp();
    });
  }

  void _scheduleNotif() {
    NotificationService.instance.scheduleAt(
      DateTime.fromMillisecondsSinceEpoch(Storage.endAt!),
      sound: Storage.sound,
      vibrate: Storage.vibrate,
    );
  }

  void _timeUp() {
    _ticker?.cancel();
    setState(() {
      running = false;
    });
    if (Storage.inQuietHours()) {
      _completeRound();
    } else {
      setState(() => reminding = true);
    }
  }

  Future<void> _completeRound() async {
    await Storage.recordDone();
    setState(() {
      reminding = false;
      remaining = totalSec;
      running = false;
    });
  }

  void start() {
    Storage.setEndAt(
        DateTime.now().millisecondsSinceEpoch + remaining * 1000);
    setState(() => running = true);
    _tick();
    _scheduleNotif();
  }

  void pause() {
    _ticker?.cancel();
    Storage.setEndAt(null);
    NotificationService.instance.cancel();
    setState(() => running = false);
  }

  void snooze() {
    setState(() => remaining = 5 * 60);
    start();
  }

  void reset() {
    _ticker?.cancel();
    Storage.setEndAt(null);
    NotificationService.instance.cancel();
    setState(() {
      running = false;
      remaining = totalSec;
    });
  }

  void finishEarly() {
    setState(() => remaining = 0);
    _timeUp();
  }

  void onIntervalChanged(int min) {
    Storage.setInterval(min);
    setState(() {
      totalSec = min * 60;
      if (!running) remaining = totalSec;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        totalSec: totalSec,
        remaining: remaining,
        running: running,
        onStart: start,
        onPause: pause,
        onSnooze: snooze,
        onReset: reset,
        onFinishEarly: finishEarly,
      ),
      const StatsScreen(),
      const ExercisesScreen(),
      SettingsScreen(onIntervalChanged: onIntervalChanged),
    ];

    return Stack(
      children: [
        Scaffold(
          body: screens[tab],
          bottomNavigationBar: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.timer_outlined), label: '计时'),
              NavigationDestination(icon: Icon(Icons.bar_chart), label: '记录'),
              NavigationDestination(icon: Icon(Icons.directions_walk), label: '动作'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), label: '设置'),
            ],
          ),
        ),
        if (reminding)
          ReminderScreen(
            strict: Storage.strict,
            onDone: _completeRound,
            onSnooze: () {
              setState(() => reminding = false);
              snooze();
            },
          ),
      ],
    );
  }
}
