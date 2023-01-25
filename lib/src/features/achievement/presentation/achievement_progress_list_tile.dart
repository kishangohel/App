import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verifi/src/common/fonts/fixed_font_awesome_icons.dart';
import 'package:verifi/src/features/achievement/domain/achievement_progress_model.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';

class AchievementProgressListTile extends StatelessWidget {
  static const height = 100.0;
  static const padding = 8.0;

  final AchievementProgress progress;

  const AchievementProgressListTile({
    super.key,
    required this.progress,
  });

  Color get _badgeBackgroundColor {
    switch (progress.completedTier) {
      case null:
        return Colors.grey.shade200;
      case TierIdentifier.bronze:
        return Colors.orange.shade200;
      case TierIdentifier.silver:
        return Colors.grey.shade300;
      case TierIdentifier.gold:
        return Colors.yellow.shade600;
    }
  }

  Color get _badgeIconEndColor {
    switch (progress.completedTier) {
      case null:
        return Colors.grey.shade300;
      case TierIdentifier.bronze:
        return Colors.orange.shade500;
      case TierIdentifier.silver:
        return Colors.grey.shade500;
      case TierIdentifier.gold:
        return Colors.yellow.shade800;
    }
  }

  Color get _badgeIconStartColor {
    switch (progress.completedTier) {
      case null:
        return Colors.grey.shade300;
      case TierIdentifier.bronze:
        return Colors.orange.shade300;
      case TierIdentifier.silver:
        return Colors.grey.shade400;
      case TierIdentifier.gold:
        return Colors.yellow.shade700;
    }
  }

  Color? get _badgeShadowColor {
    switch (progress.completedTier) {
      case null:
        return null;
      case TierIdentifier.bronze:
        return Colors.orange.shade300.withOpacity(0.8);
      case TierIdentifier.silver:
        return Colors.grey.shade400.withOpacity(0.8);
      case TierIdentifier.gold:
        return Colors.yellow.shade700.withOpacity(0.8);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    progress.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Expanded(
                    child: Text(
                      progress.description,
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
                            color:
                                progress.isComplete ? _badgeIconEndColor : null,
                            backgroundColor: Colors.grey.shade300,
                            value: progress.progress / progress.total,
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("${progress.progress}/${progress.total}"),
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
