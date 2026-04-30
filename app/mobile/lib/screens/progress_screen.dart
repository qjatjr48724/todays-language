import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/daily_progress_sync.dart';
import '../ui/section_card.dart';
import '../utils/kst_date.dart';
import '../l10n/app_localizations.dart';

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
  bool _openingDetail = false;

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
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _calendarError = l10n.progress_calendar_load_failed(e.toString());
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

  Future<DocumentSnapshot<Map<String, dynamic>>?> _fetchDailyProgressById(
    String dateId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('daily_progress')
        .doc(dateId);
    return ref.get();
  }

  Future<void> _openDayDetail(DateTime day) async {
    if (_openingDetail) return;
    setState(() => _openingDetail = true);
    try {
      final dateId = formatYyyyMmDd(day);
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          final l10n = AppLocalizations.of(context)!;
          return MediaQuery(
            // 바텀시트 텍스트만 20% 축소(다른 화면 영향 없음)
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(0.8),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                  future: _fetchDailyProgressById(dateId),
                  builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.progress_detail_loading,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          l10n.progress_detail_load_failed(
                            (snapshot.error?.toString() ?? '').isEmpty
                                ? '-'
                                : snapshot.error.toString(),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                    );
                  }

                  final snap = snapshot.data;
                  if (snap == null) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          l10n.progress_detail_login_required,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  }

                  // 문서가 없으면 "기록 없음"으로 0/x 를 보여줍니다.
                  final data = snap.data() ?? <String, dynamic>{};

                  int iv(String k, int def) {
                    final v = data[k];
                    if (v is int) return v;
                    if (v is num) return v.toInt();
                    return def;
                  }

                  final percent = iv('progressPercent', 0).clamp(0, 100);
                  final wordGoal = iv('wordGoal', 30);
                  final wordDone = iv('wordDone', 0);
                  final sentenceGoal = iv('sentenceGoal', 10);
                  final sentenceDone = iv('sentenceDone', 0);
                  final quizGoal = iv('quizGoal', 25);
                  final quizDone = iv('quizDone', 0);

                  final hasAny =
                      (wordDone + sentenceDone + quizDone) > 0 || percent > 0;

                  Color barColor() {
                    if (percent >= 80) return Colors.green;
                    if (percent >= 40) return Colors.orange;
                    return Colors.red;
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.progress_detail_header(dateId),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      if (!hasAny) ...[
                        Text(
                          l10n.progress_detail_no_record,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: (percent / 100).clamp(0.0, 1.0),
                                minHeight: 12,
                                backgroundColor: scheme.surfaceContainerHighest,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(barColor()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(l10n.common_percent(percent)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(
                        title: l10n.progress_detail_word_title,
                        value: '$wordDone / $wordGoal',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        title: l10n.progress_detail_sentence_title,
                        value: '$sentenceDone / $sentenceGoal',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        title: l10n.progress_detail_wrapup_title,
                        value: '$quizDone / $quizGoal',
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.progress_close_button),
                        ),
                      ),
                    ],
                  );
                },
                ),
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _openingDetail = false);
    }
  }

  Widget _buildCalendar(ColorScheme scheme) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final l10n = AppLocalizations.of(context)!;

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

    final weekdayLabels = <String>[
      l10n.progress_weekday_sun,
      l10n.progress_weekday_mon,
      l10n.progress_weekday_tue,
      l10n.progress_weekday_wed,
      l10n.progress_weekday_thu,
      l10n.progress_weekday_fri,
      l10n.progress_weekday_sat,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.progress_month_label(
                month.toString().padLeft(2, '0'),
                year.toString(),
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            IconButton(
              onPressed: _calendarLoading ? null : () => _changeMonth(-1),
              icon: const Icon(Icons.chevron_left),
              tooltip: l10n.progress_prev_month_tooltip,
            ),
            IconButton(
              onPressed: _calendarLoading ? null : () => _changeMonth(1),
              icon: const Icon(Icons.chevron_right),
              tooltip: l10n.progress_next_month_tooltip,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _LegendItem(
              label: l10n.progress_legend_0_39,
              child: _Sticker(shape: _StickerShape.square, color: Colors.red),
            ),
            const SizedBox(width: 10),
            _LegendItem(
              label: l10n.progress_legend_40_79,
              child: _Sticker(shape: _StickerShape.triangle, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            _LegendItem(
              label: l10n.progress_legend_80_100,
              child: _Sticker(shape: _StickerShape.circle, color: Colors.green),
            ),
            const SizedBox(width: 10),
            _LegendItem(
              label: l10n.progress_legend_no_record,
              child: _Sticker(shape: _StickerShape.square, color: Colors.grey),
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
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  // 달력 셀 내부(숫자 + 스티커)가 아래로 overflow 되는 문제를 방지하기 위해
                  // 정사각형보다 살짝 "세로로" 여유를 둡니다.
                  childAspectRatio: 0.85,
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
                  } else {
                    // 과거 날짜인데 daily_progress 문서가 없다면 "미접속/기록 없음"으로 회색 표시
                    final isPastDay = day.isBefore(today);
                    if (isPastDay) {
                      shape = _StickerShape.square;
                      stickerColor = Colors.grey;
                    }
                  }

                  final isToday = isCurrentMonth && dayNumber == today.day;
                  final borderColor =
                      isToday ? scheme.primary : scheme.outlineVariant;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _openDayDetail(day),
                      child: Ink(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(10),
                          color: isToday
                              ? scheme.primary.withValues(alpha: 0.08)
                              : null,
                        ),
                        padding: const EdgeInsets.all(4),
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
                      ),
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
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final p = _progress;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.progress_appbar_title)),
      body: Padding(
        // 카드가 화면에 더 꽉 차 보이도록 좌우 여백을 줄입니다.
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (p == null)
                ? Text(l10n.progress_no_data,
                    style: TextStyle(color: scheme.error))
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
                          SectionCard(
                            title: l10n.progress_home_title,
                            subtitle: l10n.progress_kst_subtitle_prefix(
                              todayKstYyyyMmDd(),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                Text(l10n.common_percent(p.progressPercent)),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.progress_word_line(
                                    p.wordDone,
                                    p.wordGoal,
                                  ),
                                ),
                                Text(
                                  l10n.progress_sentence_line(
                                    p.sentenceDone,
                                    p.sentenceGoal,
                                  ),
                                ),
                                Text(
                                  l10n.progress_wrapup_line(
                                    p.quizDone,
                                    p.quizGoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SectionCard(
                            title: l10n.progress_calendar_card_title,
                            subtitle: l10n.progress_calendar_card_subtitle,
                            trailing: _calendarLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : null,
                            child: _buildCalendar(scheme),
                          ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
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
