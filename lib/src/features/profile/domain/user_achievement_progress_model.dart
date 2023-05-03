import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';

class UserAchievementProgress extends Equatable {
  final TierIdentifier? currentTier;
  final TierIdentifier nextTier;
  final Map<TierIdentifier, int> tiersProgress;

  const UserAchievementProgress({
    this.currentTier,
    required this.nextTier,
    required this.tiersProgress,
  });

  static UserAchievementProgress fromFirestoreDocumentData(
    Map<String, dynamic> data,
  ) {
    if (!data.containsKey('NextTier') || !data.containsKey('TiersProgress')) {
      throw Exception('Invalid user achievement progress data');
    }
    final nextTier = EnumToString.fromString(
      TierIdentifier.values,
      data['NextTier'],
    );
    if (nextTier == null) {
      throw Exception(
        "Invalid next tier identifier: ${data['NextTier']}",
      );
    }

    TierIdentifier? currentTier;
    if (data.containsKey('CurrentTier')) {
      final currentTier = EnumToString.fromString(
        TierIdentifier.values,
        data['CurrentTier'],
      );
      if (currentTier == null) {
        throw Exception(
          "Invalid current tier identifier: ${data['CurrentTier']}",
        );
      }
    }

    return UserAchievementProgress(
      currentTier: currentTier,
      nextTier: nextTier,
      tiersProgress: (data['TiersProgress'] as Map<String, dynamic>).map(
        (key, value) {
          final tierID = EnumToString.fromString(TierIdentifier.values, key);
          if (null == tierID) {
            throw Exception('Invalid tier identifier: $key');
          }
          return MapEntry(tierID, value);
        },
      ),
    );
  }

  @override
  List<Object?> get props => [currentTier, nextTier, tiersProgress];

  static UserAchievementProgress fromJson(Map<String, dynamic> json) =>
      UserAchievementProgress(
        currentTier: json['currentTier'],
        nextTier: json['nextTier'],
        tiersProgress: json['tiersProgress'],
      );

  Map<String, dynamic> toJson() => {
        'currentTier': currentTier,
        'nextTier': nextTier,
        'tiersProgress': tiersProgress,
      };
}
