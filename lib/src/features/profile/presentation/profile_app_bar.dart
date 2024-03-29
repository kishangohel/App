import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';

class ProfileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProvider);
    return profile.when(
      loading: () {
        return AppBar(
          centerTitle: true,
          title: VShimmerWidget(
            height: kToolbarHeight,
            width: MediaQuery.of(context).size.width * 0.5,
          ),
        );
      },
      data: (currentUser) {
        return AppBar(
          centerTitle: true,
          title: Text(currentUser?.displayName ?? ''),
        );
      },
      error: (err, stack) {
        return Text(err.toString());
      },
    );
  }
}
