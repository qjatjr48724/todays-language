import test from "node:test";
import assert from "node:assert/strict";

import { CHAT_ROOM_IDS } from "./delete_user_data";

test("CHAT_ROOM_IDS matches Firestore chat room policy", () => {
  assert.deepEqual([...CHAT_ROOM_IDS], ["KOR", "USA", "JPN"]);
});
