import 'package:equatable/equatable.dart';

class AchievementTier extends Equatable {
  final TierIdentifier identifier;
  final int goalTotal;
  final String? description;

  const AchievementTier({
    required this.identifier,
    required this.goalTotal,
    this.description,
  });

  factory AchievementTier.fromJson(Map<String, dynamic> json) {
    return AchievementTier(
      identifier: TierIdentifier.deserialize(json["Identifier"]),
      goalTotal: json["GoalTotal"],
      description: json["Description"],
    );
  }

  @override
  List<Object?> get props => [identifier, goalTotal, description];
}

enum TierIdentifier {
  bronze,
  silver,
  gold;

  static TierIdentifier deserialize(String value) {
    switch (value) {
      case "BronzeTier":
        return TierIdentifier.bronze;
      case "SilverTier":
        return TierIdentifier.silver;
      case "GoldTier":
        return TierIdentifier.gold;
      default:
        throw "Unknown tier identifier: $value";
    }
  }
}
