import 'package:flutter/material.dart';
import '../widgets/ring_painter.dart';

/// 全屏提醒弹层：蓝色底 + 手绘感人物 + 拉伸建议
class ReminderScreen extends StatelessWidget {
  final bool strict;
  final VoidCallback onDone;
  final VoidCallback onSnooze;

  const ReminderScreen({
    super.key,
    required this.strict,
    required this.onDone,
    required this.onSnooze,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (_, v, child) => Opacity(
                  opacity: v,
                  child: Transform.scale(scale: 0.9 + v * 0.1, child: child),
                ),
                child: const Icon(Icons.directions_walk,
                    size: 140, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('坐太久了，\n该站起来动一动了！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.4)),
              const SizedBox(height: 14),
              Text(
                '建议：站立伸展 40 秒 + 远眺放松 60 秒\n${strict ? '强提醒模式：完成打卡后才能继续计时' : '完成一次拉伸，给身体充充电'}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('我已完成拉伸 ✓',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              if (!strict) ...[
                const SizedBox(height: 14),
                TextButton(
                  onPressed: onSnooze,
                  child: const Text('5 分钟后再提醒我',
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
