import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';

import '../helper.dart';

void main() {
  late FirebaseFirestore fakeFirestore;
  group(Achievement, () {
    setUpAll(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test(
      """
      Given a doc id that doesn't exist in the Achievement collection
      When we attempt to convert that Firestore document to an Achievement
      Then an exception is thrown
      """,
      () async {
        final snap = await fakeFirestore
            .collection('Achievement')
            .doc('invalid-id')
            .get();
        expect(() => Achievement.fromFirestore(snap, null), throwsException);
      },
    );

    test(
      """
      Given a doc id that exists in the Achievement collection but does not
      contain any data
      When we attempt to convert that Firestore document to an Achievement
      Then an Exception is thrown
      """,
      () async {
        await fakeFirestore
            .collection('Achievement')
            .doc('test-achievement')
            .set({});
        final snap = await fakeFirestore
            .collection('Achievement')
            .doc('test-achievement')
            .get();
        expect(() => Achievement.fromFirestore(snap, null), throwsException);
      },
    );

    test(
      """
      Given a doc id for a document that exists in the Achievement collection
      When we attempt to convert that Firestore document to an Achievement
      Then it succeeds
      """,
      () async {
        await fakeFirestore
            .collection('Achievement')
            .doc('test-achievement')
            .withConverter<Achievement>(
              fromFirestore: Achievement.fromFirestore,
              toFirestore: (achievement, _) => achievement.toFirestore(),
            )
            .set(achievement);
        final snap = await fakeFirestore
            .collection('Achievement')
            .doc('test-achievement')
            .withConverter<Achievement>(
              fromFirestore: Achievement.fromFirestore,
              toFirestore: (achievement, _) => achievement.toFirestore(),
            )
            .get();
        expect(snap.data(), isNotNull);
        expect(snap.data(), achievement);
      },
    );
  });
}
