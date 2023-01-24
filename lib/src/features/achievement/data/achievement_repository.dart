import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';

part 'achievement_repository.g.dart';

class AchievementRepository {
  late FirebaseFirestore _firestore;
  late CollectionReference<Map<String, dynamic>> _achievementCollection;

  AchievementRepository({FirebaseFirestore? firestore}) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _achievementCollection = _firestore.collection('Achievement');
  }

  Future<List<Achievement>> getAchievements() async {
    final query = await _achievementCollection.orderBy("ListPriority").get();

    return query.docs.map(Achievement.fromDocumentSnapshot).toList();
  }
}

@riverpod
AchievementRepository achievementRepository(AchievementRepositoryRef ref) {
  return AchievementRepository();
}
