import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';

class Achievement extends Equatable {
  final String identifier;
  final String name;
  final String statisticsKey;
  final List<AchievementTier> tiers;
  final String? description;

  const Achievement({
    required this.identifier,
    required this.name,
    required this.statisticsKey,
    required this.tiers,
    this.description,
  });

  factory Achievement.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      throw Exception('Document does not exist');
    }
    final data = snapshot.data()! as Map<String, dynamic>;
    return Achievement(
      identifier: data['Identifier'],
      name: data['Name'],
      statisticsKey: data['StatisticsKey'],
      tiers: List.castFrom<dynamic, Map<String, dynamic>>(data['Tiers'])
          .map(AchievementTier.fromJson)
          .toList(),
      description: data['Description'],
    );
  }

  @override
  List<Object?> get props => [name, statisticsKey, tiers, description];
}

enum AchievementStatus {
  notAchieved,
  bronze,
  silver,
  gold,
}
