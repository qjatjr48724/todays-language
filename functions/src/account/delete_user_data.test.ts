import test from "node:test";
import assert from "node:assert/strict";

import { CHAT_ROOM_IDS, USER_FIRESTORE_SUBCOLLECTIONS } from "./delete_user_data";

test("CHAT_ROOM_IDS matches Firestore chat room policy", () => {
  assert.deepEqual([...CHAT_ROOM_IDS], ["KOR", "USA", "JPN"]);
});

test("USER_FIRESTORE_SUBCOLLECTIONS covers progress and cursor paths", () => {
  assert.deepEqual([...USER_FIRESTORE_SUBCOLLECTIONS], [
    "daily_progress",
    "daily_quiz_cursor",
    "daily_word_cursor",
    "daily_sentence_cursor",
  ]);
});
