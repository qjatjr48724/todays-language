/**
 * 앱 내부 표준: ISO alpha-3 (KOR/USA/JPN/...)
 * 외부 국기 API: ISO alpha-2 (KR/US/JP/...)
 */

export type CountryCatalogItem = {
  alpha3: string;
  alpha2: string;
  /** "각 국가별 언어로 국가 이름" (endonym) */
  endonym: string;
  /** Phase 1: 선택 가능(한·영·일 대상언어만 enabled=true) */
  enabled: boolean;
};

// Phase 1: 대상언어는 한·영·일만 선택 가능. 유럽 3개·중국어는 추후 오픈.
export const COUNTRY_CATALOG_V1: CountryCatalogItem[] = [
  { alpha3: "KOR", alpha2: "KR", endonym: "대한민국", enabled: true },
  { alpha3: "USA", alpha2: "US", endonym: "United States", enabled: true },
  { alpha3: "JPN", alpha2: "JP", endonym: "日本", enabled: true },
  { alpha3: "FRA", alpha2: "FR", endonym: "France", enabled: false },
  { alpha3: "DEU", alpha2: "DE", endonym: "Deutschland", enabled: false },
  { alpha3: "CHN", alpha2: "CN", endonym: "中国", enabled: false },
  { alpha3: "ESP", alpha2: "ES", endonym: "España", enabled: false },

  // 추가 예정(선택 불가) — 샘플(Phase 2~3에서 전체 목록/검색으로 확장)
  { alpha3: "ITA", alpha2: "IT", endonym: "Italia", enabled: false },
  { alpha3: "RUS", alpha2: "RU", endonym: "Россия", enabled: false },
  { alpha3: "BRA", alpha2: "BR", endonym: "Brasil", enabled: false },
];

export function normalizeAlpha3(raw: string): string {
  return (raw ?? "").trim().toUpperCase();
}

