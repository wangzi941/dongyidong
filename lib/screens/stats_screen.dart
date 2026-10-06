import 'package:flutter/material.dart';
import '../services/storage.dart';
import '../widgets/ring_painter.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final daily = Storage.daily;
    final labels = ['日', '一', '二', '三', '四', '五', '六'];
    final week = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return (label: labels[d.weekday % 7], count: daily[key] ?? 0);
    });
    final max = week.fold<int>(1, (a, b) => b.count > a ? b.count : a);
    final weekTotal = week.fold<int>(0, (a, b) => a + b.count);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        children: [
          const Text('活动记录',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, letterSpacing: 3, color: Color(0xFF8A93A8))),
          const SizedBox(height: 6),
          const Text('这一周，你有在好好活动',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('本周起身活动',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                Text('$weekTotal',
                    style: const TextStyle(
                        fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('次 · 连续达标 ${Storage.streak} 天',
                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(28)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: week
                  .map((d) => Expanded(
                        child: Column(
                          children: [
                            Text(d.count > 0 ? '${d.count}' : '',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600, color: navy)),
                            const SizedBox(height: 4),
                            Container(
                              width: 22,
                              height: d.count == 0 ? 6 : 24 + (d.count / max) * 86,
                              decoration: BoxDecoration(
                                color: d.count == 0
                                    ? blue.withOpacity(0.25)
                                    : (d.label == '六' ? gold : blue),
                                borderRadius: BorderRadius.circular(11),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(d.label,
                                style:
                                    const TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFFBF9EC), borderRadius: BorderRadius.circular(24)),
            child: const Row(
              children: [
                SizedBox(
                  width: 4,
                  height: 44,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: gold, borderRadius: BorderRadius.all(Radius.circular(2))),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('小提示',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600, color: navy)),
                      SizedBox(height: 4),
                      Text('保持节奏，每小时起身一次效果最好',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
