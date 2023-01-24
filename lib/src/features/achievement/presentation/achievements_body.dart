import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/achievement/application/achievement_progresses_controller.dart';
import 'package:verifi/src/features/achievement/domain/achievement_progress_model.dart';
import 'package:verifi/src/features/achievement/presentation/achievement_progress_list_tile.dart';

class AchievementsBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<AchievementProgress>? achievementProgresses =
        ref.watch(achievementProgressesControllerProvider).valueOrNull;

    return ListView.builder(
      itemExtent: AchievementProgressListTile.height,
      itemCount:
          achievementProgresses == null ? 3 : achievementProgresses.length,
      itemBuilder: (context, i) => achievementProgresses == null
          ? _shimmer
          : AchievementProgressListTile(progress: achievementProgresses[i]),
    );
  }

  Widget get _shimmer => const VShimmerWidget(
        width: 100,
        height: AchievementProgressListTile.height,
      );
}
