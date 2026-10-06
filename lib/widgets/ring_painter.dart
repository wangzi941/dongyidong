import 'dart:math' as math;
import 'package:flutter/material.dart';

const blue = Color(0xFF4A7BF7);
const gold = Color(0xFFCBB916);
const navy = Color(0xFF1B2A4A);

/// 倒计时进度环
class RingPainter extends CustomPainter {
  final double progress; // 0~1 剩余比例
  RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 8;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..color = const Color(0xFFEDF1FB),
    );

    final low = progress < 0.12;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..color = low ? gold : blue,
    );
  }

  @override
  bool shouldRepaint(RingPainter old) => old.progress != progress;
}

String fmt(int sec) {
  final m = sec ~/ 60;
  final s = sec % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
