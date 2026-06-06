/**
 * 50일 커리큘럼 로테이션 (core_v1) — 언어·난이도·단계(phase) 공통 주제표.
 * 일상·교통·여행·학교 50일 순서는 기획 확정본(2026-06) 기준.
 *
 * - 모든 targetLanguage에 동일한 learningDay / topicIds 적용.
 * - 실제 단어·문장은 (언어 × level × phase × 일차)별로 별도 생성.
 * - 2단계(phase 2)는 동일 topicIds, 새 어휘(1단계 exclude).
 */

export const CURRICULUM_CORE_V1_ID = "core_v1";

export const CURRICULUM_CORE_V1_TOTAL_DAYS = 50;

export type CurriculumCategory =
  | "daily_life"
  | "transport"
  | "travel"
  | "school"
  | "food"
  | "health"
  | "weather";

/** 세부 주제 메타 — 프롬프트·UI 라벨용 */
export type CurriculumTopicMeta = {
  topicId: string;
  category: CurriculumCategory;
  labelKo: string;
  /** OpenAI 시스템 프롬프트에 넣을 범위 설명(영문) */
  promptScopeEn: string;
};

export type CurriculumDaySpec = {
  learningDay: number;
  category: CurriculumCategory;
  topicIds: readonly string[];
  topicLabelsKo: readonly string[];
  /** 그날 전체 학습 범위(프롬프트용, 영문) */
  promptScopeEn: string;
};

