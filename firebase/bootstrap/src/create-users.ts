import * as admin from "firebase-admin";
import { App } from "firebase-admin/app";
import { UserRecord } from "firebase-admin/lib/auth/user-record";

// The test user phone numbers will start with this value, ascending.
const phoneNumberStart = 6505553434

export const createUsers = async (
  app: App,
  userCount: number,
): Promise<Array<UserRecord>> => {
  const users: Array<UserRecord> = [];

  for (let i = 0; i < userCount; i++) {
    const newUser = await admin.auth(app).createUser({
      phoneNumber: `+1 ${phoneNumberStart + i}`,
      displayName: `test_user${i == 0 ? "" : "_" + i.toString()}`,
    });
    users.push(newUser);
  }

  return users;
}
