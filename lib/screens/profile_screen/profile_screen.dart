import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/blocs/svg_provider.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/screens/profile_screen/edit_profile_modal_bottom_sheet.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        "My Profile",
      ),
    );
  }
}

class ProfileBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _profilePhoto(),
          _profileName(),
          _logoutButton(),
        ],
      ),
    );
  }

  Widget _profilePhoto() {
    return BlocBuilder<ProfileCubit, Profile>(
      builder: (context, profile) {
        final nftPfp = profile.pfp;
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    // Profile picture avatar
                    child: CircleAvatar(
                      radius: 55,
                      // Show NFT if set, otherwise show Multiavatar
                      backgroundImage: (nftPfp != null)
                          ? nftPfp.image
                          : SvgProvider(
                              randomAvatarString(
                                profile.displayName!,
                                trBackground: true,
                              ),
                              source: SvgSource.raw,
                            ),
                      backgroundColor: Theme.of(context).colorScheme.background,
                    ),
                  ),
                  // Edit icon centered at bottom of profile avatar
                  _editProfileIconButton(),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _editProfileIconButton() {
    return Positioned(
      bottom: -2,
      child: RawMaterialButton(
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        fillColor: Theme.of(context).colorScheme.primary,
        elevation: 2.0,
        shape: const CircleBorder(),
        child: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
        onPressed: () => _showEditProfileBottomSheet(),
      ),
    );
  }

  Widget _profileName() {
    final displayName = context.watch<ProfileCubit>().displayName;
    assert(displayName != null);
    return Text(
      displayName!,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
      child: const Text(
        "Logout",
      ),
      onPressed: () async {
        await context.read<ProfileCubit>().clear();
        context.read<ProfileCubit>().logout();
        context.read<AuthenticationCubit>().logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      },
    );
  }

  void _showEditProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EditProfileModalBottomSheet();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