/** 세부 주제 카탈로그 — topicId 조회·프롬프트 보조 */
export const CURRICULUM_TOPIC_CATALOG: Record<string, CurriculumTopicMeta> = {
  "DL-01": {
    topicId: "DL-01",
    category: "daily_life",
    labelKo: "인삿말 - 만날 때 / 헤어질 때 / 처음 만날 때 / 오랜만에 만날 때 / 오랫동안 헤어질 때",
    promptScopeEn:
      "greetings: meeting, parting, first meeting, meeting after a long time, long farewell",
  },
  "DL-02": {
    topicId: "DL-02",
    category: "daily_life",
    labelKo: "인삿말 - 외출·귀가",
    promptScopeEn: "going out and coming home phrases (leaving home, returning, see you later)",
  },
  "DL-03": {
    topicId: "DL-03",
    category: "daily_life",
    labelKo: "인삿말 - 감사·사과",
    promptScopeEn: "thanks, apologies, excuse me, forgiveness",
  },
  "DL-04": {
    topicId: "DL-04",
    category: "daily_life",
    labelKo: "인삿말 - 식사·끼니",
    promptScopeEn: "meals, breakfast/lunch/dinner, hungry, eating schedule",
  },
  "DL-05": {
    topicId: "DL-05",
    category: "daily_life",
    labelKo: "숫자표현 - 개수·수량",
    promptScopeEn: "counting, quantities, units (items, people, cups), many/few",
  },
  "DL-06": {
    topicId: "DL-06",
    category: "daily_life",
    labelKo: "감정 표현",
    promptScopeEn: "expressing emotions (happy, sad, worried, surprised, agreement/disagreement)",
  },
  "DL-07": {
    topicId: "DL-07",
    category: "daily_life",
    labelKo: "인칭대명사",
    promptScopeEn: "personal pronouns (I, you, he, she, we, they, polite forms)",
  },
  "DL-08": {
    topicId: "DL-08",
    category: "daily_life",
    labelKo: "명사의 긍정/의문/부정표현",
    promptScopeEn: "noun affirmative, interrogative, and negative expressions (is/are, do/does, not)",
  },
  "DL-09": {
    topicId: "DL-09",
    category: "daily_life",
    labelKo: "부탁·요청",
    promptScopeEn: "polite requests, asking favors, accepting/refusing",
  },
  "DL-10": {
    topicId: "DL-10",
    category: "daily_life",
    labelKo: "출발점과 도달점을 나타내는 표현",
    promptScopeEn: "origin and destination (from, to, depart, arrive, starting point, endpoint)",
  },
  "DL-11": {
    topicId: "DL-11",
    category: "daily_life",
    labelKo: "시간",
    promptScopeEn: "telling time, hours, morning/afternoon/evening, waiting, soon/later",
  },
  "DL-12": {
    topicId: "DL-12",
    category: "daily_life",
    labelKo: "요일·날짜",
    promptScopeEn: "days of the week, today/tomorrow/yesterday, dates",
  },
  "DL-13": {
    topicId: "DL-13",
    category: "daily_life",
    labelKo: "가족·호칭",
    promptScopeEn: "family members, kinship terms, addressing family",
  },
  "DL-14": {
    topicId: "DL-14",
    category: "daily_life",
    labelKo: "날씨·기온",
    promptScopeEn: "weather and temperature (sunny, rainy, hot, cold)",
  },
  "DL-15": {
    topicId: "DL-15",
    category: "daily_life",
    labelKo: "몸 상태·증상",
    promptScopeEn: "body conditions, symptoms (headache, fever, hurt)",
  },
  "DL-16": {
    topicId: "DL-16",
    category: "daily_life",
    labelKo: "화폐·가격",
    promptScopeEn: "money, prices, cheap/expensive, paying, change, receipts",
  },
  "DL-17": {
    topicId: "DL-17",
    category: "daily_life",
    labelKo: "축하·위로",
    promptScopeEn: "congratulations, celebrations, condolences, encouragement",
  },
  "DL-18": {
    topicId: "DL-18",
    category: "daily_life",
    labelKo: "욕구·희망",
    promptScopeEn: "wants, hopes, wishes, plans, I want to / I would like to",
  },
  "DL-19": {
    topicId: "DL-19",
    category: "daily_life",
    labelKo: "이유·원인·근거",
    promptScopeEn: "reasons and causes (because, so, therefore, why)",
  },
  "DL-20": {
    topicId: "DL-20",
    category: "daily_life",
    labelKo: "경험·일화",
    promptScopeEn: "sharing experiences (have done before, first time, recently, memories)",
  },
  "TM-01": {
    topicId: "TM-01",
    category: "transport",
    labelKo: "이동·방향",
    promptScopeEn: "movement and directions (go, come, stop, left/right, cross)",
  },
  "TM-11": {
    topicId: "TM-11",
    category: "transport",
    labelKo: "버스·택시·렌터",
    promptScopeEn: "bus routes and stops, taxi rides, rental car basics",
  },
  "TM-03": {
    topicId: "TM-03",
    category: "transport",
    labelKo: "지하철·전철",
    promptScopeEn: "subway/metro lines, transfers, exits, last train",
  },
  "TM-05": {
    topicId: "TM-05",
    category: "transport",
    labelKo: "기차·고속철",
    promptScopeEn: "trains, stations, platforms, seats, tickets",
  },
  "TM-06": {
    topicId: "TM-06",
    category: "transport",
    labelKo: "표·요금",
    promptScopeEn: "tickets, fares, passes, discounts, how much for transport",
  },
  "TM-07": {
    topicId: "TM-07",
    category: "transport",
    labelKo: "역·정류장",
    promptScopeEn: "stations and stops, where to board, which exit",
  },
  "TM-08": {
    topicId: "TM-08",
    category: "transport",
    labelKo: "지연·변경",
    promptScopeEn: "delays, cancellations, detours, alternative routes",
  },
  "TM-09": {
    topicId: "TM-09",
    category: "transport",
    labelKo: "안전·규칙",
    promptScopeEn: "safety rules, giving seat, no running, warnings",
  },
  "TM-10": {
    topicId: "TM-10",
    category: "transport",
    labelKo: "자전거·도보",
    promptScopeEn: "walking, minutes on foot, bicycle, distance",
  },
  "TR-01": {
    topicId: "TR-01",
    category: "travel",
    labelKo: "여행 준비",
    promptScopeEn: "trip preparation, packing, passport, essentials",
  },
  "TR-02": {
    topicId: "TR-02",
    category: "travel",
    labelKo: "예약·티켓",
    promptScopeEn: "bookings, reservations, confirmation numbers, changes",
  },
  "TR-03": {
    topicId: "TR-03",
    category: "travel",
    labelKo: "공항·출입국",
    promptScopeEn: "airport, check-in, security, gate, immigration, baggage",
  },
  "TR-04": {
    topicId: "TR-04",
    category: "travel",
    labelKo: "숙소",
    promptScopeEn: "hotel/hostel, check-in/out, room, facilities",
  },
  "TR-05": {
    topicId: "TR-05",
    category: "travel",
    labelKo: "식당·주문 (여행)",
    promptScopeEn: "ordering food while traveling, menu, allergies, bill",
  },
  "TR-06": {
    topicId: "TR-06",
    category: "travel",
    labelKo: "관광·명소",
    promptScopeEn: "sightseeing, attractions, tickets, opening hours, photos",
  },
  "TR-07": {
    topicId: "TR-07",
    category: "travel",
    labelKo: "쇼핑·기념품",
    promptScopeEn: "souvenirs, shopping abroad, size/color, refund",
  },
  "TR-08": {
    topicId: "TR-08",
    category: "travel",
    labelKo: "길찾기·위치",
    promptScopeEn: "asking directions, landmarks, maps, where is",
  },
  "TR-09": {
    topicId: "TR-09",
    category: "travel",
    labelKo: "대중교통 (여행지)",
    promptScopeEn: "using local transit while traveling (timetable, stop, line)",
  },
  "TR-11": {
    topicId: "TR-11",
    category: "travel",
    labelKo: "문제·응급",
    promptScopeEn: "travel problems, lost items, delays, police, hospital, help",
  },
  "TR-12": {
    topicId: "TR-12",
    category: "travel",
    labelKo: "현지 문화·매너",
    promptScopeEn: "local customs, manners, tipping, cultural thanks",
  },
  "SC-01": {
    topicId: "SC-01",
    category: "school",
    labelKo: "학교·교실",
    promptScopeEn: "classroom, school building, attendance, late",
  },
  "SC-02": {
    topicId: "SC-02",
    category: "school",
    labelKo: "수업·과목",
    promptScopeEn: "classes, subjects, lesson start/end, understanding",
  },
  "SC-03": {
    topicId: "SC-03",
    category: "school",
    labelKo: "선생님·존댓말",
    promptScopeEn: "teachers, polite speech to teachers, questions in class",
  },
  "SC-04": {
    topicId: "SC-04",
    category: "school",
    labelKo: "친구·또래",
    promptScopeEn: "friends, classmates, playing together, introductions",
  },
  "SC-05": {
    topicId: "SC-05",
    category: "school",
    labelKo: "시간표·일과",
    promptScopeEn: "schedule, breaks, lunch, after school",
  },
  "SC-06": {
    topicId: "SC-06",
    category: "school",
    labelKo: "숙제·공부",
    promptScopeEn: "homework, studying, submit, don't understand",
  },
  "SC-07": {
    topicId: "SC-07",
    category: "school",
    labelKo: "시험·성적",
    promptScopeEn: "tests, exams, scores, pass/fail, worry",
  },
  "SC-08": {
    topicId: "SC-08",
    category: "school",
    labelKo: "학교 시설",
    promptScopeEn: "library, gym, cafeteria, office, restroom at school",
  },
  "SC-09": {
    topicId: "SC-09",
    category: "school",
    labelKo: "동아리·행사",
    promptScopeEn: "clubs, school events, festival, presentation",
  },
  "SC-10": {
    topicId: "SC-10",
    category: "school",
    labelKo: "진로·상담",
    promptScopeEn: "future plans, career talk, counseling, advice",
  },
};

