import * as admin from "firebase-admin";

// Cloud Functions 런타임에서 중복 initialize 방지
if (admin.apps.length === 0) {
  admin.initializeApp();
}

export const db = admin.firestore();

