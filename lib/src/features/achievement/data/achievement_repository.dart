import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';

part '_generated/achievement_repository.g.dart';

class AchievementRepository {
  late FirebaseFirestore _firestore;
  late CollectionReference<Achievement> _achievementCollection;

  AchievementRepository({FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _achievementCollection = _firestore
        .collection('Achievement')
        .withConverter<Achievement>(
            fromFirestore: Achievement.fromFirestore,
            toFirestore: (achievement, _) => achievement.toFirestore());
  }

  Stream<List<Achievement>> getAchievements() {
    return _achievementCollection
        .withConverter<Achievement>(
          fromFirestore: Achievement.fromFirestore,
          toFirestore: (achievement, _) => achievement.toFirestore(),
        )
        .orderBy("Priority")
        .snapshots()
        .map<List<Achievement>>(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }
}

@Riverpod(keepAlive: true)
AchievementRepository achievementRepository(AchievementRepositoryRef ref) {
  return AchievementRepository();
}

final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final achievementRepository = ref.watch(achievementRepositoryProvider);
  return achievementRepository.getAchievements();
});
