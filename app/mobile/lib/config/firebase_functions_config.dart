import 'package:cloud_functions/cloud_functions.dart';

/// Cloud Functions 기본 리전(DEV_RULES · Functions 배포와 동일하게 유지).
const String kFirebaseFunctionsRegion = 'asia-northeast3';

/// 앱에서 사용하는 Firebase Functions 인스턴스(region 고정).
FirebaseFunctions appFirebaseFunctions() =>
    FirebaseFunctions.instanceFor(region: kFirebaseFunctionsRegion);

HttpsCallable callableEnsureTodayLearningSets() =>
    appFirebaseFunctions().httpsCallable('ensureTodayLearningSets');

HttpsCallable callableEnsureLearningSetForToday() =>
    appFirebaseFunctions().httpsCallable('ensureLearningSetForToday');

HttpsCallable callableGenerateWord() =>
    appFirebaseFunctions().httpsCallable('generateWord');

HttpsCallable callableGenerateSentence() =>
    appFirebaseFunctions().httpsCallable('generateSentence');

HttpsCallable callableGetWrapUpDeck() =>
    appFirebaseFunctions().httpsCallable('getWrapUpDeck');

HttpsCallable callableSeedCountryCatalog() =>
    appFirebaseFunctions().httpsCallable('seedCountryCatalog');

HttpsCallable callableSyncCountryFlags() =>
    appFirebaseFunctions().httpsCallable('syncCountryFlags');
