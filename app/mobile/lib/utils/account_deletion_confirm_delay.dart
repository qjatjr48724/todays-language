/// 탈퇴 확인 버튼 활성화까지 필요한 대기 시간(초).
const int kAccountDeletionConfirmDelaySeconds = 5;


/// [elapsedSeconds]가 [requiredSeconds] 이상이면 탈퇴 확인 버튼을 활성화합니다.
bool accountDeletionConfirmEnabled(
  int elapsedSeconds, {
  int requiredSeconds = kAccountDeletionConfirmDelaySeconds,
}) {
  return elapsedSeconds >= requiredSeconds;
}
