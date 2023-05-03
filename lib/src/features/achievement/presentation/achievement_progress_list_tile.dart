import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verifi/src/common/fonts/fixed_font_awesome_icons.dart';
import 'package:verifi/src/features/achievement/domain/achievement_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';
import 'package:verifi/src/features/profile/domain/user_achievement_progress_model.dart';

class AchievementProgressListTile extends StatelessWidget {
  static const height = 100.0;
  static const padding = 8.0;

  final Achievement achievement;
  final UserAchievementProgress? progress;

  const AchievementProgressListTile({
    super.key,
    required this.achievement,
    required this.progress,
  });

  Color get _badgeBackgroundColor {
    final tier = progress?.nextTier ?? achievement.initialTier;
    switch (tier) {
      case TierIdentifier.bronze:
        return Colors.brown.shade200;
      case TierIdentifier.silver:
        return Colors.grey.shade300;
      case TierIdentifier.gold:
        return Colors.yellow.shade600;
    }
  }

  Color get _badgeIconEndColor {
    final tier = progress?.nextTier ?? achievement.initialTier;
    switch (tier) {
      case TierIdentifier.bronze:
        return Colors.brown.shade500;
      case TierIdentifier.silver:
        return Colors.grey.shade500;
      case TierIdentifier.gold:
        return Colors.yellow.shade800;
    }
  }

  Color get _badgeIconStartColor {
    final tier = progress?.nextTier ?? achievement.initialTier;
    switch (tier) {
      case TierIdentifier.bronze:
        return Colors.brown.shade300;
      case TierIdentifier.silver:
        return Colors.grey.shade400;
      case TierIdentifier.gold:
        return Colors.yellow.shade700;
    }
  }

  Color? get _badgeShadowColor {
    final tier = progress?.nextTier ?? achievement.initialTier;
    switch (tier) {
      case TierIdentifier.bronze:
        return Colors.brown.shade300.withOpacity(0.8);
      case TierIdentifier.silver:
        return Colors.grey.shade400.withOpacity(0.8);
      case TierIdentifier.gold:
        return Colors.yellow.shade700.withOpacity(0.8);
    }
  }

  int calculateNextTierProgress() {
    int tierProgress = 0;
    if (achievement.cumulative) {
      progress?.tiersProgress.forEach((tier, progress) {
        tierProgress += progress;
      });
    } else {
      tierProgress += progress?.tiersProgress[progress?.nextTier] ?? 0;
    }
    return tierProgress;
  }

  @override
  Widget build(BuildContext context) {
    final int nextTierProgress = calculateNextTierProgress();
    final int nextTierRequirement = achievement
        .tiers[progress?.nextTier ?? achievement.initialTier]!.requirement;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          SizedBox(
            width: height - (padding * 3),
            child: _AwardBadge(
              iconSize: height - (padding * 6.0),
              iconGradientStart: _badgeIconStartColor,
              iconGradientEnd: _badgeIconEndColor,
              shadow: _badgeShadowColor,
              background: _badgeBackgroundColor,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Expanded(
                    child: Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            color: nextTierProgress == nextTierRequirement
                                ? _badgeIconEndColor
                                : null,
                            backgroundColor: Colors.grey.shade300,
                            value: nextTierProgress / nextTierRequirement,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("$nextTierProgress/$nextTierRequirement"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _AwardBadge extends StatelessWidget {
  final double iconSize;
  final Color iconGradientStart;
  final Color iconGradientEnd;
  final Color background;
  final Color? shadow;

  final Gradient _gradient;

  _AwardBadge({
    required this.iconSize,
    required this.iconGradientStart,
    required this.iconGradientEnd,
    required this.background,
    this.shadow,
  }) : _gradient = LinearGradient(
          colors: [iconGradientStart, iconGradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: shadow == null
            ? null
            : [
                BoxShadow(
                  color: shadow!,
                  offset: const Offset(2, 2),
                )
              ],
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: ShaderMask(
        child: FaIcon(
          FixedFontAwesomeIcons.trophy,
          size: iconSize,
          color: Colors.white,
        ),
        shaderCallback: (Rect bounds) => _gradient.createShader(bounds),
      ),
    );
  }
}
