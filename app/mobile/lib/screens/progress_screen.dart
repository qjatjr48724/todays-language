import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/daily_progress_sync.dart';
import '../utils/kst_date.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DailyProgressView? _progress;
  bool _loading = true;
  DateTime _focusedMonth = DateTime.now();
  bool _calendarLoading = true;
  String? _calendarError;
  Map<String, int> _monthPercentByDate = <String, int>{};

  @override
  void initState() {
    super.initState();
    final kstNow = kstNowDate();
    _focusedMonth = DateTime(kstNow.year, kstNow.month, 1);
    _load();
    _loadMonth();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final p = await ensureTodayDailyProgress(user);
    if (!mounted) return;
    setState(() {
      _progress = p;
      _loading = false;
    });
  }

  Future<void> _loadMonth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _calendarLoading = true;
      _calendarError = null;
    });

    try {
      final start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      final end = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

      final startId = formatYyyyMmDd(start);
      final endId = formatYyyyMmDd(end);

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_progress')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startId)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endId)
          .get();

      final out = <String, int>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final percent = data['progressPercent'];
        int v = 0;
        if (percent is int) v = percent;
        if (percent is num) v = percent.toInt();
        out[doc.id] = v.clamp(0, 100);
      }
      if (!mounted) return;
      setState(() {
        _monthPercentByDate = out;
        _calendarLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _calendarError = '캘린더 데이터를 불러오지 못했습니다: $e';
        _calendarLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    final next = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    setState(() => _focusedMonth = next);
    _loadMonth();
  }

  int? _percentForDay(DateTime day) {
    final id = formatYyyyMmDd(day);
    return _monthPercentByDate[id];
  }

  Widget _buildCalendar(ColorScheme scheme) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;

    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // 일(0) 시작 기준으로 캘린더를 맞춥니다. DateTime.weekday: Mon=1..Sun=7
    // Sunday-first index: Sun=0, Mon=1, ..., Sat=6
    final leadingBlankCount = (firstDay.weekday % 7).clamp(0, 6);
    final totalCells = leadingBlankCount + daysInMonth;
    final trailingBlankCount = (7 - (totalCells % 7)) % 7;
    final cellCount = totalCells + trailingBlankCount;

    final today = kstNowDate();
    final isCurrentMonth = today.year == year && today.month == month;

    const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$year년 ${month.toString().padLeft(2, '0')}월',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            IconButton(
              onPressed: _calendarLoading ? null : () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left),
              tooltip: '이전 달',
            ),
            IconButton(
              onPressed: _calendarLoading ? null : () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right),
              tooltip: '다음 달',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _LegendItem(
              label: '0~39%',
              child: _Sticker(shape: _StickerShape.square, color: Colors.red),
            ),
            const SizedBox(width: 10),
            _LegendItem(
              label: '40~79%',
              child: _Sticker(shape: _StickerShape.triangle, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            _LegendItem(
              label: '80~100%',
              child: _Sticker(shape: _StickerShape.circle, color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
            color: scheme.surface,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  for (final w in weekdayLabels)
                    Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                itemCount: cellCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  // 달력 셀 내부(숫자 + 스티커)가 아래로 overflow 되는 문제를 방지하기 위해
                  // 정사각형보다 살짝 "세로로" 여유를 둡니다.
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final dayNumber = index - leadingBlankCount + 1;
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final day = DateTime(year, month, dayNumber);
                  final percent = _percentForDay(day);

                  _StickerShape? shape;
                  Color? stickerColor;
                  if (percent != null) {
                    if (percent >= 80) {
                      shape = _StickerShape.circle;
                      stickerColor = Colors.green;
                    } else if (percent >= 40) {
                      shape = _StickerShape.triangle;
                      stickerColor = Colors.orange;
                    } else {
                      shape = _StickerShape.square;
                      stickerColor = Colors.red;
                    }
                  }

                  final isToday = isCurrentMonth && dayNumber == today.day;
                  final borderColor =
                      isToday ? scheme.primary : scheme.outlineVariant;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(10),
                      color: isToday ? scheme.primary.withValues(alpha: 0.08) : null,
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dayNumber',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: shape == null
                              ? const SizedBox.shrink()
                              : _Sticker(shape: shape, color: stickerColor!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (_calendarError != null) ...[
          const SizedBox(height: 10),
          Text(_calendarError!, style: TextStyle(color: scheme.error)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = _progress;
    return Scaffold(
      appBar: AppBar(title: const Text('진행률')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (p == null)
                ? Text('진행률 데이터가 없습니다.', style: TextStyle(color: scheme.error))
                : RefreshIndicator(
                    onRefresh: () async {
                      await _load();
                      await _loadMonth();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 진행률 · ${todayKstYyyyMmDd()}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (p.progressPercent / 100).clamp(0.0, 1.0),
                            minHeight: 14,
                            color: p.progressPercent >= 80
                                ? Colors.green
                                : p.progressPercent >= 40
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Text('${p.progressPercent}%'),
                          const SizedBox(height: 16),
                          Text('단어 ${p.wordDone}/${p.wordGoal}'),
                          Text('문장 ${p.sentenceDone}/${p.sentenceGoal}'),
                          Text('퀴즈 ${p.quizDone}/${p.quizGoal}'),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Text(
                                '캘린더',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 10),
                              if (_calendarLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildCalendar(scheme),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 18, height: 18, child: Center(child: child)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

enum _StickerShape { square, triangle, circle }

class _Sticker extends StatelessWidget {
  const _Sticker({required this.shape, required this.color});

  final _StickerShape shape;
  final Color color;

  @override
  Widget build(BuildContext context) {
    switch (shape) {
      case _StickerShape.square:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      case _StickerShape.circle:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      case _StickerShape.triangle:
        return CustomPaint(
          size: const Size(14, 14),
          painter: _TrianglePainter(color),
        );
    }
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
