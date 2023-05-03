import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tuple/tuple.dart';
import 'package:verifi/src/features/achievement/data/achievement_repository.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';
import 'package:verifi/src/features/profile/domain/user_achievement_progress_model.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

part '_generated/user_achievements_progress_controller.g.dart';

/// Merge achievements with user achievement progress
@riverpod
class UserAchievementsProgressController
    extends _$UserAchievementsProgressController {
  @override
  List<Tuple2<Achievement, UserAchievementProgress?>>? build() {
    final achievements = ref.watch(achievementsProvider).value;
    if (null == achievements) return null;
    final currentUser = ref.watch(currentUserProvider).value;
    if (null == currentUser) return null;
    return achievements
        .map((achievement) => Tuple2<Achievement, UserAchievementProgress?>(
            achievement,
            currentUser.profile.getAchievementProgress(achievement.id)))
        .toList();
  }
}
