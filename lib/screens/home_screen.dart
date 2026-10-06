import 'package:flutter/material.dart';
import '../services/storage.dart';
import '../widgets/ring_painter.dart';

class HomeScreen extends StatelessWidget {
  final int totalSec;
  final int remaining;
  final bool running;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onSnooze;
  final VoidCallback onReset;
  final VoidCallback onFinishEarly;

  const HomeScreen({
    super.key,
    required this.totalSec,
    required this.remaining,
    required this.running,
    required this.onStart,
    required this.onPause,
    required this.onSnooze,
    required this.onReset,
    required this.onFinishEarly,
  });

  @override
  Widget build(BuildContext context) {
    final low = remaining < totalSec * 0.12;
    final inRound = remaining < totalSec && remaining > 0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        children: [
          Text(
            running ? '久坐计时中' : inRound ? '已暂停' : '准备开始',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13, letterSpacing: 3, color: Color(0xFF8A93A8)),
          ),
          const SizedBox(height: 6),
          const Text('该站起来动一动了',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: RingPainter(totalSec == 0 ? 0 : remaining / totalSec),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(fmt(remaining),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: low ? gold : navy,
                          )),
                      const SizedBox(height: 6),
                      Text(
                        low ? '马上到点，准备起身' : '本轮目标 ${totalSec ~/ 60} 分钟',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF8A93A8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: running ? onPause : onStart,
            style: FilledButton.styleFrom(
              backgroundColor: blue,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const StadiumBorder(),
            ),
            child: Text(
              running ? '暂停计时' : inRound ? '继续计时' : '开始计时',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: running ? onSnooze : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    side: const BorderSide(color: blue, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('推迟 5 分钟',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: inRound ? onFinishEarly : onReset,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F4FC),
                    foregroundColor: navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(inRound ? '提前完成' : '重置本轮',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  color: blue,
                  bg: const Color(0xFFF4F7FF),
                  value: '${Storage.todayCount()}',
                  label: '今日已起身（次）',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  color: gold,
                  bg: const Color(0xFFFBF9EC),
                  value: '${Storage.streak}',
                  label: '连续达标（天）',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final Color bg;
  final String value;
  final String label;

  const _StatCard(
      {required this.color, required this.bg, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
        ],
      ),
    );
  }
}
