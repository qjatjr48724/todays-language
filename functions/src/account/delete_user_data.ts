import * as admin from "firebase-admin";
import type { Query } from "firebase-admin/firestore";

import { db } from "../shared/firebase";

/** Firestore rules `isSupportedChatRoom`와 동일 */
export const CHAT_ROOM_IDS = ["KOR", "USA", "JPN"] as const;

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


/** `users/{uid}` 및 `daily_progress` 하위 컬렉션을 삭제합니다. */
export async function deleteUserFirestoreProfile(uid: string): Promise<number> {
  const userRef = db.collection("users").doc(uid);
  const dailyProgressDeleted = await deleteQueryBatch(
    userRef.collection("daily_progress"),
  );
  await userRef.delete();
  return dailyProgressDeleted;
}


export type DeleteUserAccountResult = {
  chatMessagesDeleted: number;
  dailyProgressDeleted: number;
};


/** Firestore 사용자 데이터 삭제 후 Firebase Auth 계정을 삭제합니다. */
export async function deleteUserAccount(uid: string): Promise<DeleteUserAccountResult> {
  const chatMessagesDeleted = await deleteUserChatMessages(uid);
  const dailyProgressDeleted = await deleteUserFirestoreProfile(uid);
  await admin.auth().deleteUser(uid);

  return { chatMessagesDeleted, dailyProgressDeleted };
}
