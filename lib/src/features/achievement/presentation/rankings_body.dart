import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/user_profile_model.dart';

class RankingsBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankings = ref.watch(userProfileRankingsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        children: [
          Text(
            "All time rankings",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: rankings.hasValue
                ? _rankingTable(rankings.value!)
                : _loadingTable(),
          ),
        ],
      ),
    );
  }

  Widget _rankingTable(List<UserProfile> rankings) {
    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, i) {
        final profile = rankings[i];

        return _RankingRow(
          ranking: i + 1,
          avatar: randomAvatar(
            profile.displayName,
            width: 50,
            height: 50,
          ),
          name: Text(
            profile.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          score: Text(
            profile.veriPoints.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      },
    );
  }

  Widget _loadingTable() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, i) {
        return _RankingRow(
          ranking: i + 1,
          avatar: const VShimmerWidget(
            borderRadius: 50,
            width: 50,
            height: 50,
          ),
          name: const VShimmerWidget(width: 100, height: 30),
          score: const VShimmerWidget(width: 50, height: 30),
        );
      },
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int ranking;
  final Widget avatar;
  final Widget name;
  final Widget score;

  const _RankingRow({
    required this.ranking,
    required this.avatar,
    required this.name,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerRight,
            width: 40,
            child: Text(
              "$ranking. ",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(width: 50, height: 50, child: avatar),
          const SizedBox(width: 8),
          Expanded(child: name),
          score,
        ],
      ),
    );
  }
}
