import 'package:flutter/material.dart';
import '../services/storage.dart';
import '../widgets/ring_painter.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<int> onIntervalChanged;
  const SettingsScreen({super.key, required this.onIntervalChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _intervals = [20, 30, 40, 50, 60];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        children: [
          const Text('提醒设置',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, letterSpacing: 3, color: Color(0xFF8A93A8))),
          const SizedBox(height: 6),
          const Text('按你的节奏来',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('久坐提醒间隔',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: navy)),
                const SizedBox(height: 3),
                const Text('建议每 30–60 分钟起身一次',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _intervals
                      .map((m) => ChoiceChip(
                            label: Text('$m 分钟'),
                            selected: Storage.interval == m,
                            selectedColor: blue,
                            labelStyle: TextStyle(
                              color: Storage.interval == m ? Colors.white : navy,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (_) {
                              widget.onIntervalChanged(m);
                              setState(() {});
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(28)),
            child: Column(
              children: [
                _switchTile('提醒铃声', '到点时播放轻柔提示音', Storage.sound, (v) {
                  Storage.setSound(v);
                  setState(() {});
                }),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _switchTile('震动提醒', '静音场合用震动提示', Storage.vibrate, (v) {
                  Storage.setVibrate(v);
                  setState(() {});
                }),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _switchTile('强提醒模式', '必须完成打卡才能关闭提醒', Storage.strict, (v) {
                  Storage.setStrict(v);
                  setState(() {});
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFF4F7FF), borderRadius: BorderRadius.circular(28)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('免打扰时段',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600, color: navy)),
                    Text('此时间段内不推送提醒',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
                  ],
                ),
                Row(
                  children: [
                    _timeChip(Storage.quietStart, (v) {
                      Storage.setQuietStart(v);
                      setState(() {});
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('至',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
                    ),
                    _timeChip(Storage.quietEnd, (v) {
                      Storage.setQuietEnd(v);
                      setState(() {});
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () async {
              await Storage.clearAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已清空全部记录')));
              }
              setState(() {});
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFDF0ED),
              foregroundColor: const Color(0xFFB6432F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: const Text('清空全部记录',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(String title, String hint, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: navy)),
      subtitle: Text(hint, style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
      value: value,
      activeColor: blue,
      onChanged: onChanged,
    );
  }

  Widget _timeChip(String time, ValueChanged<String> onChanged) {
    return ActionChip(
      label: Text(time,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: navy)),
      backgroundColor: Colors.white,
      onPressed: () async {
        final parts = time.split(':').map(int.parse).toList();
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: parts[0], minute: parts[1]),
        );
        if (picked != null) {
          onChanged(
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        }
      },
    );
  }
}
