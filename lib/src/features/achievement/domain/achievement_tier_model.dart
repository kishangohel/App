import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';

class AchievementTier extends Equatable {
  final int requirement;
  final int reward;
  final String description;

  const AchievementTier({
    required this.requirement,
    required this.reward,
    required this.description,
  });

  @override
  List<Object?> get props => [requirement, reward, description];

  factory AchievementTier.fromJson(Map<String, dynamic> json) {
    return AchievementTier(
      requirement: json["Requirement"],
      reward: json["Reward"],
      description: json["Description"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Requirement": requirement,
      "Reward": reward,
      "Description": description,
    };
  }
}

enum TierIdentifier {
  bronze,
  silver,
  gold;

  factory TierIdentifier.encode(String value) {
    final tierID = EnumToString.fromString(TierIdentifier.values, value);
    if (null == tierID) {
      throw Exception("Invalid TierIdentifier: $value");
    }
    return tierID;
  }

  static String decode(TierIdentifier tierID) {
    return EnumToString.convertToString(tierID, camelCase: true);
  }
}
