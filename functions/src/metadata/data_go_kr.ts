function dataGoKrServiceKey(): string {
  const k = (process.env.DATA_GO_KR_SERVICE_KEY ?? "").trim();
  if (!k) throw new Error("DATA_GO_KR_SERVICE_KEY is missing");
  return k;
}

function extractDownloadUrlFromDataGoKrJson(root: unknown): string | null {
  // 문서 구조가 환경/버전에 따라 다를 수 있어, download_url을 최대한 안전하게 탐색합니다.
  const stack: unknown[] = [root];
  const seen = new Set<unknown>();
  while (stack.length > 0) {
    const cur = stack.pop();
    if (cur === null || cur === undefined) continue;
    if (typeof cur !== "object") continue;
    if (seen.has(cur)) continue;
    seen.add(cur);

    const obj = cur as Record<string, unknown>;
    const dl = obj["download_url"];
    if (typeof dl === "string" && dl.startsWith("http")) return dl;

    for (const v of Object.values(obj)) {
      if (typeof v === "object" && v !== null) stack.push(v);
      if (Array.isArray(v)) for (const vv of v) stack.push(vv);
    }
  }
  return null;
}

export async function fetchFlagUrlFromDataGoKr(alpha2: string): Promise<string> {
  const serviceKey = dataGoKrServiceKey();
  const url = new URL("https://apis.data.go.kr/1262000/CountryFlagService2/getCountryFlagList2");
  url.searchParams.set("ServiceKey", serviceKey);
  url.searchParams.set("returnType", "JSON");
  url.searchParams.set("numOfRows", "1");
  url.searchParams.set("pageNo", "1");
  url.searchParams.set("cond[country_iso_alp2::EQ]", alpha2.toUpperCase());

  const res = await fetch(url.toString(), { method: "GET" });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`data.go.kr HTTP ${res.status}: ${text.slice(0, 500)}`);
  }
  const json: unknown = await res.json();
  const dl = extractDownloadUrlFromDataGoKrJson(json);
  if (!dl) throw new Error("download_url not found in data.go.kr response");
  return dl;
}

