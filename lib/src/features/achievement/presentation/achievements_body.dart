import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/achievement/presentation/achievement_progress_list_tile.dart';
import 'package:verifi/src/features/achievement/presentation/user_achievements_progress_controller.dart';

class AchievementsBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementProgresses =
        ref.watch(userAchievementsProgressControllerProvider);

    return ListView.builder(
      itemExtent: AchievementProgressListTile.height,
      itemCount: achievementProgresses?.length ?? 3,
      itemBuilder: (context, i) {
        return achievementProgresses == null
            ? _shimmer
            : AchievementProgressListTile(
                achievement: achievementProgresses[i].item1,
                progress: achievementProgresses[i].item2,
              );
      },
    );
  }

  Widget get _shimmer => const VShimmerWidget(
        width: 100,
        height: AchievementProgressListTile.height,
      );
}
