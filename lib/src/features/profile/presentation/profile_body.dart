import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:verifi/src/common/widgets/shimmer_widget.dart';
import 'package:verifi/src/features/profile/data/profile_repository.dart';
import 'package:verifi/src/features/profile/presentation/widgets/logout_button.dart';
import 'package:verifi/src/features/profile/presentation/widgets/veripoints/veripoints_widget.dart';
import 'package:verifi/src/utils/svg_provider.dart';

class ProfileBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfilePhoto(),
          VeriPointsWidget(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LogoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePhoto extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    return profile.when<Widget>(
      loading: () {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            VShimmerWidget(width: 150, height: 150),
          ],
        );
      },
      data: (profile) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Border around avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    // Profile picture avatar
                    child: CircleAvatar(
                      radius: 55,
                      // Show NFT if set, otherwise show Multiavatar
                      backgroundImage: SvgProvider(
                        randomAvatarString(
                          profile!.displayName,
                          trBackground: true,
                        ),
                        source: SvgSource.raw,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  // info button
                  Positioned(
                    bottom: 15,
                    right: 30,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
                      child: IconButton(
                        color: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.all(0),
                        splashRadius: 20,
                        icon: Icon(
                          Icons.info,
                          size: 20,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AboutProfilePictureDialog(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      },
      error: (err, stack) {
        return Text(err.toString());
      },
    );
  }
}

class AboutProfilePictureDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 40,
        child: AutoSizeText(
          'Why is this my profile picture?',
          maxLines: 1,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
      content: RichText(
        text: TextSpan(
          text: 'Profile pictures are automatically '
              'generated from your unique display name '
              'via the ',
          style: Theme.of(context).textTheme.titleMedium,
          children: [
            TextSpan(
              text: 'Multiavatar project',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrlString(
                    'https://multiavatar.com',
                  );
                },
            ),
            const TextSpan(
              text: '.\n\nIn a future update, you will be '
                  'able to customize your profile '
                  'picture.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Close',
          ),
        ),
      ],
    );
  }
}
