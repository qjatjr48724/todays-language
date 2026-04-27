/**
 * 앱 내부 표준: ISO alpha-3 (KOR/USA/JPN/...)
 * 외부 국기 API: ISO alpha-2 (KR/US/JP/...)
 */

export type CountryCatalogItem = {
  alpha3: string;
  alpha2: string;
  /** "각 국가별 언어로 국가 이름" (endonym) */
  endonym: string;
  /** Phase 1: 선택 가능(요청 8개 범위 내) */
  enabled: boolean;
};

// Phase 1: 당장 선택 가능한 국가(언어)만 enabled=true로 시작
// - 일본어(히라가나/카타카나)는 "국가"가 아니라 "표기 variant"이므로 여기서는 JPN 1개만 둠
export const COUNTRY_CATALOG_V1: CountryCatalogItem[] = [
  { alpha3: "KOR", alpha2: "KR", endonym: "대한민국", enabled: true },
  { alpha3: "USA", alpha2: "US", endonym: "United States", enabled: true },
  { alpha3: "JPN", alpha2: "JP", endonym: "日本", enabled: true },
  { alpha3: "FRA", alpha2: "FR", endonym: "France", enabled: true },
  { alpha3: "DEU", alpha2: "DE", endonym: "Deutschland", enabled: true },
  { alpha3: "CHN", alpha2: "CN", endonym: "中国", enabled: true },
  { alpha3: "ESP", alpha2: "ES", endonym: "España", enabled: true },

  // 추가 예정(선택 불가) — 샘플(Phase 2~3에서 전체 목록/검색으로 확장)
  { alpha3: "ITA", alpha2: "IT", endonym: "Italia", enabled: false },
  { alpha3: "RUS", alpha2: "RU", endonym: "Россия", enabled: false },
  { alpha3: "BRA", alpha2: "BR", endonym: "Brasil", enabled: false },
];

export function normalizeAlpha3(raw: string): string {
  return (raw ?? "").trim().toUpperCase();
}

