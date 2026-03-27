# Cloud Functions AI 호출 프로토타입

목표: 앱에서 호출하면 "단어 1개 + 의미 1개"를 반환하는 callable function 만들기.

---

## 1) Functions 초기화

프로젝트 루트에서:

```powershell
firebase login
firebase init functions
```

선택 권장:

- Language: TypeScript
- ESLint: Yes
- Install dependencies: Yes

---

## 2) 환경 변수

API 키는 앱에 두지 않고 Functions에만 둔다.

```powershell
firebase functions:config:set ai.provider="openai" ai.api_key="YOUR_SECRET_KEY"
```

로컬 에뮬레이터에서 사용할 `.runtimeconfig.json`은 외부 공유 금지.

---

## 3) 예시 함수 (`functions/src/index.ts`)

```ts
import * as functions from "firebase-functions";

type GenerateWordResponse = {
  word: string;
  meaningKo: string;
  example?: string;
};

export const generateWord = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context): Promise<GenerateWordResponse> => {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Login required");
    }

    const targetLanguage = (data?.targetLanguage ?? "ja") as string;
    const level = (data?.level ?? "beginner") as string;

    // TODO: 실제 AI 호출로 대체
    // 초기 프로토타입에서는 고정 응답으로 플로우 검증
    if (targetLanguage === "ja" && level === "beginner") {
      return {
        word: "ありがとう",
        meaningKo: "고마워요",
        example: "ありがとう、助かりました。",
      };
    }

    return {
      word: "hola",
      meaningKo: "안녕",
      example: "Hola, ¿cómo estás?",
    };
  });
```

초기에는 고정 응답으로 "앱 ↔ 함수 연결"을 먼저 검증하고, 이후 실제 AI API 연결로 전환한다.

---

## 4) Flutter 호출 예시

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<Map<String, dynamic>> fetchWord() async {
  final callable = FirebaseFunctions.instanceFor(
    region: 'asia-northeast3',
  ).httpsCallable('generateWord');

  final result = await callable.call({
    'targetLanguage': 'ja',
    'level': 'beginner',
  });

  return Map<String, dynamic>.from(result.data as Map);
}
```

---

## 5) 중요 운영 포인트

- region은 KST 운영을 고려해 `asia-northeast3`(서울) 권장
- 함수는 반드시 인증된 사용자만 호출 가능하게 유지
- Prompt/응답 포맷 검증 로직을 함수 내부에 둬서 앱 안정성 확보
- API 비용 보호를 위해 호출 횟수 제한(사용자/일 단위)을 조기에 설계
