/** Functions `admin_tools_auth.ts` / 앱 AdminToolsScreen.testAdminUid 와 동기 */
export const ADMIN_TOOLS_UID = "WhyAQoWSP4Ociipn0HQtxCwQboN2";

export const FUNCTIONS_REGION = "asia-northeast3";

export const SUPPORT_CATEGORIES = [
  { value: "bug", label: "버그/오류" },
  { value: "account", label: "계정" },
  { value: "suggestion", label: "기능 제안" },
  { value: "other", label: "기타" },
] as const;

export const INQUIRY_STATUS_LABELS: Record<string, string> = {
  open: "접수",
  answered: "답변 완료",
  closed: "종료",
};
