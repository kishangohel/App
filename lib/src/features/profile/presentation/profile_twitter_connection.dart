import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/authentication/data/authentication_repository.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/domain/current_user_model.dart';

class ProfileTwitterConnection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 8),
      const Divider(endIndent: 80, indent: 80, color: Colors.black26),
      const SizedBox(height: 8),
      _title(context),
      const SizedBox(height: 8),
      _body(context, ref),
    ]);
  }

  Widget _title(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const FaIcon(
          FontAwesomeIcons.twitter,
          color: Colors.lightBlueAccent,
        ),
        const SizedBox(width: 8),
        Text(
          'Twitter',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _body(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(currentUserProvider);

    if (userProfileState.isLoading || userProfileState.valueOrNull == null) {
      return const VShimmerWidget(width: 180, height: 80);
    }

    final currentUser = userProfileState.value!;
    if (currentUser.twitterAccount == null) {
      return _linkToTwitter(ref, currentUser);
    } else {
      return _twitterLinked(context, ref, currentUser.twitterAccount!);
    }
  }

  Widget _twitterLinked(
    BuildContext context,
    WidgetRef ref,
    LinkedTwitterAccount twitterAccount,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          twitterAccount.displayName,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            ref.read(authRepositoryProvider).unlinkTwitterAccount();
          },
          child: const Text('Unlink Twitter account'),
        ),
      ],
    );
  }

  Widget _linkToTwitter(WidgetRef ref, CurrentUser currentUser) {
    return ElevatedButton(
      onPressed: () {
        ref.read(authRepositoryProvider).linkTwitterAccount();
      },
      child: const Text("Link Twitter account"),
    );
  }
}
