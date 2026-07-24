# [TEMP] 커리큘럼 세트 JSON export / import

이 폴더(`docs/export_cur`)는 **임시 도구 + 받아온 JSON** 전용이다.  
작업이 끝나면 **폴더 전체를 삭제**하면 된다.

## 준비

```bash
cd docs/export_cur
npm install
gcloud auth application-default login
gcloud config set project todays-language-dev
```

또는 서비스 계정:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
```

## export

```bash
cd docs/export_cur
npm run export -- --doc JPN_beginner_1_1
```

결과: `docs/export_cur/JPN_beginner_1_1.json`

## import (편집 후)

```bash
cd docs/export_cur
npm run import -- --file JPN_beginner_1_1.json
```

- 텍스트가 바뀐 항목의 음성 경로(`wordAudioPath` 등)는 자동 제거된다.
- 전부 재생성: `--clear-all-audio` 추가.
