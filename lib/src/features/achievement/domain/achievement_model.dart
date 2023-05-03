import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:verifi/src/features/achievement/domain/achievement_tier_model.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final int priority;
  final Map<TierIdentifier, AchievementTier> tiers;
  final TierIdentifier initialTier;
  final bool cumulative;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.tiers,
    required this.initialTier,
    required this.cumulative,
  });

  factory Achievement.fromFirestore(
    DocumentSnapshot snapshot,
    SnapshotOptions? options,
  ) {
    if (!snapshot.exists) {
      throw Exception('Document does not exist');
    }
    final data = snapshot.data() as Map<String, dynamic>?;
    if (null == data) {
      throw Exception('Document contains no data');
    }
    return Achievement(
      id: snapshot.id,
      name: data['Name'],
      priority: data['Priority'],
      description: data['Description'],
      tiers: (data['Tiers'] as Map<String, dynamic>)
          .map<TierIdentifier, AchievementTier>(
        (key, value) {
          final tierId = TierIdentifier.encode(key);
          return MapEntry(tierId, AchievementTier.fromJson(value));
        },
      ),
      initialTier: TierIdentifier.encode(data['InitialTier']),
      cumulative: data['Cumulative'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Name': name,
      'Description': description,
      'Priority': priority,
      'Tiers': tiers.map(
        (key, value) => MapEntry(
          TierIdentifier.decode(key),
          value.toJson(),
        ),
      ),
      'InitialTier': TierIdentifier.decode(initialTier),
      'Cumulative': cumulative,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        priority,
        tiers,
        initialTier,
        cumulative,
      ];
}
