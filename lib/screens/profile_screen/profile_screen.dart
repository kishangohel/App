import 'package:auto_connect/auto_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/pfp.dart';
import 'package:verifi/models/profile.dart';
import 'package:verifi/screens/profile_screen/edit_profile_modal_bottom_sheet.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: BlocBuilder<ProfileCubit, Profile>(
        builder: (context, profile) {
          return Text(
            profile.displayName!,
          );
        },
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
    return BlocBuilder<ProfileCubit, Profile>(
      buildWhen: (previous, current) => current.id != '',
      builder: (context, profile) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profilePhoto(profile.pfp!, profile.displayName!),
              Expanded(
                child: _profileStats(profile),
              ),
              _logoutButton(),
              _deleteAccountButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _profilePhoto(Pfp nftPfp, String displayName) {
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
                  backgroundImage: nftPfp.image,
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
  }

  Widget _editProfileIconButton() {
    return Positioned(
      bottom: -2,
      child: RawMaterialButton(
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
        fillColor: Theme.of(context).colorScheme.secondary,
        elevation: 2.0,
        shape: const CircleBorder(),
        child: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.onSecondary,
          size: 20,
        ),
        onPressed: () => _showEditProfileBottomSheet(),
      ),
    );
  }

  Widget _profileStats(Profile profile) {
    return Column(
      children: [
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   children: [
        //     Text(
        //       "$veriPoints",
        //       style: Theme.of(context).textTheme.headlineSmall,
        //     ),
        //     Text(
        //       "VeriPoints",
        //       style: Theme.of(context).textTheme.bodyLarge,
        //     ),
        //   ],
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text("${profile.contributed}"),
                Text(
                  "Contributed",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Column(children: [
              Text("${profile.validated}"),
              Text(
                "Validated",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
      child: const Text(
        "Logout",
      ),
      onPressed: () async {
        AutoConnect.removeAllGeofences();
        await context.read<ProfileCubit>().clear();
        context.read<ProfileCubit>().logout();
        await context.read<AuthenticationCubit>().logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (route) => false,
        );
      },
    );
  }

  Widget _deleteAccountButton() {
    return TextButton(
      onPressed: () async {
        final shouldDelete = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: const Icon(Icons.warning),
              title: const Text("Warning!"),
              content: const Text(
                "You are about to delete your account. This is final and not "
                "reversible. All account information, stats, etc. will be "
                "permanently deleted from our servers.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    "Cancel",
                    textAlign: TextAlign.end,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    "Delete My Account",
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            );
          },
        );
        if (shouldDelete) {
          AutoConnect.removeAllGeofences();
          await context.read<ProfileCubit>().deleteProfile();
          await context.read<ProfileCubit>().clear();
          context.read<ProfileCubit>().logout();
          await context.read<AuthenticationCubit>().logout();
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/onboarding',
            (route) => false,
          );
        }
      },
      child: Text(
        "Delete account",
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
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
