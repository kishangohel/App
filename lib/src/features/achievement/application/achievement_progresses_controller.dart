import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:verifi/src/features/achievement/data/achievement_repository.dart';
import 'package:verifi/src/features/achievement/domain/achievement_progress_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part 'achievement_progresses_controller.g.dart';

@riverpod
class AchievementProgressesController
    extends _$AchievementProgressesController {
  @override
  FutureOr<List<AchievementProgress>?> build() async {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) return null;

    final achievements =
        await ref.watch(achievementRepositoryProvider).getAchievements();

    return achievements
        .map(
          (achievement) => AchievementProgress.evaluate(
            currentUser.profile,
            achievement,
          ),
        )
        .whereType<AchievementProgress>()
        .toList();
  }
}
