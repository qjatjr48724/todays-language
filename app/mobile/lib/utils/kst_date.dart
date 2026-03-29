/// 한국 자정 기준 일일 리셋용: [Asia/Seoul](https://en.wikipedia.org/wiki/Time_in_South_Korea) 날짜 문자열 `yyyy-MM-dd`.
///
/// Dart에 별도 타임존 패키지 없이, "지금 시각"의 KST 달력 날짜를 UTC+9 오프셋으로 계산합니다.
String todayKstYyyyMmDd() {
  final kstInstant = DateTime.now().toUtc().add(const Duration(hours: 9));
  final y = kstInstant.year.toString().padLeft(4, '0');
  final m = kstInstant.month.toString().padLeft(2, '0');
  final d = kstInstant.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