/** 50일 로테이션 — learningDay 1..50 (기획 확정 순서) */
export const CURRICULUM_CORE_V1_DAYS: readonly CurriculumDaySpec[] = [
  day(1, "daily_life", ["DL-01"]),
  day(2, "daily_life", ["DL-02"]),
  day(3, "daily_life", ["DL-03"]),
  day(4, "daily_life", ["DL-04"]),
  day(5, "daily_life", ["DL-05"]),
  day(6, "daily_life", ["DL-06"]),
  day(7, "daily_life", ["DL-07"]),
  day(8, "daily_life", ["DL-08"]),
  day(9, "daily_life", ["DL-09"]),
  day(10, "daily_life", ["DL-10"]),
  day(11, "daily_life", ["DL-11"]),
  day(12, "daily_life", ["DL-12"]),
  day(13, "daily_life", ["DL-13"]),
  day(14, "daily_life", ["DL-14"]),
  day(15, "daily_life", ["DL-15"]),
  day(16, "daily_life", ["DL-16"]),
  day(17, "daily_life", ["DL-17"]),
  day(18, "daily_life", ["DL-18"]),
  day(19, "daily_life", ["DL-19"]),
  day(20, "daily_life", ["DL-20"]),
  day(21, "transport", ["TM-01"]),
  day(22, "transport", ["TM-11"]),
  day(23, "transport", ["TM-03"]),
  day(24, "transport", ["TM-05"]),
  day(25, "transport", ["TM-06"]),
  day(26, "transport", ["TM-07"]),
  day(27, "transport", ["TM-08"]),
  day(28, "transport", ["TM-09"]),
  day(29, "transport", ["TM-10"]),
  day(30, "travel", ["TR-01"]),
  day(31, "travel", ["TR-02"]),
  day(32, "travel", ["TR-03"]),
  day(33, "travel", ["TR-04"]),
  day(34, "travel", ["TR-05"]),
  day(35, "travel", ["TR-06"]),
  day(36, "travel", ["TR-07"]),
  day(37, "travel", ["TR-08"]),
  day(38, "travel", ["TR-09"]),
  day(39, "travel", ["TR-11"]),
  day(40, "travel", ["TR-12"]),
  day(41, "school", ["SC-01"]),
  day(42, "school", ["SC-02"]),
  day(43, "school", ["SC-03"]),
  day(44, "school", ["SC-04"]),
  day(45, "school", ["SC-05"]),
  day(46, "school", ["SC-06"]),
  day(47, "school", ["SC-07"]),
  day(48, "school", ["SC-08"]),
  day(49, "school", ["SC-09"]),
  day(50, "school", ["SC-10"]),
] as const;

