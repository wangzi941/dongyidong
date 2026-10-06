import 'package:flutter/material.dart';
import '../widgets/ring_painter.dart';

class _Ex {
  final String name;
  final int secs;
  final String desc;
  final IconData icon;
  const _Ex(this.name, this.secs, this.desc, this.icon);
}

const _list = [
  _Ex('颈部环绕', 30, '缓慢用下巴画圈，顺时针、逆时针各 15 秒', Icons.face_retouching_natural),
  _Ex('肩部环绕', 30, '双肩向前、向后各绕环 10 次，放松斜方肌', Icons.accessibility_new),
  _Ex('站立伸展', 40, '双手举过头顶交叉，身体向左右各弯 10 秒', Icons.sunny),
  _Ex('手腕旋转', 30, '双臂前伸，手腕顺时针、逆时针各 15 秒', Icons.pan_tool_outlined),
  _Ex('原地深蹲', 45, '扶椅背慢蹲慢起 12 次，激活下肢循环', Icons.fitness_center),
  _Ex('远眺放松', 60, '走到窗边，看 6 米外景物，眨眨眼', Icons.visibility_outlined),
];

class ExercisesScreen extends StatelessWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        children: [
          const Text('拉伸动作库',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, letterSpacing: 3, color: Color(0xFF8A93A8))),
          const SizedBox(height: 6),
          const Text('每次 2 分钟，身体会感谢你',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 24),
          ...List.generate(_list.length, (i) {
            final ex = _list[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: i % 2 == 0 ? const Color(0xFFF4F7FF) : const Color(0xFFFBF9EC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: blue.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Icon(ex.icon, color: blue),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.name,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600, color: navy)),
                          const SizedBox(height: 3),
                          Text(ex.desc,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF8A93A8), height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text('${ex.secs} 秒',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: blue)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
