import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verifi/src/features/achievement/data/achievement_repository.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';

import '../helper.dart';

void main() {
  group(AchievementRepository, () {
    late FirebaseFirestore firestore;
    late AchievementRepository achievementRepository;

    setUpAll(() {
      firestore = FakeFirebaseFirestore();
      achievementRepository = AchievementRepository(firestore: firestore);
    });

    test("""
      Given a Firestore instance with an Achievements collection
      When we call getAchievements
      Then it returns a list of Achievement objects
      """, () async {
      firestore
          .collection('Achievement')
          .withConverter<Achievement>(
            fromFirestore: Achievement.fromFirestore,
            toFirestore: (achievement, _) => achievement.toFirestore(),
          )
          .doc('test-achievement')
          .set(achievement);
      final achievements = await achievementRepository.getAchievements().first;
      expect(achievements, isA<List<Achievement>>());
      expect(achievements, isNotEmpty);
    });
  });
}