function day(
  learningDay: number,
  category: CurriculumCategory,
  topicIds: string[]
): CurriculumDaySpec {
  const metas = topicIds.map((id) => {
    const m = CURRICULUM_TOPIC_CATALOG[id];
    if (!m) {
      throw new Error(`Unknown topicId: ${id} (learningDay ${learningDay})`);
    }
    return m;
  });
  return {
    learningDay,
    category,
    topicIds,
    topicLabelsKo: metas.map((m) => m.labelKo),
    promptScopeEn: metas.map((m) => m.promptScopeEn).join("; "),
  };
}

/** learningDay(1..50) → 일차 스펙 */
export function getCurriculumDaySpec(learningDay: number): CurriculumDaySpec | undefined {
  if (!Number.isInteger(learningDay) || learningDay < 1 || learningDay > CURRICULUM_CORE_V1_TOTAL_DAYS) {
    return undefined;
  }
  return CURRICULUM_CORE_V1_DAYS[learningDay - 1];
}

/** 프롬프트용: 그날 학습 주제 요약 문자열 */
export function formatCurriculumDayForPrompt(learningDay: number): string {
  const spec = getCurriculumDaySpec(learningDay);
  if (!spec) {
    return `unknown day (learningDay=${learningDay})`;
  }
  const ids = spec.topicIds.join(", ");
  const labels = spec.topicLabelsKo.join(", ");
  return `Day ${spec.learningDay}/${CURRICULUM_CORE_V1_TOTAL_DAYS}, topics [${ids}] (${labels}): ${spec.promptScopeEn}`;
}

/** 프롬프트 user JSON에 넣을 필드 조각 */
export function curriculumContextForPrompt(learningDay: number): {
  curriculumId: string;
  learningDay: number;
  totalDays: number;
  category: CurriculumCategory;
  topicIds: string[];
  topicLabelsKo: string[];
  promptScopeEn: string;
} | undefined {
  const spec = getCurriculumDaySpec(learningDay);
  if (!spec) return undefined;
  return {
    curriculumId: CURRICULUM_CORE_V1_ID,
    learningDay: spec.learningDay,
    totalDays: CURRICULUM_CORE_V1_TOTAL_DAYS,
    category: spec.category,
    topicIds: [...spec.topicIds],
    topicLabelsKo: [...spec.topicLabelsKo],
    promptScopeEn: spec.promptScopeEn,
  };
}
