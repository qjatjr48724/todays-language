import * as admin from "firebase-admin";
import type { Query } from "firebase-admin/firestore";

import { recordAccountRecreationBlock } from "./account_recreation_block";
import { db } from "../shared/firebase";

/** Firestore rules `isSupportedChatRoom`와 동일 */
export const CHAT_ROOM_IDS = ["KOR", "USA", "JPN"] as const;

/** 탈퇴 시 `users/{uid}` 아래에서 삭제할 하위 컬렉션 (부모 문서 삭제 전 전부 제거) */
export const USER_FIRESTORE_SUBCOLLECTIONS = [
  "daily_progress",
  "daily_quiz_cursor",
  "daily_word_cursor",
  "daily_sentence_cursor",
] as const;

const BATCH_DELETE_LIMIT = 400;


/** 하위 컬렉션 문서를 배치로 삭제하고 삭제 건수를 반환합니다. */
export async function deleteQueryBatch(query: Query): Promise<number> {
  let deleted = 0;

  while (true) {
    const snap = await query.limit(BATCH_DELETE_LIMIT).get();
    if (snap.empty) break;

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    deleted += snap.size;

    if (snap.size < BATCH_DELETE_LIMIT) break;
  }

  return deleted;
}


/** 본인 uid가 작성한 채팅 메시지를 모든 지원 방에서 삭제합니다. */
export async function deleteUserChatMessages(uid: string): Promise<number> {
  let total = 0;

  for (const roomId of CHAT_ROOM_IDS) {
    const messagesRef = db
      .collection("chat_rooms")
      .doc(roomId)
      .collection("messages");
    const count = await deleteQueryBatch(messagesRef.where("uid", "==", uid));
    total += count;
  }

  return total;
}


/** `users/{uid}` 및 모든 사용자 하위 컬렉션을 삭제합니다. */
export async function deleteUserFirestoreProfile(uid: string): Promise<number> {
  const userRef = db.collection("users").doc(uid);
  let totalDeleted = 0;

  for (const sub of USER_FIRESTORE_SUBCOLLECTIONS) {
    const count = await deleteQueryBatch(userRef.collection(sub));
    totalDeleted += count;
  }

  await userRef.delete();
  return totalDeleted;
}


export type DeleteUserAccountResult = {
  chatMessagesDeleted: number;
  userSubcollectionDocsDeleted: number;
};


/** Firestore 사용자 데이터 삭제 후 Firebase Auth 계정을 삭제합니다. */
export async function deleteUserAccount(uid: string): Promise<DeleteUserAccountResult> {
  const userRecord = await admin.auth().getUser(uid);
  const email = userRecord.email?.trim();

  const chatMessagesDeleted = await deleteUserChatMessages(uid);
  const userSubcollectionDocsDeleted = await deleteUserFirestoreProfile(uid);

  if (email) {
    await recordAccountRecreationBlock(email);
  }

  await admin.auth().deleteUser(uid);

  return { chatMessagesDeleted, userSubcollectionDocsDeleted };
}
